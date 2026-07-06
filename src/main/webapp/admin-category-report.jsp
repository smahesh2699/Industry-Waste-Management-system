<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.model.CategoryUserSummary" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Admin+access+required");
        return;
    }

    Map<String, List<CategoryUserSummary>> listingsByCategory = 
        (Map<String, List<CategoryUserSummary>>) request.getAttribute("listingsByCategory");
    Map<String, List<CategoryUserSummary>> recyclerShareByCategory = 
        (Map<String, List<CategoryUserSummary>>) request.getAttribute("recyclerShareByCategory");

    if (listingsByCategory == null || recyclerShareByCategory == null) {
        response.sendRedirect(request.getContextPath() + "/admin/category-report");
        return;
    }

    request.setAttribute("activePage", "category-report");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Admin Sidebar -->
        <jsp:include page="includes/admin-sidebar.jsp" />

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="page-title">Categorical Waste Exchange Report</h1>
                    <p class="page-subtitle mb-0">Overview of which certified recycling partners process which material categories, along with volume distribution metrics.</p>
                </div>
                <a href="<%= request.getContextPath() %>/admin/category-export" class="btn btn-wl-primary text-white d-flex align-items-center gap-2">
                    <i class="bi bi-file-earmark-spreadsheet-fill"></i> Export to CSV
                </a>
            </div>

            <!-- Horizontal Stacked Bar Chart -->
            <div class="card card-wl p-4 border border-light shadow-sm mb-5">
                <h5 class="fw-bold mb-3 text-success"><i class="bi bi-bar-chart-steps"></i> Recycler Category Share (Stacked Breakdown)</h5>
                <div style="height: 380px; position: relative;">
                    <canvas id="stackedBarChart"></canvas>
                </div>
            </div>

            <!-- Drill-Down Section -->
            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="card card-wl p-4 border border-light shadow-sm h-100">
                        <h5 class="fw-bold mb-3 text-success"><i class="bi bi-pie-chart-fill"></i> Category Share Drill-Down</h5>
                        
                        <div class="mb-4">
                            <label for="drillCategory" class="form-label small fw-semibold text-muted">Select Material Category</label>
                            <select id="drillCategory" class="form-select rounded-3" onchange="onCategoryChange()">
                                <option value="" disabled selected>Loading categories...</option>
                            </select>
                        </div>

                        <div style="height: 250px; position: relative;" class="d-flex justify-content-center align-items-center">
                            <canvas id="donutChart"></canvas>
                            <div id="noDataMessage" class="text-muted small">Select a category to view chart</div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6 mb-4">
                    <div class="card card-wl p-4 border border-light shadow-sm h-100">
                        <h5 class="fw-bold mb-3 text-success"><i class="bi bi-list-ol"></i> Share Metrics Listing</h5>
                        <div class="table-responsive">
                            <table class="table align-middle" id="drillTable">
                                <thead class="table-light">
                                    <tr>
                                        <th>Recycler Company</th>
                                        <th>Total Exchanged</th>
                                        <th>Percentage Share</th>
                                    </tr>
                                </thead>
                                <tbody id="drillTableBody">
                                    <tr>
                                        <td colspan="3" class="text-center text-muted small py-4">Please select a category in the drill-down panel.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Load Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    let chartData = null;
    let donutChartInstance = null;

    document.addEventListener("DOMContentLoaded", function() {
        fetch('<%= request.getContextPath() %>/admin/category-chart')
            .then(res => res.json())
            .then(data => {
                chartData = data;
                renderStackedBarChart(data);
                
                // Populate category dropdown
                const select = document.getElementById("drillCategory");
                select.innerHTML = '<option value="" disabled selected>Select Category</option>';
                Object.keys(data).forEach(cat => {
                    if (data[cat].length > 0) {
                        const opt = document.createElement("option");
                        opt.value = cat;
                        opt.textContent = cat;
                        select.appendChild(opt);
                    }
                });
            })
            .catch(err => console.error("Error loading category report:", err));
    });

    function renderStackedBarChart(data) {
        const categories = Object.keys(data);
        const recyclerData = {};

        categories.forEach(cat => {
            data[cat].forEach(item => {
                if (!recyclerData[item.companyName]) {
                    recyclerData[item.companyName] = {};
                }
                recyclerData[item.companyName][cat] = item.totalQuantityKg;
            });
        });

        const recyclers = Object.keys(recyclerData);
        const colors = [
            'rgba(29, 158, 117, 0.75)',  // Emerald Teal
            'rgba(93, 202, 165, 0.75)',  // Mint Green
            'rgba(239, 159, 39, 0.75)',   // Amber Gold
            'rgba(15, 110, 86, 0.75)',   // Dark Forest Teal
            'rgba(235, 87, 87, 0.75)',   // Coral Red
            'rgba(86, 204, 242, 0.75)',  // Sky Blue
            'rgba(155, 81, 224, 0.75)'   // Amethyst Purple
        ];

        const datasets = recyclers.map((rec, index) => {
            const dataPoints = categories.map(cat => recyclerData[rec][cat] || 0);
            return {
                label: rec,
                data: dataPoints,
                backgroundColor: colors[index % colors.length],
                borderColor: colors[index % colors.length].replace('0.7', '1'),
                borderWidth: 1
            };
        });

        const ctx = document.getElementById('stackedBarChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: categories,
                datasets: datasets
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        stacked: true,
                        title: {
                            display: true,
                            text: 'Exchanged Volume (kg)'
                        }
                    },
                    y: {
                        stacked: true
                    }
                },
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            boxWidth: 12
                        }
                    }
                }
            }
        });
    }

    function onCategoryChange() {
        const cat = document.getElementById("drillCategory").value;
        if (!chartData || !chartData[cat]) return;

        const list = chartData[cat];

        // Hide prompt message
        document.getElementById("noDataMessage").style.display = "none";

        // Render Donut Chart
        renderDonutChart(cat, list);

        // Populate Table
        const tbody = document.getElementById("drillTableBody");
        tbody.innerHTML = "";
        list.forEach(item => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td>${item.companyName}</td>
                <td class="fw-semibold">${item.totalQuantityKg.toFixed(1)} kg</td>
                <td class="text-success fw-bold">${item.percentageShare.toFixed(1)}%</td>
            `;
            tbody.appendChild(tr);
        });
    }

    function renderDonutChart(category, list) {
        const ctx = document.getElementById('donutChart').getContext('2d');

        if (donutChartInstance) {
            donutChartInstance.destroy();
        }

        const labels = list.map(item => item.companyName);
        const data = list.map(item => item.totalQuantityKg);

        const colors = [
            'rgba(40, 167, 69, 0.7)',
            'rgba(0, 123, 255, 0.7)',
            'rgba(255, 193, 7, 0.7)',
            'rgba(220, 53, 69, 0.7)',
            'rgba(111, 66, 193, 0.7)',
            'rgba(23, 162, 184, 0.7)',
            'rgba(253, 126, 20, 0.7)'
        ];

        donutChartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: data,
                    backgroundColor: colors.slice(0, list.length),
                    borderColor: colors.slice(0, list.length).map(c => c.replace('0.7', '1')),
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            boxWidth: 10,
                            font: { size: 10 }
                        }
                    }
                }
            }
        });
    }
</script>

<jsp:include page="includes/footer.jsp" />
