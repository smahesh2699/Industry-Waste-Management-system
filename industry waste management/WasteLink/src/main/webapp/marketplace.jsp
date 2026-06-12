<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.model.Waste" %>
<%@ page import="com.wastelink.util.LocationUtil" %>
<%@ page import="com.wastelink.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"RECYCLER".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }

    List<Waste> listings = (List<Waste>) request.getAttribute("listings");
    if (listings == null) {
        // If accessed directly without going through the servlet, redirect
        response.sendRedirect("marketplace");
        return;
    }

    String searchQuery = request.getParameter("searchQuery");
    String category = request.getParameter("category");
    String maxPrice = request.getParameter("maxPrice");
    String maxDistance = request.getParameter("maxDistance");

    if (searchQuery == null) searchQuery = "";
    if (category == null) category = "ALL";
    if (maxPrice == null) maxPrice = "";
    if (maxDistance == null) maxDistance = "";
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar Navigation -->
        <div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
            <div class="position-sticky">
                <a class="nav-link" href="recycler-dashboard.jsp">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
                <a class="nav-link active" href="marketplace">
                    <i class="bi bi-shop"></i> Marketplace
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
            <div class="mb-4">
                <h1 class="page-title">Waste Material Marketplace</h1>
                <p class="page-subtitle">Search, filter, and buy available industrial byproducts listed near you.</p>
            </div>

            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                if (success != null) {
            %>
                <div class="alert alert-success alert-dismissible fade show small" role="alert">
                    <i class="bi bi-check-circle-fill"></i> <%= success %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i> <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <!-- Search and Filter Panel -->
            <div class="card card-wl p-4 border border-light shadow-sm mb-4">
                <form action="marketplace" method="GET">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label for="searchQuery" class="form-label small fw-semibold text-muted">Search Keyword</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control border-start-0 rounded-end-3" id="searchQuery" name="searchQuery" placeholder="e.g. scrap, HDPE, drums" value="<%= searchQuery %>">
                            </div>
                        </div>

                        <div class="col-md-3">
                            <label for="category" class="form-label small fw-semibold text-muted">Category</label>
                            <select class="form-select rounded-3" id="category" name="category">
                                <option value="ALL" <%= "ALL".equals(category) ? "selected" : "" %>>All Categories</option>
                                <option value="METAL" <%= "METAL".equals(category) ? "selected" : "" %>>Metal By-products</option>
                                <option value="PLASTIC" <%= "PLASTIC".equals(category) ? "selected" : "" %>>Plastics & Polymers</option>
                                <option value="PAPER" <%= "PAPER".equals(category) ? "selected" : "" %>>Paper & Cardboard</option>
                                <option value="CHEMICAL" <%= "CHEMICAL".equals(category) ? "selected" : "" %>>Chemical Waste</option>
                                <option value="ELECTRONIC" <%= "ELECTRONIC".equals(category) ? "selected" : "" %>>Electronic Scrap</option>
                                <option value="ORGANIC" <%= "ORGANIC".equals(category) ? "selected" : "" %>>Organic Byproducts</option>
                                <option value="OTHER" <%= "OTHER".equals(category) ? "selected" : "" %>>Other Materials</option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label for="maxPrice" class="form-label small fw-semibold text-muted">Max Price (₹/kg)</label>
                            <input type="number" step="0.01" class="form-control rounded-3" id="maxPrice" name="maxPrice" placeholder="e.g. 50" value="<%= maxPrice %>">
                        </div>

                        <div class="col-md-2">
                            <label for="maxDistance" class="form-label small fw-semibold text-muted">Max Distance (km)</label>
                            <input type="number" class="form-control rounded-3" id="maxDistance" name="maxDistance" placeholder="e.g. 150" value="<%= maxDistance %>">
                        </div>

                        <div class="col-md-1 d-flex align-items-end">
                            <button type="submit" class="btn btn-wl-primary w-100 py-2.5 text-white">Filter</button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Material Grid -->
            <div class="row g-4">
                <% if (listings.isEmpty()) { %>
                    <div class="col-12">
                        <div class="card card-wl p-5 text-center">
                            <span class="fs-1">🔍</span>
                            <h4 class="fw-bold mt-3">No matching listings found.</h4>
                            <p class="text-muted small">Try broadening your search keywords or increasing the distance threshold.</p>
                            <a href="marketplace" class="btn btn-wl-outline btn-sm mx-auto mt-2">Clear Filters</a>
                        </div>
                    </div>
                <% } else { 
                    for (Waste w : listings) {
                        double dist = LocationUtil.haversineDistance(
                            user.getLatitude(), user.getLongitude(),
                            w.getLatitude(), w.getLongitude()
                        );
                        
                        // Check if already requested a match to disable button
                        boolean alreadyMatched = false;
                        try (Connection conn = DBConnection.getConnection();
                             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM MATCHES WHERE waste_id = ? AND recycler_id = ?")) {
                            ps.setInt(1, w.getWasteId());
                            ps.setInt(2, user.getUserId());
                            try (ResultSet rs = ps.executeQuery()) {
                                if (rs.next() && rs.getInt(1) > 0) {
                                    alreadyMatched = true;
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                %>
                    <div class="col-md-6 col-lg-4">
                        <div class="card card-wl h-100 p-4 d-flex flex-column justify-content-between shadow-sm">
                            <div>
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <span class="badge-category"><%= w.getCategory() %></span>
                                    <span class="text-success small fw-bold"><i class="bi bi-geo-alt"></i> <%= String.format("%.1f", dist) %> km</span>
                                </div>
                                <h5 class="fw-bold text-success mt-1 mb-2"><%= w.getWasteType() %></h5>
                                <p class="text-muted small mb-3 text-truncate-3" style="font-size:0.85rem; height: 60px; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical;">
                                    <%= w.getDescription() != null ? w.getDescription() : "No description provided." %>
                                </p>
                            </div>

                            <div class="mt-3">
                                <div class="row align-items-center border-top pt-3 mb-3">
                                    <div class="col-6">
                                        <div class="small text-muted mb-0">Quantity</div>
                                        <div class="fw-bold text-dark"><%= w.getQuantityKg() %> kg</div>
                                    </div>
                                    <div class="col-6 text-end">
                                        <div class="small text-muted mb-0">Price per kg</div>
                                        <div class="fw-bold text-success fs-5">₹<%= w.getPricePerKg() %></div>
                                    </div>
                                </div>
                                <div class="text-muted small mb-3"><i class="bi bi-building"></i> Listed in: <%= w.getLocation() %></div>
                                
                                <% if (alreadyMatched) { %>
                                    <button class="btn btn-secondary btn-sm w-100 py-2 rounded-3" disabled>
                                        <i class="bi bi-check-circle-fill"></i> Match Requested
                                    </button>
                                <% } else { %>
                                    <form action="match-action" method="POST">
                                        <input type="hidden" name="action" value="request">
                                        <input type="hidden" name="wasteId" value="<%= w.getWasteId() %>">
                                        <button type="submit" class="btn btn-wl-primary btn-sm w-100 py-2 rounded-3 text-white">
                                            Request Exchange Match
                                        </button>
                                    </form>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <% } } %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
