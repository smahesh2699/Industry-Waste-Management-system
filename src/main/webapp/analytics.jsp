<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.util.ImpactUtil" %>
<%@ page import="java.util.Map" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?error=Access+denied");
        return;
    }

    Map<String, Integer> categoryCounts = (Map<String, Integer>) request.getAttribute("categoryCounts");
    Map<String, Integer> statusCounts = (Map<String, Integer>) request.getAttribute("statusCounts");
    Map<String, Integer> monthlyActivity = (Map<String, Integer>) request.getAttribute("monthlyActivity");
    Double totalCo2Saved = (Double) request.getAttribute("totalCo2Saved");
    Double totalProfitEstimate = (Double) request.getAttribute("totalProfitEstimate");
    Integer totalTransactions = (Integer) request.getAttribute("totalTransactions");

    if (categoryCounts == null) {
        response.sendRedirect("analytics");
        return;
    }

    double co2Val = totalCo2Saved != null ? totalCo2Saved : 0.0;
    double profitVal = totalProfitEstimate != null ? totalProfitEstimate : 0.0;
    int transactionVal = totalTransactions != null ? totalTransactions : 0;
    
    // Estimate total quantity roughly to compute sustainability rating
    double estimatedQuantity = co2Val / 2.0; // reverse average factor of 2.0
    double sustainRating = ImpactUtil.sustainabilityScore(co2Val, estimatedQuantity);
%>
<jsp:include page="includes/navbar.jsp" />

<!-- Load Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<div class="container-fluid">
    <div class="row">
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
                <a class="nav-link active" href="analytics">
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
                <h1 class="page-title">Performance Analytics</h1>
                <p class="page-subtitle">Inspect financial trade indexes, sustainability ratings, and carbon credits.</p>
            </div>

            <!-- Stats Row -->
            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="stat-card text-center">
                        <div class="fs-2 mb-1">💰</div>
                        <div class="stat-value text-success">₹<%= String.format("%.2f", profitVal) %></div>
                        <div class="stat-label">Cumulative Margins Earned/Saved</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card text-center">
                        <div class="fs-2 mb-1">🌱</div>
                        <div class="stat-value text-success"><%= String.format("%.1f", co2Val) %> kg</div>
                        <div class="stat-label">Total CO₂ Offsets Recouped</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card text-center">
                        <div class="fs-2 mb-1">🤝</div>
                        <div class="stat-value text-success"><%= transactionVal %></div>
                        <div class="stat-label">Completed/Active Trades</div>
                    </div>
                </div>
            </div>

            <div class="row g-4 mb-5">
                <!-- Sustainability bar & Calculator -->
                <div class="col-lg-6">
                    <div class="card card-wl p-4 h-100 shadow-sm border border-light">
                        <h5 class="fw-bold text-success mb-3"><i class="bi bi-tree-fill"></i> Environmental Impact Card</h5>
                        <p class="small text-muted">Your current sustainability ranking is determined by the total volume of recyclable materials processed against direct carbon saves.</p>
                        
                        <div class="my-4">
                            <div class="d-flex justify-content-between mb-1 small fw-bold">
                                <span>Sustainability Index</span>
                                <span><%= String.format("%.1f", sustainRating) %>%</span>
                            </div>
                            <div class="impact-bar">
                                <div class="impact-fill" style="width: <%= sustainRating %>%;"></div>
                            </div>
                        </div>

                        <!-- Profit Estimator Form -->
                        <h5 class="fw-bold text-success mt-4 mb-3 border-top pt-4"><i class="bi bi-calculator"></i> Trade Net Margin Estimator</h5>
                        <div class="row g-3">
                            <div class="col-sm-6">
                                <label for="calcQty" class="form-label small text-muted">Quantity (kg)</label>
                                <input type="number" class="form-control form-control-sm" id="calcQty" placeholder="e.g. 1000" oninput="runCalculation()">
                            </div>
                            <div class="col-sm-6">
                                <label for="calcPrice" class="form-label small text-muted">Price per kg (₹)</label>
                                <input type="number" class="form-control form-control-sm" id="calcPrice" placeholder="e.g. 25" oninput="runCalculation()">
                            </div>
                        </div>
                        <div class="mt-4 p-3 bg-light rounded-3 d-flex justify-content-between align-items-center">
                            <span class="small fw-semibold text-muted">Estimated Margin:</span>
                            <span class="fw-bold fs-4 text-success" id="calcResult">₹0.00</span>
                        </div>
                    </div>
                </div>

                <!-- status breakdown pie chart -->
                <div class="col-lg-6">
                    <div class="card card-wl p-4 h-100 shadow-sm border border-light">
                        <h5 class="fw-bold text-success mb-3"><i class="bi bi-pie-chart-fill"></i> Transaction Exchange Status</h5>
                        <div class="chart-container d-flex justify-content-center" style="position: relative; height:220px; width:100%;">
                            <canvas id="statusChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Category bar chart -->
                <div class="col-lg-6">
                    <div class="card card-wl p-4 shadow-sm border border-light">
                        <h5 class="fw-bold text-success mb-3"><i class="bi bi-bar-chart-fill"></i> Materials Distribution (Categories)</h5>
                        <div class="chart-container" style="position: relative; height:240px; width:100%;">
                            <canvas id="categoryChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Monthly activity line chart -->
                <div class="col-lg-6">
                    <div class="card card-wl p-4 shadow-sm border border-light">
                        <h5 class="fw-bold text-success mb-3"><i class="bi bi-graph-up"></i> Activity Timeline (Recent Months)</h5>
                        <div class="chart-container" style="position: relative; height:240px; width:100%;">
                            <canvas id="monthlyChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Client-side calculations
    function runCalculation() {
        var qty = parseFloat(document.getElementById('calcQty').value) || 0;
        var prc = parseFloat(document.getElementById('calcPrice').value) || 0;
        var gross = qty * prc;
        var handling = gross * 0.08;
        var transport = qty * 0.5;
        var profit = gross - handling - transport;
        
        document.getElementById('calcResult').innerText = "₹" + (profit > 0 ? profit.toFixed(2) : "0.00");
    }

    // Chart.js Configuration
    document.addEventListener("DOMContentLoaded", function() {
        // 1. Category Chart
        const catCtx = document.getElementById('categoryChart').getContext('2d');
        const catLabels = [
            <% for (String cat : categoryCounts.keySet()) { %> '<%= cat %>', <% } %>
        ];
        const catData = [
            <% for (Integer cnt : categoryCounts.values()) { %> <%= cnt %>, <% } %>
        ];
        new Chart(catCtx, {
            type: 'bar',
            data: {
                labels: catLabels.length ? catLabels : ['No Materials'],
                datasets: [{
                    label: 'Postings Count',
                    data: catData.length ? catData : [0],
                    backgroundColor: '#1D9E75',
                    borderColor: '#0F6E56',
                    borderWidth: 1,
                    borderRadius: 5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { beginAtZero: true, ticks: { stepSize: 1 } }
                }
            }
        });

        // 2. Status Chart
        const statusCtx = document.getElementById('statusChart').getContext('2d');
        const statLabels = [
            <% for (String stat : statusCounts.keySet()) { %> '<%= stat %>', <% } %>
        ];
        const statData = [
            <% for (Integer cnt : statusCounts.values()) { %> <%= cnt %>, <% } %>
        ];
        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: statLabels.length ? statLabels : ['No Exchanges'],
                datasets: [{
                    data: statData.length ? statData : [1],
                    backgroundColor: ['#1D9E75', '#EF9F27', '#185FA5', '#C53030'],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });

        // 3. Monthly Activity Chart
        const monCtx = document.getElementById('monthlyChart').getContext('2d');
        const monLabels = [
            <% for (String mon : monthlyActivity.keySet()) { %> '<%= mon %>', <% } %>
        ];
        const monData = [
            <% for (Integer cnt : monthlyActivity.values()) { %> <%= cnt %>, <% } %>
        ];
        new Chart(monCtx, {
            type: 'line',
            data: {
                labels: monLabels.length ? monLabels : ['No Activity'],
                datasets: [{
                    label: 'Transactions Count',
                    data: monData.length ? monData : [0],
                    backgroundColor: 'rgba(93, 202, 165, 0.2)',
                    borderColor: '#1D9E75',
                    borderWidth: 2,
                    tension: 0.3,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { beginAtZero: true, ticks: { stepSize: 1 } }
                }
            }
        });
    });
</script>

<jsp:include page="includes/footer.jsp" />
