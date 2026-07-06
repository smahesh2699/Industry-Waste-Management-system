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
                            <a href="#" class="small text-decoration-none text-success" data-bs-toggle="modal" data-bs-target="#forgotModal">Forgot Password?</a>
                        </div>
                        <div class="input-group">
                            <input type="password" class="form-control rounded-start-3" id="password" name="password" required placeholder="Enter password">
                            <button class="btn btn-outline-secondary rounded-end-3" type="button" id="toggleLoginPass" onclick="togglePass('password','toggleLoginPass')">
                                <i class="bi bi-eye" id="toggleLoginPassIcon"></i>
                            </button>
                        </div>
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

<!-- Forgot Password Modal -->
<div class="modal fade" id="forgotModal" tabindex="-1" aria-labelledby="forgotModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content rounded-4 border-0 shadow">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title fw-bold" id="forgotModalLabel"><i class="bi bi-shield-lock text-success me-2"></i>Reset Your Password</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body pt-2">
        <p class="text-muted small mb-3">To reset your password, please contact the WasteLink platform administrator with your registered email address.</p>
        <div class="alert alert-success py-2 small rounded-3 mb-2">
          <i class="bi bi-envelope-fill me-1"></i> <strong>Admin Email:</strong> admin@wastelink.com
        </div>
        <p class="text-muted" style="font-size:0.78rem;">Include your registered company email and full name. The admin will verify your identity and reset your password within 24 hours.</p>
      </div>
      <div class="modal-footer border-0 pt-0">
        <button type="button" class="btn btn-wl-primary text-white px-4" data-bs-dismiss="modal">Got it</button>
      </div>
    </div>
  </div>
</div>

<script>
function togglePass(fieldId, btnId) {
    var field = document.getElementById(fieldId);
    var icon = document.getElementById(btnId + 'Icon');
    if (field.type === 'password') {
        field.type = 'text';
        icon.classList.replace('bi-eye', 'bi-eye-slash');
    } else {
        field.type = 'password';
        icon.classList.replace('bi-eye-slash', 'bi-eye');
    }
}
</script>

<jsp:include page="includes/footer.jsp" />
