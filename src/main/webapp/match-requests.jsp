<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.db.DBConnection" %>
<%@ page import="com.wastelink.util.LocationUtil" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }
    int userId = user.getUserId();
    String role = user.getRole();

    List<String[]> matches = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        String query;
        if ("INDUSTRY".equalsIgnoreCase(role)) {
            query = "SELECT m.match_id, w.waste_type, w.quantity_kg, w.price_per_kg, rc.company_name as partner_company, m.profit_estimate, m.co2_saved_kg, m.status, m.matched_at " +
                    "FROM MATCHES m " +
                    "JOIN WASTE w ON m.waste_id = w.waste_id " +
                    "JOIN USERS rc ON m.recycler_id = rc.user_id " +
                    "WHERE m.industry_user_id = ? " +
                    "ORDER BY m.matched_at DESC";
        } else {
            query = "SELECT m.match_id, w.waste_type, w.quantity_kg, w.price_per_kg, ind.company_name as partner_company, m.profit_estimate, m.co2_saved_kg, m.status, m.matched_at, w.latitude as w_lat, w.longitude as w_lon " +
                    "FROM MATCHES m " +
                    "JOIN WASTE w ON m.waste_id = w.waste_id " +
                    "JOIN USERS ind ON m.industry_user_id = ind.user_id " +
                    "WHERE m.recycler_id = ? " +
                    "ORDER BY m.matched_at DESC";
        }

        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String distance = "N/A";
                    if ("RECYCLER".equalsIgnoreCase(role)) {
                        double d = LocationUtil.haversineDistance(
                            user.getLatitude(), user.getLongitude(),
                            rs.getDouble("w_lat"), rs.getDouble("w_lon")
                        );
                        distance = String.format("%.1f km", d);
                    }
                    matches.add(new String[]{
                        String.valueOf(rs.getInt("match_id")),
                        rs.getString("waste_type"),
                        String.valueOf(rs.getDouble("quantity_kg")),
                        String.valueOf(rs.getDouble("price_per_kg")),
                        rs.getString("partner_company"),
                        String.format("%.2f", rs.getDouble("profit_estimate")),
                        String.format("%.1f", rs.getDouble("co2_saved_kg")),
                        rs.getString("status"),
                        rs.getTimestamp("matched_at").toString(),
                        distance
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
                <% if ("INDUSTRY".equalsIgnoreCase(role)) { %>
                    <a class="nav-link" href="industry-dashboard.jsp">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a class="nav-link" href="add-waste.jsp">
                        <i class="bi bi-plus-circle"></i> Post Waste
                    </a>
                    <a class="nav-link" href="my-listings.jsp">
                        <i class="bi bi-list-task"></i> My Listings
                    </a>
                <% } else { %>
                    <a class="nav-link" href="recycler-dashboard.jsp">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a class="nav-link" href="marketplace">
                        <i class="bi bi-shop"></i> Marketplace
                    </a>
                <% } %>
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
            <div class="mb-4">
                <h1 class="page-title">Match Requests Ledger</h1>
                <p class="page-subtitle">Historical log of all waste exchange matching activities and statuses.</p>
            </div>

            <div class="card card-wl border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="fw-bold mb-0 text-success">All Matching Requests</h5>
                </div>
                <div class="card-body p-0">
                    <% if (matches.isEmpty()) { %>
                        <div class="text-center py-5">
                            <span class="fs-1">🤝</span>
                            <h5 class="mt-3 text-muted">No matches log found.</h5>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-4">Waste Listing</th>
                                        <th><%= "INDUSTRY".equalsIgnoreCase(role) ? "Recycler Buyer" : "Industry Seller" %></th>
                                        <th>Quantity (kg)</th>
                                        <th>Price (₹/kg)</th>
                                        <th>Est. Profit</th>
                                        <th>CO₂ Offsets</th>
                                        <% if ("RECYCLER".equalsIgnoreCase(role)) { %>
                                            <th>Distance</th>
                                        <% } %>
                                        <th>Matched At</th>
                                        <th class="pe-4">Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (String[] m : matches) { 
                                        String badge = "bg-warning-subtle text-warning";
                                        if ("ACCEPTED".equalsIgnoreCase(m[7])) badge = "bg-success-subtle text-success";
                                        if ("REJECTED".equalsIgnoreCase(m[7])) badge = "bg-danger-subtle text-danger";
                                        if ("COMPLETED".equalsIgnoreCase(m[7])) badge = "bg-info-subtle text-info";
                                    %>
                                        <tr>
                                            <td class="ps-4 fw-semibold"><%= m[1] %></td>
                                            <td><%= m[4] %></td>
                                            <td><%= m[2] %> kg</td>
                                            <td>₹<%= m[3] %></td>
                                            <td class="text-success fw-bold">₹<%= m[5] %></td>
                                            <td><span class="text-success fw-semibold"><%= m[6] %> kg</span></td>
                                            <% if ("RECYCLER".equalsIgnoreCase(role)) { %>
                                                <td><%= m[9] %></td>
                                            <% } %>
                                            <td class="small text-muted"><%= m[8] %></td>
                                            <td class="pe-4"><span class="badge <%= badge %>"><%= m[7] %></span></td>
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
