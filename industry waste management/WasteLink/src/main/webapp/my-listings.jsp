<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.model.Waste" %>
<%@ page import="com.wastelink.dao.WasteDAO" %>
<%@ page import="com.wastelink.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"INDUSTRY".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }
    int userId = user.getUserId();

    WasteDAO wasteDAO = new WasteDAO();
    List<Waste> listings = wasteDAO.getByUserId(userId);
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar Navigation -->
        <div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
            <div class="position-sticky">
                <a class="nav-link" href="industry-dashboard.jsp">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
                <a class="nav-link" href="add-waste.jsp">
                    <i class="bi bi-plus-circle"></i> Post Waste
                </a>
                <a class="nav-link active" href="my-listings.jsp">
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
                    <h1 class="page-title">My Waste Listings</h1>
                    <p class="page-subtitle">Manage listings, run geolocational matching, and finalize exchanges.</p>
                </div>
                <a href="add-waste.jsp" class="btn btn-wl-primary text-white d-flex align-items-center gap-2">
                    <i class="bi bi-plus-circle"></i> Add New Listing
                </a>
            </div>

            <%
                String added = request.getParameter("added");
                String deleted = request.getParameter("deleted");
                String updated = request.getParameter("updated");
                String matches = request.getParameter("matches");
                if ("true".equals(added)) {
            %>
                <div class="alert alert-success alert-dismissible fade show small" role="alert">
                    <i class="bi bi-check-circle-fill"></i> Listing published successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if ("true".equals(deleted)) { %>
                <div class="alert alert-warning alert-dismissible fade show small" role="alert">
                    <i class="bi bi-trash-fill"></i> Listing deleted.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if ("true".equals(updated)) { %>
                <div class="alert alert-success alert-dismissible fade show small" role="alert">
                    <i class="bi bi-check-circle-fill"></i> Listing updated.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if (matches != null) { %>
                <div class="alert alert-info alert-dismissible fade show small" role="alert">
                    <i class="bi bi-info-circle-fill"></i> Geolocation algorithm complete. Found <strong><%= matches %></strong> matching recyclers within radius!
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <div class="row g-4">
                <% if (listings.isEmpty()) { %>
                    <div class="col-12">
                        <div class="card card-wl p-5 text-center">
                            <span class="fs-1">📦</span>
                            <h4 class="fw-bold mt-3">You haven't listed any waste materials yet.</h4>
                            <p class="text-muted small">Begin by publishing a new material listing.</p>
                            <a href="add-waste.jsp" class="btn btn-wl-primary btn-sm mx-auto mt-2 text-white">Create Listing</a>
                        </div>
                    </div>
                <% } else { 
                    for (Waste w : listings) {
                        String badgeClass = "badge-status-available";
                        if ("MATCHED".equalsIgnoreCase(w.getStatus())) badgeClass = "badge-status-matched";
                        if ("SOLD".equalsIgnoreCase(w.getStatus())) badgeClass = "badge-status-sold";
                %>
                    <div class="col-12">
                        <div class="card card-wl border border-light p-4 shadow-sm">
                            <div class="row align-items-center border-bottom pb-3 mb-3">
                                <div class="col-md-6">
                                    <div class="d-flex align-items-center gap-3">
                                        <h4 class="fw-bold text-success mb-0"><%= w.getWasteType() %></h4>
                                        <span class="badge badge-category <%= badgeClass %>"><%= w.getStatus() %></span>
                                    </div>
                                    <div class="text-muted small mt-1">
                                        Category: <span class="badge-category"><%= w.getCategory() %></span> | Location: <%= w.getLocation() %>
                                    </div>
                                </div>
                                <div class="col-md-6 text-md-end mt-2 mt-md-0">
                                    <span class="text-muted small me-3">Quantity: <strong><%= w.getQuantityKg() %> kg</strong></span>
                                    <span class="text-success fw-bold fs-5">₹<%= w.getPricePerKg() %>/kg</span>
                                </div>
                            </div>

                            <p class="text-muted small"><%= w.getDescription() != null ? w.getDescription() : "No description provided." %></p>

                            <!-- Inline Match Listing -->
                            <div class="bg-light p-3 rounded-3 mt-3">
                                <h6 class="fw-bold text-secondary mb-2 d-flex justify-content-between align-items-center">
                                    <span>Matches for this listing</span>
                                    <% if ("AVAILABLE".equalsIgnoreCase(w.getStatus())) { %>
                                        <form action="match" method="POST" class="d-inline-flex gap-2 align-items-center">
                                            <input type="hidden" name="wasteId" value="<%= w.getWasteId() %>">
                                            <select name="radius" class="form-select form-select-sm py-0.5 rounded-2" style="width: auto;">
                                                <option value="50">50 km</option>
                                                <option value="100" selected>100 km</option>
                                                <option value="250">250 km</option>
                                                <option value="500">500 km</option>
                                            </select>
                                            <button type="submit" class="btn btn-wl-primary btn-sm py-0.5 px-2 text-white">Find Recycler Match</button>
                                        </form>
                                    <% } %>
                                </h6>

                                <%
                                    List<String[]> matchesList = new ArrayList<>();
                                    try (Connection conn = DBConnection.getConnection();
                                         PreparedStatement ps = conn.prepareStatement("SELECT m.match_id, m.status, m.profit_estimate, m.co2_saved_kg, u.company_name as recycler_company, u.phone as recycler_phone, u.email as recycler_email FROM MATCHES m JOIN USERS u ON m.recycler_id = u.user_id WHERE m.waste_id = ?")) {
                                        ps.setInt(1, w.getWasteId());
                                        try (ResultSet rs = ps.executeQuery()) {
                                            while (rs.next()) {
                                                matchesList.add(new String[]{
                                                    String.valueOf(rs.getInt("match_id")),
                                                    rs.getString("recycler_company"),
                                                    String.format("%.2f", rs.getDouble("profit_estimate")),
                                                    String.format("%.1f", rs.getDouble("co2_saved_kg")),
                                                    rs.getString("status"),
                                                    rs.getString("recycler_phone"),
                                                    rs.getString("recycler_email")
                                                });
                                            }
                                        }
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }

                                    if (matchesList.isEmpty()) {
                                %>
                                    <p class="small text-muted mb-0">No matches generated yet. Run the matching algorithm above.</p>
                                <% } else { %>
                                    <div class="table-responsive">
                                        <table class="table table-sm table-borderless align-middle mb-0" style="font-size:0.85rem;">
                                            <thead>
                                                <tr class="text-secondary small">
                                                    <th>Recycler Company</th>
                                                    <th>Estimated Net Margin</th>
                                                    <th>CO₂ Saved</th>
                                                    <th>Status</th>
                                                    <th>Contact details</th>
                                                    <% if (!"SOLD".equalsIgnoreCase(w.getStatus())) { %>
                                                        <th>Action</th>
                                                    <% } %>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% for (String[] m : matchesList) { 
                                                    String matchBadge = "bg-warning-subtle text-warning";
                                                    if ("ACCEPTED".equalsIgnoreCase(m[4])) matchBadge = "bg-success-subtle text-success";
                                                    if ("REJECTED".equalsIgnoreCase(m[4])) matchBadge = "bg-danger-subtle text-danger";
                                                    if ("COMPLETED".equalsIgnoreCase(m[4])) matchBadge = "bg-info-subtle text-info";
                                                %>
                                                    <tr>
                                                        <td class="fw-semibold"><%= m[1] %></td>
                                                        <td class="text-success fw-bold">₹<%= m[2] %></td>
                                                        <td><%= m[3] %> kg</td>
                                                        <td><span class="badge <%= matchBadge %>"><%= m[4] %></span></td>
                                                        <td>
                                                            <% if ("ACCEPTED".equalsIgnoreCase(m[4])) { %>
                                                                <a href="mailto:<%= m[6] %>" class="text-success"><%= m[6] %></a> | <%= m[5] %>
                                                            <% } else { %>
                                                                <span class="text-muted italic">Unlocked on Acceptance</span>
                                                            <% } %>
                                                        </td>
                                                        <% if (!"SOLD".equalsIgnoreCase(w.getStatus())) { %>
                                                            <td>
                                                                <% if ("ACCEPTED".equalsIgnoreCase(m[4])) { %>
                                                                    <form action="manage-waste" method="POST" class="d-inline">
                                                                        <input type="hidden" name="wasteId" value="<%= w.getWasteId() %>">
                                                                        <input type="hidden" name="status" value="SOLD">
                                                                        <input type="hidden" name="wasteType" value="<%= w.getWasteType() %>">
                                                                        <input type="hidden" name="category" value="<%= w.getCategory() %>">
                                                                        <input type="hidden" name="quantity" value="<%= w.getQuantityKg() %>">
                                                                        <input type="hidden" name="price" value="<%= w.getPricePerKg() %>">
                                                                        <input type="hidden" name="location" value="<%= w.getLocation() %>">
                                                                        <button type="submit" class="btn btn-sm btn-wl-primary text-white py-0.5 px-2">
                                                                            Mark Sold
                                                                        </button>
                                                                    </form>
                                                                <% } %>
                                                            </td>
                                                        <% } %>
                                                    </tr>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                <% } %>
                            </div>

                            <!-- Operations -->
                            <div class="d-flex justify-content-end gap-2 mt-3 pt-2 border-top">
                                <a href="manage-waste?action=delete&wasteId=<%= w.getWasteId() %>" class="btn btn-sm btn-outline-danger py-1" onclick="return confirm('Are you sure you want to delete this listing?');">Delete Listing</a>
                            </div>
                        </div>
                    </div>
                <% } } %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
