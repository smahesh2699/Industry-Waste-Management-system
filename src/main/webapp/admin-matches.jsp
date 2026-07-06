<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Admin+access+required");
        return;
    }

    List<String[]> matches = (List<String[]>) request.getAttribute("matches");
    if (matches == null) {
        response.sendRedirect(request.getContextPath() + "/admin/matches");
        return;
    }

    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "ALL";

    String success = request.getParameter("success");
    request.setAttribute("activePage", "matches");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Admin Sidebar -->
        <jsp:include page="includes/admin-sidebar.jsp" />

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">Manage Trade Matches</h1>
                <p class="page-subtitle">Oversee recycling negotiations, review calculated carbon offset credits, and manually override exchange states.</p>
            </div>

            <% if (success != null) { %>
                <div class="alert alert-success py-2 small" role="alert">
                    <i class="bi bi-check-circle-fill"></i> <%= success %>
                </div>
            <% } %>

            <!-- Filter Panel -->
            <div class="card card-wl p-3 border border-light shadow-sm mb-4">
                <form action="<%= request.getContextPath() %>/admin/matches" method="GET" class="row align-items-center g-3">
                    <div class="col-md-4">
                        <label for="status" class="form-label small fw-semibold text-muted mb-1">Filter by Status</label>
                        <select name="status" id="status" class="form-select rounded-3" onchange="this.form.submit()">
                            <option value="ALL" <%= "ALL".equals(statusFilter) ? "selected" : "" %>>All Statuses</option>
                            <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>PENDING</option>
                            <option value="ACCEPTED" <%= "ACCEPTED".equals(statusFilter) ? "selected" : "" %>>ACCEPTED</option>
                            <option value="REJECTED" <%= "REJECTED".equals(statusFilter) ? "selected" : "" %>>REJECTED</option>
                            <option value="COMPLETED" <%= "COMPLETED".equals(statusFilter) ? "selected" : "" %>>COMPLETED</option>
                        </select>
                    </div>
                </form>
            </div>

            <!-- Matches Table -->
            <div class="card card-wl border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-4">Match ID</th>
                                    <th>Material Type</th>
                                    <th>Category</th>
                                    <th>Industry (Seller)</th>
                                    <th>Recycler (Buyer)</th>
                                    <th>Profit Margin</th>
                                    <th>CO₂ Saved</th>
                                    <th>Matched At</th>
                                    <th class="pe-4 text-end">Update Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (matches.isEmpty()) { %>
                                    <tr>
                                        <td colspan="9" class="text-center py-4 text-muted small">No matches found matching criteria.</td>
                                    </tr>
                                <% } else { %>
                                    <% for (String[] m : matches) { %>
                                        <tr>
                                            <td class="ps-4 fw-semibold">#<%= m[0] %></td>
                                            <td><%= m[1] %></td>
                                            <td>
                                                <span class="badge-category"><%= m[2] %></span>
                                            </td>
                                            <td><%= m[3] %></td>
                                            <td><%= m[4] %></td>
                                            <td class="fw-bold">₹<%= m[6] %></td>
                                            <td class="text-success fw-bold"><%= m[7] %> kg</td>
                                            <td class="small text-muted"><%= m[8] %></td>
                                            <td class="pe-4 text-end">
                                                <form action="<%= request.getContextPath() %>/admin/matches" method="POST" class="d-inline" onsubmit="return confirm('Override match status to ' + this.status.value + '?');">
                                                    <input type="hidden" name="targetMatchId" value="<%= m[0] %>">
                                                    <select name="status" class="form-select form-select-sm d-inline-block rounded-3" style="width: 125px; font-size: 0.8rem;" onchange="this.form.submit()">
                                                        <option value="PENDING" <%= "PENDING".equals(m[5]) ? "selected" : "" %>>PENDING</option>
                                                        <option value="ACCEPTED" <%= "ACCEPTED".equals(m[5]) ? "selected" : "" %>>ACCEPTED</option>
                                                        <option value="REJECTED" <%= "REJECTED".equals(m[5]) ? "selected" : "" %>>REJECTED</option>
                                                        <option value="COMPLETED" <%= "COMPLETED".equals(m[5]) ? "selected" : "" %>>COMPLETED</option>
                                                    </select>
                                                </form>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
