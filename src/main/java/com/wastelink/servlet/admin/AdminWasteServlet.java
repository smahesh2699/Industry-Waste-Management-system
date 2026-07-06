package com.wastelink.servlet.admin;

import com.wastelink.db.DBConnection;
import com.wastelink.model.Waste;
import com.wastelink.util.AuditLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/listings")
public class AdminWasteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        List<Waste> listings = new ArrayList<>();
        String sql = "SELECT w.*, u.company_name FROM WASTE w JOIN USERS u ON w.user_id = u.user_id ORDER BY w.listed_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Waste w = new Waste();
                w.setWasteId(rs.getInt("waste_id"));
                w.setUserId(rs.getInt("user_id"));
                w.setWasteType(rs.getString("waste_type"));
                w.setCategory(rs.getString("category"));
                w.setQuantityKg(rs.getDouble("quantity_kg"));
                w.setPricePerKg(rs.getDouble("price_per_kg"));
                w.setDescription(rs.getString("description"));
                w.setLocation(rs.getString("location"));
                w.setLatitude(rs.getDouble("latitude"));
                w.setLongitude(rs.getDouble("longitude"));
                w.setStatus(rs.getString("status"));
                w.setListedAt(rs.getTimestamp("listed_at"));

                // retrieve custom flagging properties
                boolean flagged = rs.getBoolean("flagged");
                String reason = rs.getString("flagged_reason");

                req.setAttribute("company_" + w.getWasteId(), rs.getString("company_name"));
                req.setAttribute("flagged_" + w.getWasteId(), flagged);
                req.setAttribute("reason_" + w.getWasteId(), reason);

                listings.add(w);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("listings", listings);
        req.getRequestDispatcher("/admin-listings.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        int adminId = (int) session.getAttribute("userId");

        String action = req.getParameter("action");
        int targetWasteId = Integer.parseInt(req.getParameter("targetWasteId"));

        String sql = "";
        String details = "";
        String reason = req.getParameter("reason");

        if ("flag".equalsIgnoreCase(action)) {
            sql = "UPDATE WASTE SET flagged = TRUE, flagged_reason = ? WHERE waste_id = ?";
            details = "Flagged listing: " + reason;
        } else if ("unflag".equalsIgnoreCase(action)) {
            sql = "UPDATE WASTE SET flagged = FALSE, flagged_reason = NULL WHERE waste_id = ?";
            details = "Unflagged listing";
        } else if ("remove".equalsIgnoreCase(action)) {
            sql = "DELETE FROM WASTE WHERE waste_id = ?";
            details = "Removed listing";
        }

        if (!sql.isEmpty()) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                if ("flag".equalsIgnoreCase(action)) {
                    ps.setString(1, reason);
                    ps.setInt(2, targetWasteId);
                } else {
                    ps.setInt(1, targetWasteId);
                }
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    AuditLogger.log(adminId, action.toUpperCase(), "WASTE", targetWasteId, details);
                }
            } catch (SQLException e) {
                e.printStackTrace();
                res.sendRedirect(req.getContextPath() + "/admin/listings?error=Action+failed+due+to+matching+dependencies");
                return;
            }
        }

        res.sendRedirect(req.getContextPath() + "/admin/listings?success=Listing+moderated+successfully");
    }
}
