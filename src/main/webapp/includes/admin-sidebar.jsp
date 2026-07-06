<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
    String ctx = request.getContextPath();
%>
<div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
    <div class="position-sticky">
        <a class="nav-link <%= "dashboard".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/admin-dashboard.jsp">
            <i class="bi bi-speedometer2"></i> Dashboard
        </a>
        <a class="nav-link <%= "users".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/admin/users">
            <i class="bi bi-people"></i> Users
        </a>
        <a class="nav-link <%= "listings".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/admin/listings">
            <i class="bi bi-list-task"></i> Listings
        </a>
        <a class="nav-link <%= "matches".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/admin/matches">
            <i class="bi bi-arrow-left-right"></i> Matches
        </a>
        <a class="nav-link <%= "category-report".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/admin/category-report">
            <i class="bi bi-bar-chart-line"></i> Category Report
        </a>
        <a class="nav-link <%= "logs".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/admin-logs.jsp">
            <i class="bi bi-journal-text"></i> Audit Logs
        </a>
        <a class="nav-link <%= "leaderboard".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/leaderboard">
            <i class="bi bi-award"></i> Leaderboard
        </a>
        <a class="nav-link <%= "profile".equals(activePage) ? "active" : "" %>" href="<%= ctx %>/profile.jsp">
            <i class="bi bi-person"></i> Profile
        </a>
        <hr class="text-white-50 my-3 mx-3">
        <a class="nav-link text-warning" href="<%= ctx %>/logout">
            <i class="bi bi-box-arrow-right"></i> Logout
        </a>
    </div>
</div>
