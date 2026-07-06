<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }
    String role = user.getRole();

    List<String[]> leaderboard = (List<String[]>) request.getAttribute("leaderboard");
    if (leaderboard == null) {
        response.sendRedirect("leaderboard");
        return;
    }
    request.setAttribute("activePage", "leaderboard");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
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
                        <a class="nav-link" href="match-requests.jsp">
                            <i class="bi bi-arrow-left-right"></i> Match Requests
                        </a>
                    <% } else { %>
                        <a class="nav-link" href="recycler-dashboard.jsp">
                            <i class="bi bi-speedometer2"></i> Dashboard
                        </a>
                        <a class="nav-link" href="marketplace">
                            <i class="bi bi-shop"></i> Marketplace
                        </a>
                        <a class="nav-link" href="match-requests.jsp">
                            <i class="bi bi-arrow-left-right"></i> Match Requests
                        </a>
                    <% } %>
                    <a class="nav-link" href="analytics">
                        <i class="bi bi-bar-chart"></i> Analytics
                    </a>
                    <a class="nav-link active" href="leaderboard">
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
        <% } %>

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">🌿 Green Sustainability Leaderboard</h1>
                <p class="page-subtitle">Celebrating our top industrial and recycling partners driving circular economy offsets.</p>
            </div>

            <!-- Milestone Explanation Board -->
            <div class="card border border-light p-4 bg-light rounded-3 mb-5 shadow-sm">
                <h5 class="fw-bold text-success mb-3"><i class="bi bi-award-fill"></i> Environmental Milestone Emblems</h5>
                <div class="row g-3 text-center">
                    <div class="col-sm-3 border-end">
                        <span class="fs-4">🏅</span>
                        <div class="fw-bold text-dark mt-1 small">Green Pioneer</div>
                        <span class="text-muted small" style="font-size:0.75rem;">1,000+ kg CO₂ saved</span>
                    </div>
                    <div class="col-sm-3 border-end">
                        <span class="fs-4">🥈</span>
                        <div class="fw-bold text-dark mt-1 small">Eco Champion</div>
                        <span class="text-muted small" style="font-size:0.75rem;">500+ kg CO₂ saved</span>
                    </div>
                    <div class="col-sm-3 border-end">
                        <span class="fs-4">🥉</span>
                        <div class="fw-bold text-dark mt-1 small">Carbon Warrior</div>
                        <span class="text-muted small" style="font-size:0.75rem;">100+ kg CO₂ saved</span>
                    </div>
                    <div class="col-sm-3">
                        <span class="fs-4">🌱</span>
                        <div class="fw-bold text-dark mt-1 small">Green Partner</div>
                        <span class="text-muted small" style="font-size:0.75rem;">Join active trades</span>
                    </div>
                </div>
            </div>

            <!-- Leaderboard Card -->
            <div class="card card-wl border-0 shadow-sm">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="fw-bold mb-0 text-success">Rankings &amp; Achievements</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-4" style="width: 100px;">Rank</th>
                                    <th>Company Name</th>
                                    <th>Partner Role</th>
                                    <th>Location</th>
                                    <th>Total CO₂ Offset</th>
                                    <th class="pe-4 text-end">Active Emblem</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                int rank = 1;
                                for (String[] comp : leaderboard) { 
                                    double co2 = Double.parseDouble(comp[4]);
                                    
                                    // Determine rank indicator
                                    String rankIndicator = String.valueOf(rank);
                                    if (rank == 1) rankIndicator = "🥇 1st";
                                    if (rank == 2) rankIndicator = "🥈 2nd";
                                    if (rank == 3) rankIndicator = "🥉 3rd";
                                    
                                    // Determine Badge
                                    String badge = "🌿 Green Partner";
                                    String badgeClass = "badge-status-available";
                                    if (co2 >= 1000) {
                                        badge = "🏅 Green Pioneer";
                                        badgeClass = "badge-status-sold";
                                    } else if (co2 >= 500) {
                                        badge = "🥈 Eco Champion";
                                        badgeClass = "badge-status-matched";
                                    } else if (co2 >= 100) {
                                        badge = "🥉 Carbon Warrior";
                                        badgeClass = "badge-status-matched";
                                    }
                                    
                                    // Highlight logged-in company
                                    String rowHighlight = "";
                                    if (Integer.parseInt(comp[0]) == user.getUserId()) {
                                        rowHighlight = "table-success fw-bold";
                                    }
                                %>
                                    <tr class="<%= rowHighlight %>">
                                        <td class="ps-4 fw-bold text-success"><%= rankIndicator %></td>
                                        <td>
                                            <%= comp[1] %>
                                            <% if (Integer.parseInt(comp[0]) == user.getUserId()) { %>
                                                <span class="badge bg-success ms-1" style="font-size:0.65rem;">You</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge-category" style="font-size:0.75rem;"><%= comp[2] %></span>
                                        </td>
                                        <td><%= comp[3] %></td>
                                        <td class="fw-bold text-success"><%= comp[4] %> kg</td>
                                        <td class="pe-4 text-end">
                                            <span class="badge badge-category <%= badgeClass %>"><%= badge %></span>
                                        </td>
                                    </tr>
                                <% 
                                    rank++;
                                } 
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
