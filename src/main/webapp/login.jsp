<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/navbar.jsp" />

<div class="container py-5 my-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card card-wl p-4 border border-light shadow">
                <div class="text-center mb-4">
                    <span class="fs-1">🌿</span>
                    <h3 class="fw-bold mt-2">Log In to WasteLink</h3>
                    <p class="text-muted small">Connect, trade, and track industrial waste exchange</p>
                </div>

                <%
                    String error = request.getParameter("error");
                    String registered = request.getParameter("registered");
                    String logout = request.getParameter("logout");
                    if (error != null) {
                %>
                    <div class="alert alert-danger py-2 small" role="alert">
                        <i class="bi bi-exclamation-triangle-fill"></i> <%= error %>
                    </div>
                <% } %>

                <% if (registered != null) { %>
                    <div class="alert alert-success py-2 small" role="alert">
                        <i class="bi bi-check-circle-fill"></i> Registration successful! Please log in.
                    </div>
                <% } %>

                <% if (logout != null) { %>
                    <div class="alert alert-info py-2 small" role="alert">
                        <i class="bi bi-info-circle-fill"></i> You have logged out successfully.
                    </div>
                <% } %>

                <form action="login" method="POST">
                    <div class="mb-3">
                        <label for="email" class="form-label small fw-semibold text-muted">Email Address</label>
                        <input type="email" class="form-control rounded-3" id="email" name="email" required placeholder="name@company.com">
                    </div>
                    <div class="mb-4">
                        <div class="d-flex justify-content-between">
                            <label for="password" class="form-label small fw-semibold text-muted">Password</label>
                            <a href="#" class="small text-decoration-none text-success">Forgot?</a>
                        </div>
                        <input type="password" class="form-control rounded-3" id="password" name="password" required placeholder="Enter password">
                    </div>
                    
                    <button type="submit" class="btn btn-wl-primary w-100 py-2.5 mb-3 text-white">Log In</button>
                </form>

                <div class="text-center mt-3">
                    <p class="small text-muted mb-0">Don't have an account? <a href="register.jsp" class="text-success fw-bold text-decoration-none">Register Here</a></p>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
