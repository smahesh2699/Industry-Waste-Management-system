<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.model.Waste" %>
<%@ page import="com.wastelink.dao.WasteDAO" %>
<%@ page import="com.wastelink.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"INDUSTRY".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }
    int userId = user.getUserId();

    int totalListings = 0;
    int activeMatches = 0;
    double totalEarned = 0.0;
    double co2Saved = 0.0;

    // Retrieve stats
    try (Connection conn = DBConnection.getConnection()) {
        // Total Listings
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM WASTE WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalListings = rs.getInt(1);
            }
        }
        // Active Matches
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM MATCHES WHERE industry_user_id = ? AND status IN ('PENDING', 'ACCEPTED')")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) activeMatches = rs.getInt(1);
            }
        }
        // Total Earned
        try (PreparedStatement ps = conn.prepareStatement("SELECT SUM(quantity_kg * price_per_kg) FROM WASTE WHERE user_id = ? AND status = 'SOLD'")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalEarned = rs.getDouble(1);
            }
        }
        // CO2 Saved
        try (PreparedStatement ps = conn.prepareStatement("SELECT SUM(co2_saved_kg) FROM MATCHES WHERE industry_user_id = ? AND status = 'ACCEPTED'")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) co2Saved = rs.getDouble(1);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    // Recent Listings
    WasteDAO wasteDAO = new WasteDAO();
    List<Waste> listings = wasteDAO.getByUserId(userId);
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar Navigation -->
        <div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
            <div class="position-sticky">
                <a class="nav-link active" href="industry-dashboard.jsp">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
                <a class="nav-link" href="add-waste.jsp">
                    <i class="bi bi-plus-circle"></i> Post Waste
                </a>
                <a class="nav-link" href="my-listings.jsp">
                    <i class="bi bi-list-task"></i> My Listings
                </a>
                <a class="nav-link" href="analytics">
                    <i class="bi bi-bar-chart"></i> Analytics
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
                    <p class="page-subtitle mb-0">Monitor your listings, active deals, and sustainability achievements.</p>
                </div>
                <a href="add-waste.jsp" class="btn btn-wl-primary text-white d-flex align-items-center gap-2">
                    <i class="bi bi-plus-circle"></i> Post New Waste
                </a>
            </div>

            <!-- Stats Bar -->
            <div class="row g-4 mb-5">
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value"><%= totalListings %></div>
                        <div class="stat-label">Total Listings</div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value"><%= activeMatches %></div>
                        <div class="stat-label">Active Matches</div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value">₹<%= String.format("%.2f", totalEarned) %></div>
                        <div class="stat-label">Total Earned</div>
                    </div>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-value"><%= String.format("%.1f", co2Saved) %> kg</div>
                        <div class="stat-label">CO₂ Offset Saved</div>
                    </div>
                </div>
            </div>

            <!-- Recent Listings Section -->
            <div class="card card-wl border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="fw-bold mb-0 text-success">Recent Waste Postings</h5>
                </div>
                <div class="card-body p-0">
                    <% if (listings.isEmpty()) { %>
                        <div class="text-center py-5">
                            <span class="fs-1">📦</span>
                            <h5 class="mt-3 text-muted">No waste listings posted yet</h5>
                            <a href="add-waste.jsp" class="btn btn-wl-outline btn-sm mt-2">Create Listing</a>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-4">Waste Type</th>
                                        <th>Category</th>
                                        <th>Quantity (kg)</th>
                                        <th>Price (per kg)</th>
                                        <th>Status</th>
                                        <th class="pe-4">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                    int count = 0;
                                    for (Waste w : listings) { 
                                        if (count++ >= 5) break; // limit to 5
                                        String badgeClass = "badge-status-available";
                                        if ("MATCHED".equalsIgnoreCase(w.getStatus())) badgeClass = "badge-status-matched";
                                        if ("SOLD".equalsIgnoreCase(w.getStatus())) badgeClass = "badge-status-sold";
                                    %>
                                        <tr>
                                            <td class="ps-4 fw-semibold"><%= w.getWasteType() %></td>
                                            <td><span class="badge-category"><%= w.getCategory() %></span></td>
                                            <td><%= w.getQuantityKg() %> kg</td>
                                            <td>₹<%= w.getPricePerKg() %></td>
                                            <td><span class="badge badge-category <%= badgeClass %>"><%= w.getStatus() %></span></td>
                                            <td class="pe-4">
                                                <div class="d-flex gap-2">
                                                    <% if ("AVAILABLE".equalsIgnoreCase(w.getStatus())) { %>
                                                        <form action="match" method="POST" class="d-inline">
                                                            <input type="hidden" name="wasteId" value="<%= w.getWasteId() %>">
                                                            <input type="hidden" name="radius" value="100"> <!-- Default 100km -->
                                                            <button type="submit" class="btn btn-sm btn-wl-primary text-white py-1 px-2.5">
                                                                Find Recycler Match
                                                            </button>
                                                        </form>
                                                    <% } %>
                                                    <a href="my-listings.jsp" class="btn btn-sm btn-outline-secondary py-1 px-2.5">View Details</a>
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
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
