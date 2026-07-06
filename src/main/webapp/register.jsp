<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/navbar.jsp" />

<div class="container py-5 auto-locate">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="card card-wl p-4 border border-light shadow">
                <div class="text-center mb-4">
                    <span class="fs-1">🌿</span>
                    <h3 class="fw-bold mt-2">Create WasteLink Account</h3>
                    <p class="text-muted small">Register to start listing, matching, and trading waste resources.</p>
                </div>

                <%
                    String error = request.getParameter("error");
                    if (error != null) {
                %>
                    <div class="alert alert-danger py-2 small" role="alert">
                        <i class="bi bi-exclamation-triangle-fill"></i> <%= error %>
                    </div>
                <% } %>

                <form action="register" method="POST" id="registerForm">
                    <!-- Geolocation coordinates (Auto filled by script) -->
                    <input type="hidden" id="latitude" name="latitude" value="12.9716">
                    <input type="hidden" id="longitude" name="longitude" value="77.5946">

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label for="fullName" class="form-label small fw-semibold text-muted">Full Name</label>
                            <input type="text" class="form-control rounded-3" id="fullName" name="fullName" required placeholder="John Doe">
                        </div>
                        <div class="col-md-6">
                            <label for="email" class="form-label small fw-semibold text-muted">Email Address</label>
                            <input type="email" class="form-control rounded-3" id="email" name="email" required placeholder="john@company.com">
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label for="password" class="form-label small fw-semibold text-muted">Password</label>
                            <div class="input-group">
                                <input type="password" class="form-control rounded-start-3" id="password" name="password" required placeholder="Minimum 6 characters">
                                <button class="btn btn-outline-secondary rounded-end-3" type="button" id="toggleRegPass" onclick="togglePass('password','toggleRegPass')">
                                    <i class="bi bi-eye" id="toggleRegPassIcon"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label for="confirmPassword" class="form-label small fw-semibold text-muted">Confirm Password</label>
                            <div class="input-group">
                                <input type="password" class="form-control rounded-start-3" id="confirmPassword" required placeholder="Repeat password">
                                <button class="btn btn-outline-secondary rounded-end-3" type="button" id="toggleConfPass" onclick="togglePass('confirmPassword','toggleConfPass')">
                                    <i class="bi bi-eye" id="toggleConfPassIcon"></i>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Role Selector -->
                    <div class="mb-4">
                        <label class="form-label small fw-semibold text-muted d-block">Register As</label>
                        <div class="row g-3">
                            <div class="col-6">
                                <input type="radio" class="btn-check" name="role" id="roleIndustry" value="INDUSTRY" checked required>
                                <label class="btn btn-outline-success w-100 py-3 rounded-3" for="roleIndustry">
                                    <div class="fs-4 mb-1">🏭</div>
                                    <strong>Industry / Seller</strong>
                                    <div class="small text-muted" style="font-size: 0.75rem;">Generate and list industrial waste</div>
                                </label>
                            </div>
                            <div class="col-6">
                                <input type="radio" class="btn-check" name="role" id="roleRecycler" value="RECYCLER" required>
                                <label class="btn btn-outline-success w-100 py-3 rounded-3" for="roleRecycler">
                                    <div class="fs-4 mb-1">♻️</div>
                                    <strong>Recycler / Buyer</strong>
                                    <div class="small text-muted" style="font-size: 0.75rem;">Source materials and process waste</div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label for="companyName" class="form-label small fw-semibold text-muted">Company Name</label>
                            <input type="text" class="form-control rounded-3" id="companyName" name="companyName" required placeholder="Acme Corp India">
                        </div>
                        <div class="col-md-6">
                            <label for="phone" class="form-label small fw-semibold text-muted">Phone Number</label>
                            <input type="tel" class="form-control rounded-3" id="phone" name="phone" required placeholder="+91 98765 43210">
                        </div>
                    </div>

                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label for="city" class="form-label small fw-semibold text-muted">City</label>
                            <input type="text" class="form-control rounded-3" id="city" name="city" required placeholder="Bengaluru">
                        </div>
                        <div class="col-md-6">
                            <label for="state" class="form-label small fw-semibold text-muted">State</label>
                            <input type="text" class="form-control rounded-3" id="state" name="state" required placeholder="Karnataka">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-wl-primary w-100 py-2.5 mb-3 text-white">Create Account</button>
                </form>

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
                    document.getElementById('registerForm').addEventListener('submit', function(e) {
                        var pass = document.getElementById('password').value;
                        var conf = document.getElementById('confirmPassword').value;
                        if (pass !== conf) {
                            e.preventDefault();
                            alert("Passwords do not match!");
                        }
                    });
                </script>

                <div class="text-center mt-2">
                    <p class="small text-muted mb-0">Already have an account? <a href="login.jsp" class="text-success fw-bold text-decoration-none">Log In Here</a></p>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
