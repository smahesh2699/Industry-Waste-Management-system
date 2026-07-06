package com.wastelink.servlet.admin;

import com.wastelink.db.DBConnection;
import com.wastelink.model.User;
import com.wastelink.util.AuditLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        List<User> userList = new ArrayList<>();
        String sql = "SELECT * FROM USERS ORDER BY role, full_name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setRole(rs.getString("role"));
                u.setCompanyName(rs.getString("company_name"));
                u.setPhone(rs.getString("phone"));
                u.setCity(rs.getString("city"));
                u.setState(rs.getString("state"));
                // Since account_status is new, retrieve it or default to ACTIVE
                String status = rs.getString("account_status");
                if (status == null) status = "ACTIVE";
                req.setAttribute("status_" + u.getUserId(), status);
                userList.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("users", userList);
        req.getRequestDispatcher("/admin-users.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        int adminId = (int) session.getAttribute("userId");

        String action = req.getParameter("action");
        int targetUserId = Integer.parseInt(req.getParameter("targetUserId"));
        
        String sql = "";
        String details = "";

        if ("suspend".equalsIgnoreCase(action)) {
            sql = "UPDATE USERS SET account_status = 'SUSPENDED' WHERE user_id = ?";
            details = "Suspended user account";
        } else if ("activate".equalsIgnoreCase(action)) {
            sql = "UPDATE USERS SET account_status = 'ACTIVE' WHERE user_id = ?";
            details = "Activated user account";
        } else if ("delete".equalsIgnoreCase(action)) {
            sql = "DELETE FROM USERS WHERE user_id = ?";
            details = "Deleted user account";
        }

        if (!sql.isEmpty()) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    AuditLogger.log(adminId, action.toUpperCase(), "USERS", targetUserId, details);
                }
            } catch (SQLException e) {
                e.printStackTrace();
                // Redirect with error
                res.sendRedirect(req.getContextPath() + "/admin/users?error=Action+failed+due+to+database+constraints");
                return;
            }
        }

        res.sendRedirect(req.getContextPath() + "/admin/users?success=User+updated+successfully");
    }
}
