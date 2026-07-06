<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.db.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Admin+access+required");
        return;
    }

    List<String[]> logsList = new ArrayList<>();
    String sql = "SELECT l.log_id, u.full_name, l.action, l.target_table, l.target_id, l.details, l.created_at " +
                 "FROM ADMIN_LOGS l " +
                 "JOIN USERS u ON l.admin_id = u.user_id " +
                 "ORDER BY l.created_at DESC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            logsList.add(new String[]{
                String.valueOf(rs.getInt("log_id")),
                rs.getString("full_name"),
                rs.getString("action"),
                rs.getString("target_table"),
                String.valueOf(rs.getInt("target_id")),
                rs.getString("details"),
                rs.getTimestamp("created_at").toString()
            });
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    request.setAttribute("activePage", "logs");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Admin Sidebar -->
        <jsp:include page="includes/admin-sidebar.jsp" />

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">Platform Audit Logs</h1>
                <p class="page-subtitle">Track administrative interventions, user account updates, listing moderations, and override matches in real-time.</p>
            </div>

            <!-- Logs Table -->
            <div class="card card-wl border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-4">Log ID</th>
                                    <th>Admin User</th>
                                    <th>Action Log</th>
                                    <th>Target Scope</th>
                                    <th>Target ID</th>
                                    <th>Details</th>
                                    <th class="pe-4">Executed At</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (logsList.isEmpty()) { %>
                                    <tr>
                                        <td colspan="7" class="text-center py-4 text-muted small">No administrative actions have been logged yet.</td>
                                    </tr>
                                <% } else { %>
                                    <% for (String[] log : logsList) { %>
                                        <tr>
                                            <td class="ps-4 text-muted small">#<%= log[0] %></td>
                                            <td class="fw-semibold"><%= log[1] %></td>
                                            <td>
                                                <%
                                                    String actionBadge = "bg-secondary text-white";
                                                    if ("SUSPEND".equalsIgnoreCase(log[2])) {
                                                        actionBadge = "bg-warning text-dark";
                                                    } else if ("DELETE".equalsIgnoreCase(log[2]) || "REMOVE".equalsIgnoreCase(log[2])) {
                                                        actionBadge = "bg-danger text-white";
                                                    } else if ("ACTIVATE".equalsIgnoreCase(log[2]) || "RESOLVE".equalsIgnoreCase(log[2]) || "UNFLAG".equalsIgnoreCase(log[2])) {
                                                        actionBadge = "bg-success text-white";
                                                    } else if ("FLAG".equalsIgnoreCase(log[2])) {
                                                        actionBadge = "bg-info text-dark";
                                                    }
                                                %>
                                                <span class="badge <%= actionBadge %> small px-2 py-1"><%= log[2] %></span>
                                            </td>
                                            <td class="small"><%= log[3] %></td>
                                            <td class="small text-muted"><%= log[4] %></td>
                                            <td class="small"><%= log[5] %></td>
                                            <td class="small text-muted pe-4"><%= log[6] %></td>
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
