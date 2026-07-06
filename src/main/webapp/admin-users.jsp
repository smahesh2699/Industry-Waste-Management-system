<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Admin+access+required");
        return;
    }

    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) {
        response.sendRedirect(request.getContextPath() + "/admin/users");
        return;
    }

    String error = request.getParameter("error");
    String success = request.getParameter("success");
    request.setAttribute("activePage", "users");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Admin Sidebar -->
        <jsp:include page="includes/admin-sidebar.jsp" />

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">Manage Users</h1>
                <p class="page-subtitle">Inspect user credentials, business properties, and adjust suspension access controls.</p>
            </div>

            <% if (error != null) { %>
                <div class="alert alert-danger py-2 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i> <%= error %>
                </div>
            <% } %>
            <% if (success != null) { %>
                <div class="alert alert-success py-2 small" role="alert">
                    <i class="bi bi-check-circle-fill"></i> <%= success %>
                </div>
            <% } %>

            <!-- Search and Filter Panel -->
            <div class="card card-wl p-3 border border-light shadow-sm mb-4">
                <div class="row g-3">
                    <div class="col-md-6">
                        <input type="text" id="userSearch" class="form-control rounded-3" placeholder="Search by name, email, or company..." onkeyup="filterUsers()">
                    </div>
                    <div class="col-md-6">
                        <select id="roleFilter" class="form-select rounded-3" onchange="filterUsers()">
                            <option value="ALL">All Roles</option>
                            <option value="INDUSTRY">Industry Partners</option>
                            <option value="RECYCLER">Recycler Partners</option>
                            <option value="ADMIN">Administrators</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Users Table Card -->
            <div class="card card-wl border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0" id="usersTable">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-4">Full Name</th>
                                    <th>Email Address</th>
                                    <th>Role</th>
                                    <th>Company Name</th>
                                    <th>City &amp; State</th>
                                    <th>Status</th>
                                    <th class="pe-4 text-end">Action controls</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (User u : users) {
                                        String status = (String) request.getAttribute("status_" + u.getUserId());
                                        if (status == null) status = "ACTIVE";
                                        
                                        String badgeClass = "badge-status-available";
                                        if ("SUSPENDED".equalsIgnoreCase(status)) {
                                            badgeClass = "bg-danger text-white";
                                        } else {
                                            badgeClass = "bg-success text-white";
                                        }
                                %>
                                    <tr class="user-row" data-name="<%= u.getFullName().toLowerCase() %>" 
                                        data-email="<%= u.getEmail().toLowerCase() %>" 
                                        data-company="<%= (u.getCompanyName() != null ? u.getCompanyName() : "").toLowerCase() %>"
                                        data-role="<%= u.getRole() %>">
                                        <td class="ps-4 fw-semibold"><%= u.getFullName() %></td>
                                        <td><%= u.getEmail() %></td>
                                        <td>
                                            <span class="badge-category"><%= u.getRole() %></span>
                                        </td>
                                        <td><%= u.getCompanyName() != null ? u.getCompanyName() : "N/A" %></td>
                                        <td><%= u.getCity() != null ? u.getCity() + ", " + u.getState() : "N/A" %></td>
                                        <td>
                                            <span class="badge <%= badgeClass %> small" style="font-size: 0.75rem;"><%= status %></span>
                                        </td>
                                        <td class="pe-4 text-end">
                                            <% if (u.getUserId() != loggedUser.getUserId()) { %>
                                                <div class="d-flex justify-content-end gap-2">
                                                    <% if ("ACTIVE".equalsIgnoreCase(status)) { %>
                                                        <form action="<%= request.getContextPath() %>/admin/users" method="POST" class="d-inline" onsubmit="return confirm('Suspend user account?');">
                                                            <input type="hidden" name="action" value="suspend">
                                                            <input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
                                                            <button type="submit" class="btn btn-sm btn-outline-warning py-1 px-2.5 rounded-3">Suspend</button>
                                                        </form>
                                                    <% } else { %>
                                                        <form action="<%= request.getContextPath() %>/admin/users" method="POST" class="d-inline">
                                                            <input type="hidden" name="action" value="activate">
                                                            <input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
                                                            <button type="submit" class="btn btn-sm btn-outline-success py-1 px-2.5 rounded-3">Activate</button>
                                                        </form>
                                                    <% } %>
                                                    
                                                    <form action="<%= request.getContextPath() %>/admin/users" method="POST" class="d-inline" onsubmit="return confirm('Permanently delete user? This cannot be undone.');">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger py-1 px-2.5 rounded-3">Delete</button>
                                                    </form>
                                                </div>
                                            <% } else { %>
                                                <span class="text-muted small italic">Logged-in</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function filterUsers() {
        const query = document.getElementById("userSearch").value.toLowerCase();
        const role = document.getElementById("roleFilter").value;
        const rows = document.querySelectorAll(".user-row");

        rows.forEach(row => {
            const name = row.getAttribute("data-name");
            const email = row.getAttribute("data-email");
            const company = row.getAttribute("data-company");
            const rowRole = row.getAttribute("data-role");

            const matchesQuery = name.includes(query) || email.includes(query) || company.includes(query);
            const matchesRole = (role === "ALL") || (rowRole === role);

            if (matchesQuery && matchesRole) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    }
</script>

<jsp:include page="includes/footer.jsp" />
