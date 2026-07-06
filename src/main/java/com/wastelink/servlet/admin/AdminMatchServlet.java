package com.wastelink.servlet.admin;

import com.wastelink.db.DBConnection;
import com.wastelink.util.AuditLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/matches")
public class AdminMatchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        List<String[]> matchesList = new ArrayList<>();
        String statusFilter = req.getParameter("status");

        StringBuilder sql = new StringBuilder(
            "SELECT m.match_id, w.waste_type, w.category, ind.company_name AS industry_name, " +
            "rec.company_name AS recycler_name, m.status, m.profit_estimate, m.co2_saved_kg, m.matched_at " +
            "FROM MATCHES m " +
            "JOIN WASTE w ON m.waste_id = w.waste_id " +
            "JOIN USERS ind ON m.industry_user_id = ind.user_id " +
            "JOIN USERS rec ON m.recycler_id = rec.user_id "
        );

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("WHERE m.status = ? ");
        }
        sql.append("ORDER BY m.matched_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                ps.setString(1, statusFilter);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    matchesList.add(new String[]{
                        String.valueOf(rs.getInt("match_id")),
                        rs.getString("waste_type"),
                        rs.getString("category"),
                        rs.getString("industry_name"),
                        rs.getString("recycler_name"),
                        rs.getString("status"),
                        String.format("%.2f", rs.getDouble("profit_estimate")),
                        String.format("%.1f", rs.getDouble("co2_saved_kg")),
                        rs.getTimestamp("matched_at").toString()
                    });
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("matches", matchesList);
        req.setAttribute("statusFilter", statusFilter);
        req.getRequestDispatcher("/admin-matches.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        int adminId = (int) session.getAttribute("userId");

        int targetMatchId = Integer.parseInt(req.getParameter("targetMatchId"));
        String newStatus = req.getParameter("status");

        String sql = "UPDATE MATCHES SET status = ? WHERE match_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, targetMatchId);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                AuditLogger.log(adminId, "RESOLVE", "MATCHES", targetMatchId, "Updated match status to " + newStatus);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        res.sendRedirect(req.getContextPath() + "/admin/matches?success=Match+resolved+successfully");
    }
}
