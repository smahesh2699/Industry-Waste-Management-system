package com.wastelink.servlet;

import com.wastelink.db.DBConnection;
import com.wastelink.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();

        String currentPassword    = req.getParameter("currentPassword");
        String newPassword        = req.getParameter("newPassword");
        String confirmNewPassword = req.getParameter("confirmNewPassword");

        // Validate new password confirmation
        if (!newPassword.equals(confirmNewPassword)) {
            res.sendRedirect("profile.jsp?pwmsg=mismatch");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Verify current password
            String checkSql = "SELECT password FROM USERS WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String storedPassword = rs.getString("password");
                        if (!storedPassword.equals(currentPassword)) {
                            // Current password doesn't match
                            res.sendRedirect("profile.jsp?pwmsg=error");
                            return;
                        }
                    }
                }
            }

            // Update to new password
            String updateSql = "UPDATE USERS SET password = ? WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newPassword);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            res.sendRedirect("profile.jsp?pwmsg=error");
            return;
        }

        res.sendRedirect("profile.jsp?pwmsg=success");
    }
}
