<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.model.Recycler" %>
<%@ page import="com.wastelink.dao.RecyclerDAO" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }
    int userId = user.getUserId();
    String role = user.getRole();

    Recycler recycler = null;
    if ("RECYCLER".equals(role)) {
        RecyclerDAO recyclerDAO = new RecyclerDAO();
        recycler = recyclerDAO.getByUserId(userId);
    }
    request.setAttribute("activePage", "profile");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid auto-locate">
    <div class="row">
        <% if ("ADMIN".equalsIgnoreCase(role)) { %>
            <jsp:include page="includes/admin-sidebar.jsp" />
        <% } else { %>
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
                    <a class="nav-link active" href="profile.jsp">
                        <i class="bi bi-person"></i> Profile
                    </a>
                    <hr class="text-white-50 my-3 mx-3">
                    <a class="nav-link text-warning" href="logout">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </div>
            </div>
        <% } %>

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">Manage Account Profile</h1>
                <p class="page-subtitle">Configure contact markers, business properties, and location anchors.</p>
            </div>

            <%
                String updated = request.getParameter("updated");
                if ("true".equals(updated)) {
            %>
                <div class="alert alert-success alert-dismissible fade show small" role="alert">
                    <i class="bi bi-check-circle-fill"></i> Account details updated successfully.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <div class="row">
                <div class="col-lg-8">
                    <div class="card card-wl p-4 border border-light shadow-sm mb-4">
                        <form action="profile" method="POST">
                            <!-- Geolocation inputs auto populated by wastelink.js if permission granted -->
                            <input type="hidden" id="latitude" name="latitude" value="<%= user.getLatitude() %>">
                            <input type="hidden" id="longitude" name="longitude" value="<%= user.getLongitude() %>">

                            <h5 class="fw-bold text-success mb-3 border-bottom pb-2">Business Contact Information</h5>
                            
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="fullName" class="form-label small text-muted fw-semibold">Representative Full Name</label>
                                    <input type="text" class="form-control rounded-3" id="fullName" name="fullName" value="<%= user.getFullName() %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="email" class="form-label small text-muted fw-semibold">Account Email (ReadOnly)</label>
                                    <input type="email" class="form-control rounded-3 bg-light text-muted" id="email" value="<%= user.getEmail() %>" readonly>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="companyName" class="form-label small text-muted fw-semibold">Company Name</label>
                                    <input type="text" class="form-control rounded-3" id="companyName" name="companyName" value="<%= user.getCompanyName() %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="phone" class="form-label small text-muted fw-semibold">Contact Phone Number</label>
                                    <input type="tel" class="form-control rounded-3" id="phone" name="phone" value="<%= user.getPhone() %>" required>
                                </div>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label for="city" class="form-label small text-muted fw-semibold">Office City</label>
                                    <input type="text" class="form-control rounded-3" id="city" name="city" value="<%= user.getCity() %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="state" class="form-label small text-muted fw-semibold">Office State</label>
                                    <input type="text" class="form-control rounded-3" id="state" name="state" value="<%= user.getState() %>" required>
                                </div>
                            </div>

                            <% if ("RECYCLER".equals(role)) { 
                                String cats = recycler != null ? recycler.getAcceptedCategories() : "";
                                if (cats == null) cats = "";
                            %>
                                <h5 class="fw-bold text-success mb-3 border-top pt-4 pb-2">Recycling Operational Parameters</h5>
                                
                                <div class="mb-3">
                                    <label class="form-label small text-muted fw-semibold d-block">Approved Categories (Select all that apply)</label>
                                    <div class="row g-2">
                                        <div class="col-6 col-sm-4">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="acceptedCategories" value="METAL" id="catMetal" <%= cats.contains("METAL") ? "checked" : "" %>>
                                                <label class="form-check-label small" for="catMetal">Metal By-products</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-4">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="acceptedCategories" value="PLASTIC" id="catPlastic" <%= cats.contains("PLASTIC") ? "checked" : "" %>>
                                                <label class="form-check-label small" for="catPlastic">Plastics & Polymers</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-4">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="acceptedCategories" value="PAPER" id="catPaper" <%= cats.contains("PAPER") ? "checked" : "" %>>
                                                <label class="form-check-label small" for="catPaper">Paper & Cardboard</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-4">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="acceptedCategories" value="CHEMICAL" id="catChemical" <%= cats.contains("CHEMICAL") ? "checked" : "" %>>
                                                <label class="form-check-label small" for="catChemical">Chemical Waste</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-4">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="acceptedCategories" value="ELECTRONIC" id="catElectronic" <%= cats.contains("ELECTRONIC") ? "checked" : "" %>>
                                                <label class="form-check-label small" for="catElectronic">Electronic Scrap</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-4">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="acceptedCategories" value="ORGANIC" id="catOrganic" <%= cats.contains("ORGANIC") ? "checked" : "" %>>
                                                <label class="form-check-label small" for="catOrganic">Organic Byproducts</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label for="capacity" class="form-label small text-muted fw-semibold">Monthly Recycling Capacity (kg)</label>
                                        <input type="number" step="0.1" class="form-control rounded-3" id="capacity" name="capacity" value="<%= recycler != null ? recycler.getCapacityKg() : 0.0 %>" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="certification" class="form-label small text-muted fw-semibold">ISO / Pollution Control Board Certificate Number</label>
                                        <input type="text" class="form-control rounded-3" id="certification" name="certification" value="<%= recycler != null ? recycler.getCertification() : "" %>" placeholder="e.g. ISO-14001, KSPCB-REG-2025" required>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label for="bio" class="form-label small text-muted fw-semibold">Company Profile Bio</label>
                                    <textarea class="form-control rounded-3" id="bio" name="bio" rows="3" placeholder="Brief details about your facilities, recycling methodology, or trade policies..."><%= recycler != null ? recycler.getBio() : "" %></textarea>
                                </div>
                            <% } %>

                            <button type="submit" class="btn btn-wl-primary text-white px-4">Update Account Details</button>
                        </form>
                    </div>
                </div>

                <div class="col-lg-4">
                    <!-- Geolocation coordinates summary card -->
                    <div class="card border border-light p-4 bg-light rounded-3 mb-4 text-center">
                        <h5 class="fw-bold text-success mb-2"><i class="bi bi-geo-fill"></i> Location Anchors</h5>
                        <p class="small text-muted mb-3">Your registered geolocation parameters are verified for distance-based matching algorithms.</p>
                        <div class="d-flex justify-content-center gap-4 text-dark mb-3">
                            <div>
                                <span class="d-block small text-muted">Latitude</span>
                                <strong class="small"><%= String.format("%.4f", user.getLatitude()) %></strong>
                            </div>
                            <div>
                                <span class="d-block small text-muted">Longitude</span>
                                <strong class="small"><%= String.format("%.4f", user.getLongitude()) %></strong>
                            </div>
                        </div>
                        <button type="button" class="btn btn-sm btn-wl-outline w-100" onclick="initGeolocation()">
                            <i class="bi bi-arrow-repeat"></i> Update Geolocations
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
