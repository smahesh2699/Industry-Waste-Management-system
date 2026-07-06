package com.wastelink.servlet;

import com.wastelink.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/leaderboard")
public class LeaderboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        List<String[]> leaderboardList = new ArrayList<>();

        String query = "SELECT u.user_id, u.company_name, u.role, u.city, u.state, COALESCE(SUM(m.co2_saved_kg), 0) as total_co2 " +
                       "FROM USERS u " +
                       "LEFT JOIN MATCHES m ON (u.user_id = m.industry_user_id OR u.user_id = m.recycler_id) AND m.status = 'ACCEPTED' " +
                       "GROUP BY u.user_id, u.company_name, u.role, u.city, u.state " +
                       "ORDER BY total_co2 DESC, u.company_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                leaderboardList.add(new String[]{
                    String.valueOf(rs.getInt("user_id")),
                    rs.getString("company_name"),
                    rs.getString("role"),
                    rs.getString("city") + ", " + rs.getString("state"),
                    String.format("%.1f", rs.getDouble("total_co2"))
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("leaderboard", leaderboardList);
        req.getRequestDispatcher("leaderboard.jsp").forward(req, res);
    }
}
