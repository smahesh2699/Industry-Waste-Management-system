<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"INDUSTRY".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid auto-locate">
    <div class="row">
        <!-- Sidebar Navigation -->
        <div class="col-md-3 col-lg-2 px-0 sidebar d-none d-md-block">
            <div class="position-sticky">
                <a class="nav-link" href="industry-dashboard.jsp">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
                <a class="nav-link active" href="add-waste.jsp">
                    <i class="bi bi-plus-circle"></i> Post Waste
                </a>
                <a class="nav-link" href="my-listings.jsp">
                    <i class="bi bi-list-task"></i> My Listings
                </a>
                <a class="nav-link" href="match-requests.jsp">
                    <i class="bi bi-arrow-left-right"></i> Match Requests
                </a>
                <a class="nav-link" href="analytics">
                    <i class="bi bi-bar-chart"></i> Analytics
                </a>
                <a class="nav-link" href="leaderboard">
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

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">Post New Waste Listing</h1>
                <p class="page-subtitle">Publish details about your industrial byproducts to match with local certified buyers.</p>
            </div>

            <%
                String error = request.getParameter("error");
                if (error != null) {
            %>
                <div class="alert alert-danger py-2 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i> <%= error %>
                </div>
            <% } %>

            <div class="row">
                <div class="col-lg-8">
                    <div class="card card-wl p-4 border border-light shadow-sm">
                        <form action="add-waste" method="POST">
                            <!-- Hidden Coordinates Filled by wastelink.js -->
                            <input type="hidden" id="latitude" name="latitude" value="<%= user.getLatitude() %>">
                            <input type="hidden" id="longitude" name="longitude" value="<%= user.getLongitude() %>">

                            <div class="mb-3">
                                <label for="wasteType" class="form-label small fw-semibold text-muted">Waste Material Name / Type</label>
                                <input type="text" class="form-control rounded-3" id="wasteType" name="wasteType" required placeholder="e.g. High-Density Polyethylene Scrap">
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="category" class="form-label small fw-semibold text-muted">Material Category</label>
                                    <select class="form-select rounded-3" id="category" name="category" required>
                                        <option value="" disabled selected>Select Category</option>
                                        <option value="METAL">Metal By-products</option>
                                        <option value="PLASTIC">Plastics & Polymers</option>
                                        <option value="PAPER">Paper & Cardboard</option>
                                        <option value="CHEMICAL">Chemical Waste</option>
                                        <option value="ELECTRONIC">Electronic Scrap (E-Waste)</option>
                                        <option value="ORGANIC">Organic Byproducts</option>
                                        <option value="OTHER">Other Materials</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="location" class="form-label small fw-semibold text-muted">Pickup Location City/State</label>
                                    <input type="text" class="form-control rounded-3" id="location" name="location" required placeholder="e.g. Bengaluru, Karnataka" value="<%= user.getCity() != null ? user.getCity() + ", " + user.getState() : "" %>">
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="quantity" class="form-label small fw-semibold text-muted">Quantity (kg)</label>
                                    <div class="input-group">
                                        <input type="number" step="0.1" class="form-control rounded-3" id="quantity" name="quantity" required placeholder="e.g. 500">
                                        <span class="input-group-text bg-light rounded-end-3">kg</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label for="price" class="form-label small fw-semibold text-muted">Offered Price (per kg)</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light rounded-start-3">₹</span>
                                        <input type="number" step="0.01" class="form-control rounded-3" id="price" name="price" required placeholder="e.g. 15.00">
                                    </div>
                                    <div class="form-text text-muted small" style="font-size:0.75rem;">Set to 0 if offering material for free collection.</div>
                                    <div class="form-text text-success small fw-semibold mt-1" id="price-suggestion-box" style="display:none;"></div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label small fw-semibold text-muted">Material Description &amp; Details</label>
                                <textarea class="form-control rounded-3" id="description" name="description" rows="4" placeholder="Detail purity, dimensions, storage packaging, handling precautions, or other terms..."></textarea>
                            </div>

                            <div class="d-flex gap-3">
                                <button type="submit" class="btn btn-wl-primary text-white px-4">Publish Waste Listing</button>
                                <a href="industry-dashboard.jsp" class="btn btn-outline-secondary px-4 rounded-3">Cancel</a>
                            </div>
                        </form>
                    </div>
                </div>
                
                <div class="col-lg-4">
                    <div class="card border border-light p-4 bg-light rounded-3 mb-4">
                        <h5 class="fw-bold text-success mb-3"><i class="bi bi-info-circle"></i> Posting Guidelines</h5>
                        <ul class="small text-muted ps-3 mb-0">
                            <li class="mb-2">Verify quantities accurately before listing to avoid transaction discrepancies.</li>
                            <li class="mb-2">Categorize correctly: matching criteria relies on category approvals.</li>
                            <li class="mb-2">Specify standard contamination levels or chemical purities in the description.</li>
                            <li class="mb-2">The location is auto-detected via browser Geolocation; you can update the text name manually.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // ── Real-time field validation ──────────────────────────────────────
    function showError(fieldId, msg) {
        const field = document.getElementById(fieldId);
        field.classList.add('is-invalid');
        let fb = field.parentElement.querySelector('.invalid-feedback');
        if (!fb) { fb = document.createElement('div'); fb.className = 'invalid-feedback'; field.parentElement.appendChild(fb); }
        fb.textContent = msg;
    }
    function clearError(fieldId) {
        const field = document.getElementById(fieldId);
        field.classList.remove('is-invalid');
        field.classList.add('is-valid');
    }

    document.getElementById('wasteType').addEventListener('blur', function() {
        if (this.value.trim().length < 3) showError('wasteType', 'Please enter at least 3 characters for the material name.');
        else clearError('wasteType');
    });

    document.getElementById('quantity').addEventListener('blur', function() {
        if (!this.value || parseFloat(this.value) <= 0) showError('quantity', 'Quantity must be greater than 0 kg.');
        else clearError('quantity');
    });

    document.getElementById('price').addEventListener('blur', function() {
        if (this.value === '' || parseFloat(this.value) < 0) showError('price', 'Price cannot be negative.');
        else clearError('price');
    });

    // Prevent submit if any errors remain
    document.querySelector('form').addEventListener('submit', function(e) {
        let valid = true;
        const wasteType = document.getElementById('wasteType');
        const qty = document.getElementById('quantity');
        const price = document.getElementById('price');
        const cat = document.getElementById('category');

        if (wasteType.value.trim().length < 3) { showError('wasteType', 'Please enter at least 3 characters.'); valid = false; }
        if (!qty.value || parseFloat(qty.value) <= 0) { showError('quantity', 'Quantity must be greater than 0 kg.'); valid = false; }
        if (price.value === '' || parseFloat(price.value) < 0) { showError('price', 'Price cannot be negative.'); valid = false; }
        if (!cat.value) { cat.classList.add('is-invalid'); valid = false; }

        if (!valid) e.preventDefault();
    });

    // ── Smart Price Suggestion ──────────────────────────────────────────
    document.getElementById('category').addEventListener('change', function() {
        var category = this.value;
        if (!category) return;
        this.classList.remove('is-invalid');

        var suggestionBox = document.getElementById('price-suggestion-box');
        
        fetch('price-suggestion?category=' + encodeURIComponent(category))
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    suggestionBox.innerHTML = '<i class="bi bi-lightbulb-fill"></i> Smart Suggested Price: \u20B9' + data.average.toFixed(2) + '/kg (based on recent trades)';
                    suggestionBox.style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error fetching price suggestion:', error);
            });
    });
</script>


<jsp:include page="includes/footer.jsp" />
