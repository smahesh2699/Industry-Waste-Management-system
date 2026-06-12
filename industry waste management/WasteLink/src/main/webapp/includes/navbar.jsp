<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.dao.MatchDAO" %>
<%
    User currUser = (User) session.getAttribute("user");
    int unreadCount = 0;
    if (currUser != null) {
        MatchDAO matchDAO = new MatchDAO();
        unreadCount = matchDAO.getUnreadNotificationsCount(currUser.getUserId());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Google Fonts Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom styling -->
    <link href="css/wastelink.css" rel="stylesheet">
    <!-- Javascript -->
    <script src="js/wastelink.js" defer></script>
    <title>WasteLink - Smart Waste Exchange</title>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark navbar-wl sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2" href="index.jsp">
            <span class="fs-4">🌿</span> <strong>WasteLink</strong>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarText" aria-controls="navbarText" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarText">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <% if (currUser == null) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="index.jsp#how-it-works">How It Works</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index.jsp#features">Features</a>
                    </li>
                <% } else { 
                    if ("INDUSTRY".equals(currUser.getRole())) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="industry-dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="add-waste.jsp"><i class="bi bi-plus-circle"></i> Post Waste</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="my-listings.jsp"><i class="bi bi-list-task"></i> My Listings</a>
                        </li>
                    <% } else { %>
                        <li class="nav-item">
                            <a class="nav-link" href="recycler-dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="marketplace"><i class="bi bi-shop"></i> Marketplace</a>
                        </li>
                    <% } %>
                    <li class="nav-item">
                        <a class="nav-link" href="analytics"><i class="bi bi-bar-chart"></i> Analytics</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="profile.jsp"><i class="bi bi-person"></i> Profile</a>
                    </li>
                <% } %>
            </ul>
            
            <div class="d-flex align-items-center gap-3">
                <% if (currUser == null) { %>
                    <a href="login.jsp" class="btn btn-outline-light btn-sm px-3 rounded-pill">Log In</a>
                    <a href="register.jsp" class="btn btn-wl-primary btn-sm px-3 rounded-pill text-white" style="box-shadow:none;">Register</a>
                <% } else { %>
                    <!-- Notification Bell with Red Badge -->
                    <a href="notifications" class="text-white position-relative fs-5 me-2">
                        <i class="bi bi-bell"></i>
                        <% if (unreadCount > 0) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 0.65rem; padding: 0.25em 0.5em;">
                                <%= unreadCount %>
                            </span>
                        <% } %>
                    </a>
                    
                    <span class="text-white-50 small me-2 d-none d-md-inline">
                        <%= currUser.getCompanyName() != null ? currUser.getCompanyName() : currUser.getFullName() %>
                    </span>
                    <a href="logout" class="btn btn-sm btn-outline-light rounded-pill px-3">Logout</a>
                <% } %>
            </div>
        </div>
    </div>
</nav>
