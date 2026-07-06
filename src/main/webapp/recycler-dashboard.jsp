<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.util.LocationUtil" %>
<%@ page import="com.wastelink.util.ImpactUtil" %>
<%@ page import="com.wastelink.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"RECYCLER".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }
    int userId = user.getUserId();

    int matchRequestsCount = 0;
    int acceptedDealsCount = 0;
    double totalProcessedKg = 0.0;
    double totalCo2Saved = 0.0;
    double sustainabilityScore = 0.0;

    // Fetch lists
    List<String[]> pendingMatches = new ArrayList<>();
    List<String[]> acceptedDeals = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        // Stats calculations
        // 1. Pending Matches count
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM MATCHES WHERE recycler_id = ? AND status = 'PENDING'")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) matchRequestsCount = rs.getInt(1);
            }
        }

        // 2. Accepted Deals count
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM MATCHES WHERE recycler_id = ? AND status = 'ACCEPTED'")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) acceptedDealsCount = rs.getInt(1);
            }
        }

        // 3. Materials Processed and CO2
        String statsQuery = "SELECT SUM(w.quantity_kg), SUM(m.co2_saved_kg) FROM MATCHES m JOIN WASTE w ON m.waste_id = w.waste_id WHERE m.recycler_id = ? AND m.status = 'ACCEPTED'";
        try (PreparedStatement ps = conn.prepareStatement(statsQuery)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalProcessedKg = rs.getDouble(1);
                    totalCo2Saved = rs.getDouble(2);
                }
            }
        }
        sustainabilityScore = ImpactUtil.sustainabilityScore(totalCo2Saved, totalProcessedKg);

        // 4. Fetch Pending Matches with waste details
        String pendingQuery = "SELECT m.match_id, w.waste_type, w.quantity_kg, w.price_per_kg, w.latitude as w_lat, w.longitude as w_lon, u.company_name as industry_name FROM MATCHES m JOIN WASTE w ON m.waste_id = w.waste_id JOIN USERS u ON w.user_id = u.user_id WHERE m.recycler_id = ? AND m.status = 'PENDING' ORDER BY m.matched_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(pendingQuery)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double dist = LocationUtil.haversineDistance(
                        user.getLatitude(), user.getLongitude(),
                        rs.getDouble("w_lat"), rs.getDouble("w_lon")
                    );
                    pendingMatches.add(new String[]{
                        String.valueOf(rs.getInt("match_id")),
                        rs.getString("waste_type"),
                        String.valueOf(rs.getDouble("quantity_kg")),
                        String.valueOf(rs.getDouble("price_per_kg")),
                        rs.getString("industry_name"),
                        String.format("%.1f", dist)
                    });
                }
            }
        }

        // 5. Fetch Accepted Deals with waste and contact details
        String acceptedQuery = "SELECT m.match_id, w.waste_type, w.quantity_kg, u.company_name as industry_name, u.phone as industry_phone, u.email as industry_email, m.updated_at FROM MATCHES m JOIN WASTE w ON m.waste_id = w.waste_id JOIN USERS u ON w.user_id = u.user_id WHERE m.recycler_id = ? AND m.status = 'ACCEPTED' ORDER BY m.updated_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(acceptedQuery)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    acceptedDeals.add(new String[]{
                        String.valueOf(rs.getInt("match_id")),
                        rs.getString("waste_type"),
                        String.valueOf(rs.getDouble("quantity_kg")),
                        rs.getString("industry_name"),
                        rs.getString("industry_phone"),
                        rs.getString("industry_email"),
                        rs.getTimestamp("updated_at").toString()
                    });
                }
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar Navigation -->
        <div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
            <div class="position-sticky">
                <a class="nav-link active" href="recycler-dashboard.jsp">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
                <a class="nav-link" href="marketplace">
                    <i class="bi bi-shop"></i> Marketplace
                </a>
                <a class="nav-link" href="analytics">
                    <i class="bi bi-bar-chart"></i> Analytics
                </a>
                <a class="nav-link" href="leaderboard">
                    <i class="bi bi-award"></i> Leaderboard
                </a>
                <a class="nav-link" href="notifications">
                    <i class="bi bi-bell"></i> Notifications
                </a>
                <a class="nav-link" href="profile.jsp">
                    <i class="bi bi-person"></i> Profile
                </a>
                <hr class="text-white-50 my-3 mx-3">
                <a class="nav-link text-warning" href="logout">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="page-title">Welcome back, <%= user.getCompanyName() %></h1>
                    <p class="page-subtitle mb-0">Manage match requests, accepted orders, and track your sustainability rating.</p>
                </div>
                <a href="marketplace" class="btn btn-wl-primary text-white d-flex align-items-center gap-2">
                    <i class="bi bi-shop"></i> Browse Marketplace
                </a>
            </div>

            <!-- Stats Bar -->
            <div class="row g-4 mb-5">
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value"><%= matchRequestsCount %></div>
                        <div class="stat-label">Match Requests</div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value"><%= acceptedDealsCount %></div>
                        <div class="stat-label">Accepted Deals</div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value"><%= String.format("%.1f", totalProcessedKg) %> kg</div>
                        <div class="stat-label">Materials Processed</div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value"><%= String.format("%.1f", sustainabilityScore) %>%</div>
                        <div class="stat-label">Sustainability Score</div>
                    </div>
                </div>
            </div>

            <!-- Incoming Matches (Pending Action) -->
            <div class="card card-wl border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="fw-bold mb-0 text-success">Incoming Match Requests</h5>
                </div>
                <div class="card-body p-0">
                    <% if (pendingMatches.isEmpty()) { %>
                        <div class="text-center py-5">
                            <span class="fs-1">⚡</span>
                            <h5 class="mt-3 text-muted">No pending match requests</h5>
                            <p class="small text-muted mb-0">Browse the marketplace to look for materials manually.</p>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-4">Waste Listing</th>
                                        <th>Industry Name</th>
                                        <th>Quantity</th>
                                        <th>Price (per kg)</th>
                                        <th>Distance (Est)</th>
                                        <th class="pe-4 text-end">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (String[] pm : pendingMatches) { %>
                                        <tr>
                                            <td class="ps-4 fw-semibold"><%= pm[1] %></td>
                                            <td><%= pm[4] %></td>
                                            <td><%= pm[2] %> kg</td>
                                            <td>₹<%= pm[3] %></td>
                                            <td><span class="text-success fw-bold"><%= pm[5] %> km</span></td>
                                            <td class="pe-4 text-end">
                                                <div class="d-inline-flex gap-2">
                                                    <form action="match-action" method="POST" class="d-inline">
                                                        <input type="hidden" name="matchId" value="<%= pm[0] %>">
                                                        <input type="hidden" name="action" value="accept">
                                                        <button type="submit" class="btn btn-sm btn-wl-primary text-white py-1 px-3">
                                                            Accept
                                                        </button>
                                                    </form>
                                                    <form action="match-action" method="POST" class="d-inline">
                                                        <input type="hidden" name="matchId" value="<%= pm[0] %>">
                                                        <input type="hidden" name="action" value="reject">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger py-1 px-3">
                                                            Reject
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Accepted Deals Section -->
            <div class="card card-wl border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="fw-bold mb-0 text-success">Accepted Exchange Deals</h5>
                </div>
                <div class="card-body p-0">
                    <% if (acceptedDeals.isEmpty()) { %>
                        <div class="text-center py-5">
                            <span class="fs-1">🤝</span>
                            <h5 class="mt-3 text-muted">No active deals accepted yet</h5>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-4">Waste Listing</th>
                                        <th>Seller (Industry)</th>
                                        <th>Quantity</th>
                                        <th>Contact Email</th>
                                        <th>Contact Phone</th>
                                        <th class="pe-4">Accepted Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (String[] ad : acceptedDeals) { %>
                                        <tr>
                                            <td class="ps-4 fw-semibold"><%= ad[1] %></td>
                                            <td><%= ad[3] %></td>
                                            <td><%= ad[2] %> kg</td>
                                            <td><a href="mailto:<%= ad[5] %>" class="text-decoration-none text-success"><%= ad[5] %></a></td>
                                            <td><%= ad[4] %></td>
                                            <td class="pe-4 text-muted small"><%= ad[6] %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
