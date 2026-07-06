<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=Admin+access+required");
        return;
    }

    // Populate attributes if accessed directly without going through servlet
    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    Integer totalListings = (Integer) request.getAttribute("totalListings");
    Integer totalMatches = (Integer) request.getAttribute("totalMatches");
    Double totalCo2Saved = (Double) request.getAttribute("totalCo2Saved");

    if (totalUsers == null) {
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM USERS");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalUsers = rs.getInt(1);
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM WASTE");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalListings = rs.getInt(1);
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM MATCHES");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalMatches = rs.getInt(1);
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT SUM(co2_saved_kg) FROM MATCHES WHERE status = 'ACCEPTED'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalCo2Saved = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    if (totalCo2Saved == null) totalCo2Saved = 0.0;
    request.setAttribute("activePage", "dashboard");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Admin Sidebar -->
        <jsp:include page="includes/admin-sidebar.jsp" />

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">Admin Dashboard</h1>
                <p class="page-subtitle">Oversee user activities, listing moderations, transactions, and ecological statistics.</p>
            </div>

            <!-- Stats Grid -->
            <div class="row g-4 mb-5">
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="fs-2 mb-1">👥</div>
                        <div class="stat-value text-success"><%= totalUsers %></div>
                        <div class="stat-label">Total Registered Users</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="fs-2 mb-1">📦</div>
                        <div class="stat-value text-success"><%= totalListings %></div>
                        <div class="stat-label">Total Waste Listings</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="fs-2 mb-1">🤝</div>
                        <div class="stat-value text-success"><%= totalMatches %></div>
                        <div class="stat-label">Total Matches Generated</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card text-center">
                        <div class="fs-2 mb-1">🌱</div>
                        <div class="stat-value text-success"><%= String.format("%.1f", totalCo2Saved) %> kg</div>
                        <div class="stat-label">Total CO₂ Saved Offsets</div>
                    </div>
                </div>
            </div>

            <!-- Chart Preview Card -->
            <div class="row">
                <div class="col-lg-8 mb-4">
                    <div class="card card-wl p-4 border border-light shadow-sm">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0 text-success"><i class="bi bi-bar-chart-fill"></i> Categorical Recycler Exchange Share</h5>
                            <a href="<%= request.getContextPath() %>/admin/category-report" class="btn btn-sm btn-wl-outline py-1">View Full Report</a>
                        </div>
                        <div style="height: 320px; position: relative;">
                            <canvas id="categoryChart"></canvas>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-4 mb-4">
                    <div class="card border border-light p-4 bg-light rounded-3 h-100">
                        <h5 class="fw-bold text-success mb-3"><i class="bi bi-shield-check"></i> Admin Operations Quick-Links</h5>
                        <div class="list-group list-group-flush bg-transparent mb-3">
                            <a href="<%= request.getContextPath() %>/admin/users" class="list-group-item list-group-item-action bg-transparent border-0 ps-0 text-dark small">
                                <i class="bi bi-people-fill text-success me-2"></i> Manage User Accounts & Status
                            </a>
                            <a href="<%= request.getContextPath() %>/admin/listings" class="list-group-item list-group-item-action bg-transparent border-0 ps-0 text-dark small">
                                <i class="bi bi-trash-fill text-success me-2"></i> Moderate Posted Listings & Flag Reports
                            </a>
                            <a href="<%= request.getContextPath() %>/admin/matches" class="list-group-item list-group-item-action bg-transparent border-0 ps-0 text-dark small">
                                <i class="bi bi-arrow-left-right text-success me-2"></i> Oversee and Update Trade Matches
                            </a>
                            <a href="<%= request.getContextPath() %>/admin-logs.jsp" class="list-group-item list-group-item-action bg-transparent border-0 ps-0 text-dark small">
                                <i class="bi bi-journal-text text-success me-2"></i> Inspect Platform System Audits
                            </a>
                        </div>
                        <hr class="my-3">
                        <h6 class="fw-bold text-dark mb-2"><i class="bi bi-gear-wide-connected"></i> Reviewer Demo Controls</h6>
                        <div class="d-grid gap-2">
                            <form action="<%= request.getContextPath() %>/admin/mock-generator" method="POST">
                                <input type="hidden" name="action" value="populate">
                                <button type="submit" class="btn btn-sm btn-wl-primary text-white w-100 py-1.5"><i class="bi bi-database-fill-add"></i> Populate Review Mock Data</button>
                            </form>
                            <form action="<%= request.getContextPath() %>/admin/mock-generator" method="POST" onsubmit="return confirm('Clean all database records back to brand new empty state?');">
                                <input type="hidden" name="action" value="reset">
                                <button type="submit" class="btn btn-sm btn-outline-danger w-100 py-1.5"><i class="bi bi-trash3-fill"></i> Reset to Empty State</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Load Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        fetch('<%= request.getContextPath() %>/admin/category-chart')
            .then(response => response.json())
            .then(data => {
                const categories = Object.keys(data);
                const recyclerData = {};

                // Find all unique recycler names
                categories.forEach(cat => {
                    data[cat].forEach(item => {
                        if (!recyclerData[item.companyName]) {
                            recyclerData[item.companyName] = {};
                        }
                        recyclerData[item.companyName][cat] = item.totalQuantityKg;
                    });
                });

                const recyclers = Object.keys(recyclerData);
                const colors = [
                    'rgba(29, 158, 117, 0.75)',  // Emerald Teal
                    'rgba(93, 202, 165, 0.75)',  // Mint Green
                    'rgba(239, 159, 39, 0.75)',   // Amber Gold
                    'rgba(15, 110, 86, 0.75)',   // Dark Forest Teal
                    'rgba(235, 87, 87, 0.75)',   // Coral Red
                    'rgba(86, 204, 242, 0.75)',  // Sky Blue
                    'rgba(155, 81, 224, 0.75)'   // Amethyst Purple
                ];

                const datasets = recyclers.map((rec, index) => {
                    const dataPoints = categories.map(cat => recyclerData[rec][cat] || 0);
                    return {
                        label: rec,
                        data: dataPoints,
                        backgroundColor: colors[index % colors.length],
                        borderColor: colors[index % colors.length].replace('0.7', '1'),
                        borderWidth: 1
                    };
                });

                const ctx = document.getElementById('categoryChart').getContext('2d');
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: categories,
                        datasets: datasets
                    },
                    options: {
                        indexAxis: 'y',
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            x: {
                                stacked: true,
                                title: {
                                    display: true,
                                    text: 'Exchanged Quantity (kg)'
                                }
                            },
                            y: {
                                stacked: true
                            }
                        },
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    boxWidth: 12,
                                    font: { size: 10 }
                                }
                            }
                        }
                    }
                });
            })
            .catch(err => console.error("Error loading chart data:", err));
    });
</script>

<jsp:include page="includes/footer.jsp" />
