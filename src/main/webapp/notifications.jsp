<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }

    List<String[]> notifications = (List<String[]>) request.getAttribute("notifications");
    if (notifications == null) {
        response.sendRedirect("notifications");
        return;
    }
    request.setAttribute("activePage", "notifications");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
            <jsp:include page="includes/admin-sidebar.jsp" />
        <% } else { %>
            <!-- Sidebar Navigation -->
            <div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
                <div class="position-sticky">
                    <% if ("INDUSTRY".equalsIgnoreCase(user.getRole())) { %>
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
                    <a class="nav-link active" href="notifications">
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
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="page-title">System Notifications</h1>
                    <p class="page-subtitle mb-0">Track match request logs, user accept actions, and trade updates.</p>
                </div>
                
                <% if (!notifications.isEmpty()) { %>
                    <form action="notifications" method="POST" class="d-inline">
                        <input type="hidden" name="action" value="markRead">
                        <button type="submit" class="btn btn-wl-outline btn-sm d-flex align-items-center gap-1">
                            <i class="bi bi-check-all"></i> Mark All as Read
                        </button>
                    </form>
                <% } %>
            </div>

            <div class="card card-wl border-0">
                <div class="card-body p-0">
                    <% if (notifications.isEmpty()) { %>
                        <div class="text-center py-5">
                            <span class="fs-1">🔔</span>
                            <h5 class="mt-3 text-muted">No notifications found</h5>
                            <p class="small text-muted mb-0">You're all caught up! Matching alerts will show up here.</p>
                        </div>
                    <% } else { %>
                        <div class="list-group list-group-flush rounded-3">
                            <% for (String[] n : notifications) { 
                                boolean isUnread = !"true".equalsIgnoreCase(n[2]);
                                String unreadClass = isUnread ? "unread" : "";
                            %>
                                <div class="notif-item <%= unreadClass %> d-flex align-items-center justify-content-between">
                                    <div class="d-flex align-items-center">
                                        <% if (isUnread) { %>
                                            <span class="notif-dot"></span>
                                        <% } else { %>
                                            <span class="me-3 text-muted" style="width: 10px; display: inline-block;">&bull;</span>
                                        <% } %>
                                        <div class="text-dark small"><%= n[1] %></div>
                                    </div>
                                    <div class="small text-muted ps-3" style="font-size:0.75rem;"><%= n[3] %></div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
