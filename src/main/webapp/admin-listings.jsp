<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wastelink.model.User" %>
<%@ page import="com.wastelink.model.Waste" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Admin+access+required");
        return;
    }

    List<Waste> listings = (List<Waste>) request.getAttribute("listings");
    if (listings == null) {
        response.sendRedirect(request.getContextPath() + "/admin/listings");
        return;
    }

    String error = request.getParameter("error");
    String success = request.getParameter("success");
    request.setAttribute("activePage", "listings");
%>
<jsp:include page="includes/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Admin Sidebar -->
        <jsp:include page="includes/admin-sidebar.jsp" />

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
            <div class="mb-4">
                <h1 class="page-title">Manage Listings</h1>
                <p class="page-subtitle">Inspect waste materials listed by industrial producers, handle flagging reports, and remove inappropriate posts.</p>
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
                        <input type="text" id="listingSearch" class="form-control rounded-3" placeholder="Search by waste name or description..." onkeyup="filterListings()">
                    </div>
                    <div class="col-md-6">
                        <select id="flaggedFilter" class="form-select rounded-3" onchange="filterListings()">
                            <option value="ALL">All Listings</option>
                            <option value="FLAGGED">Flagged Only</option>
                            <option value="SAFE">Safe Only</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Listings Table -->
            <div class="card card-wl border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0" id="listingsTable">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-4">Material Name</th>
                                    <th>Category</th>
                                    <th>Quantity</th>
                                    <th>Unit Price</th>
                                    <th>Listed By</th>
                                    <th>Status</th>
                                    <th>Flagged Status</th>
                                    <th class="pe-4 text-end">Action controls</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (Waste w : listings) {
                                        String company = (String) request.getAttribute("company_" + w.getWasteId());
                                        boolean flagged = (Boolean) request.getAttribute("flagged_" + w.getWasteId());
                                        String reason = (String) request.getAttribute("reason_" + w.getWasteId());
                                %>
                                    <tr class="listing-row" data-name="<%= w.getWasteType().toLowerCase() %>" 
                                        data-desc="<%= (w.getDescription() != null ? w.getDescription() : "").toLowerCase() %>" 
                                        data-flagged="<%= flagged %>">
                                        <td class="ps-4 fw-semibold">
                                            <%= w.getWasteType() %>
                                            <% if (flagged) { %>
                                                <i class="bi bi-flag-fill text-danger ms-1" title="Reason: <%= reason %>"></i>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge-category"><%= w.getCategory() %></span>
                                        </td>
                                        <td><%= w.getQuantityKg() %> kg</td>
                                        <td class="fw-bold">₹<%= String.format("%.2f", w.getPricePerKg()) %>/kg</td>
                                        <td><%= company != null ? company : "N/A" %></td>
                                        <td>
                                            <%
                                                String statusClass = "badge-status-available";
                                                if ("SOLD".equalsIgnoreCase(w.getStatus())) {
                                                    statusClass = "badge-status-sold";
                                                } else if ("MATCHED".equalsIgnoreCase(w.getStatus())) {
                                                    statusClass = "badge-status-matched";
                                                }
                                            %>
                                            <span class="<%= statusClass %>"><%= w.getStatus() %></span>
                                        </td>
                                        <td>
                                            <% if (flagged) { %>
                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle small px-2">FLAGGED</span>
                                                <div class="text-muted small italic" style="font-size: 0.7rem; max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><%= reason %></div>
                                            <% } else { %>
                                                <span class="badge bg-success-subtle text-success border border-success-subtle small px-2">SAFE</span>
                                            <% } %>
                                        </td>
                                        <td class="pe-4 text-end">
                                            <div class="d-flex justify-content-end gap-2">
                                                <% if (!flagged) { %>
                                                    <form action="<%= request.getContextPath() %>/admin/listings" method="POST" class="d-inline" onsubmit="return promptForFlagReason(this, <%= w.getWasteId() %>);">
                                                        <input type="hidden" name="action" value="flag">
                                                        <input type="hidden" name="targetWasteId" value="<%= w.getWasteId() %>">
                                                        <input type="hidden" id="flagReason_<%= w.getWasteId() %>" name="reason" value="">
                                                        <button type="submit" class="btn btn-sm btn-outline-warning py-1 px-2.5 rounded-3">Flag</button>
                                                    </form>
                                                <% } else { %>
                                                    <form action="<%= request.getContextPath() %>/admin/listings" method="POST" class="d-inline">
                                                        <input type="hidden" name="action" value="unflag">
                                                        <input type="hidden" name="targetWasteId" value="<%= w.getWasteId() %>">
                                                        <button type="submit" class="btn btn-sm btn-outline-success py-1 px-2.5 rounded-3">Unflag</button>
                                                    </form>
                                                <% } %>
                                                
                                                <form action="<%= request.getContextPath() %>/admin/listings" method="POST" class="d-inline" onsubmit="return confirm('Permanently remove listing? This cannot be undone.');">
                                                    <input type="hidden" name="action" value="remove">
                                                    <input type="hidden" name="targetWasteId" value="<%= w.getWasteId() %>">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger py-1 px-2.5 rounded-3">Remove</button>
                                                </form>
                                            </div>
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
    function promptForFlagReason(form, id) {
        var reason = prompt("Enter the reason for flagging this listing:");
        if (reason === null || reason.trim() === "") {
            return false;
        }
        document.getElementById("flagReason_" + id).value = reason;
        return true;
    }

    function filterListings() {
        const query = document.getElementById("listingSearch").value.toLowerCase();
        const filter = document.getElementById("flaggedFilter").value;
        const rows = document.querySelectorAll(".listing-row");

        rows.forEach(row => {
            const name = row.getAttribute("data-name");
            const desc = row.getAttribute("data-desc");
            const flagged = row.getAttribute("data-flagged") === "true";

            const matchesQuery = name.includes(query) || desc.includes(query);
            let matchesFilter = true;

            if (filter === "FLAGGED") {
                matchesFilter = flagged;
            } else if (filter === "SAFE") {
                matchesFilter = !flagged;
            }

            if (matchesQuery && matchesFilter) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    }
</script>

<jsp:include page="includes/footer.jsp" />
