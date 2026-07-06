<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%
    User indexUser = (User) session.getAttribute("user");
    String primaryLink = "login.jsp";
    String primaryText = "Post Waste Listing";
    String secondaryLink = "register.jsp?role=RECYCLER";
    String secondaryText = "Find Recyclables";
    
    if (indexUser != null) {
        if ("ADMIN".equals(indexUser.getRole())) {
            primaryLink = "admin-dashboard.jsp";
            primaryText = "Go to Admin Dashboard";
            secondaryLink = "logout";
            secondaryText = "Logout";
        } else if ("INDUSTRY".equals(indexUser.getRole())) {
            primaryLink = "add-waste.jsp";
            primaryText = "Post Waste Listing";
            secondaryLink = "industry-dashboard.jsp";
            secondaryText = "Go to Dashboard";
        } else {
            primaryLink = "marketplace";
            primaryText = "Browse Marketplace";
            secondaryLink = "recycler-dashboard.jsp";
            secondaryText = "Go to Dashboard";
        }
    }
%>
<jsp:include page="includes/navbar.jsp" />

<!-- Hero Section -->
<div class="hero-wl">
    <div class="container text-center py-5">
        <h1 class="display-4 fw-extrabold mb-3 text-white">Transform Industrial Waste into Value</h1>
        <p class="lead mb-4 mx-auto text-white-50" style="max-width: 700px;">
            Connecting waste producers with certified recycling buyers. Trade metals, plastics, chemical by-products, and organics via geolocation matching.
        </p>
        <div class="d-flex justify-content-center gap-3">
            <a href="<%= request.getContextPath() %>/<%= primaryLink %>" class="btn btn-light btn-lg px-4 fs-6 fw-semibold text-success"><%= primaryText %></a>
            <a href="<%= request.getContextPath() %>/<%= secondaryLink %>" class="btn btn-wl-primary btn-lg px-4 fs-6 fw-semibold text-white"><%= secondaryText %></a>
        </div>
    </div>
</div>

<!-- Stats Bar -->
<div class="bg-white py-4 border-bottom border-top border-light shadow-sm">
    <div class="container">
        <div class="row text-center text-dark">
            <div class="col-md-3 border-end">
                <h3 class="fw-bold text-success mb-1">500+</h3>
                <span class="text-muted small uppercase fw-semibold">Active Industries</span>
            </div>
            <div class="col-md-3 border-end">
                <h3 class="fw-bold text-success mb-1">200+</h3>
                <span class="text-muted small uppercase fw-semibold">Certified Recyclers</span>
            </div>
            <div class="col-md-3 border-end">
                <h3 class="fw-bold text-success mb-1">10,000 Tons</h3>
                <span class="text-muted small uppercase fw-semibold">Waste Diverted</span>
            </div>
            <div class="col-md-3">
                <h3 class="fw-bold text-success mb-1">₹2Cr+</h3>
                <span class="text-muted small uppercase fw-semibold">Value Exchanged</span>
            </div>
        </div>
    </div>
</div>

<!-- How It Works -->
<div id="how-it-works" class="container py-5 my-3">
    <div class="text-center mb-5">
        <h2 class="fw-bold text-success">How WasteLink Works</h2>
        <p class="text-muted">Three simple steps to close the loop on industrial byproducts</p>
    </div>
    <div class="row g-4">
        <div class="col-md-4">
            <div class="card card-wl h-100 text-center p-4">
                <div class="fs-1 text-success mb-3">📝</div>
                <h4 class="fw-bold mb-2">1. Post Your Waste</h4>
                <p class="text-muted small mb-0">Industries post waste details including categories, quantities, locations, and pricing.</p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card card-wl h-100 text-center p-4">
                <div class="fs-1 text-success mb-3">🔄</div>
                <h4 class="fw-bold mb-2">2. Get Matched</h4>
                <p class="text-muted small mb-0">Our geolocation matching system checks category permissions and locates nearby recyclers.</p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card card-wl h-100 text-center p-4">
                <div class="fs-1 text-success mb-3">💰</div>
                <h4 class="fw-bold mb-2">3. Exchange &amp; Earn</h4>
                <p class="text-muted small mb-0">Review profit estimations, complete transactions, and trace carbon footprint savings.</p>
            </div>
        </div>
    </div>
</div>

<!-- Features Section -->
<div id="features" class="bg-light py-5 border-top border-bottom">
    <div class="container py-3">
        <div class="text-center mb-5">
            <h2 class="fw-bold text-success">Advanced System Features</h2>
            <p class="text-muted">A full-featured B2B circular marketplace built with state-of-the-art tech</p>
        </div>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="p-4 bg-white rounded-3 border h-100">
                    <h5 class="fw-bold text-success mb-3"><i class="bi bi-geo-alt"></i> Geolocation Matching</h5>
                    <p class="text-muted small mb-0">Automated distance calculation using the Haversine formula ensuring local recycling partners.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4 bg-white rounded-3 border h-100">
                    <h5 class="fw-bold text-success mb-3"><i class="bi bi-graph-up-arrow"></i> Profit Estimator</h5>
                    <p class="text-muted small mb-0">Estimates margins dynamically based on transportation overhead and handling fee calculations.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4 bg-white rounded-3 border h-100">
                    <h5 class="fw-bold text-success mb-3"><i class="bi bi-tree"></i> Eco Impact Tracking</h5>
                    <p class="text-muted small mb-0">Logs direct CO₂ offsets for recycled metal, plastic, paper, and electronics.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4 bg-white rounded-3 border h-100">
                    <h5 class="fw-bold text-success mb-3"><i class="bi bi-bell"></i> Instant Alerts</h5>
                    <p class="text-muted small mb-0">Instant notification logs inform buyers and sellers of matches and bids.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4 bg-white rounded-3 border h-100">
                    <h5 class="fw-bold text-success mb-3"><i class="bi bi-pie-chart"></i> Visual Analytics</h5>
                    <p class="text-muted small mb-0">Interactive dashboards with Chart.js display categories, statuses, and monthly transactions.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4 bg-white rounded-3 border h-100">
                    <h5 class="fw-bold text-success mb-3"><i class="bi bi-shield-check"></i> Verified Certifications</h5>
                    <p class="text-muted small mb-0">Strict role filtering limits trades to verified recyclers matching certified categories.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
