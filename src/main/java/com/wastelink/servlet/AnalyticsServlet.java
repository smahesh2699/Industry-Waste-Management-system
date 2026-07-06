package com.wastelink.servlet;

import com.wastelink.db.DBConnection;
import com.wastelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();
        String role = user.getRole();

        // Data containers
        Map<String, Integer> categoryCounts = new HashMap<>();
        Map<String, Integer> statusCounts = new HashMap<>();
        Map<String, Integer> monthlyActivity = new LinkedHashMap<>(); // preserve month order
        
        double totalCo2Saved = 0.0;
        double totalProfitEstimate = 0.0;
        int totalTransactions = 0;

        String wasteQuery;
        String matchQuery;
        String monthlyQuery;

        if ("INDUSTRY".equalsIgnoreCase(role)) {
            wasteQuery = "SELECT category, COUNT(*) as cnt FROM WASTE WHERE user_id = ? GROUP BY category";
            matchQuery = "SELECT status, COUNT(*) as cnt, SUM(profit_estimate) as profit, SUM(co2_saved_kg) as co2 FROM MATCHES WHERE industry_user_id = ? GROUP BY status";
            monthlyQuery = "SELECT DATE_FORMAT(listed_at, '%b %Y') as month_yr, COUNT(*) as cnt FROM WASTE WHERE user_id = ? GROUP BY month_yr ORDER BY MIN(listed_at) ASC LIMIT 6";
        } else {
            wasteQuery = "SELECT w.category, COUNT(*) as cnt FROM MATCHES m JOIN WASTE w ON m.waste_id = w.waste_id WHERE m.recycler_id = ? GROUP BY w.category";
            matchQuery = "SELECT status, COUNT(*) as cnt, SUM(profit_estimate) as profit, SUM(co2_saved_kg) as co2 FROM MATCHES WHERE recycler_id = ? GROUP BY status";
            monthlyQuery = "SELECT DATE_FORMAT(matched_at, '%b %Y') as month_yr, COUNT(*) as cnt FROM MATCHES WHERE recycler_id = ? GROUP BY month_yr ORDER BY MIN(matched_at) ASC LIMIT 6";
        }

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Category Counts
            try (PreparedStatement ps = conn.prepareStatement(wasteQuery)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        categoryCounts.put(rs.getString("category"), rs.getInt("cnt"));
                    }
                }
            }

            // 2. Match Status Counts & Totals
            try (PreparedStatement ps = conn.prepareStatement(matchQuery)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String status = rs.getString("status");
                        int cnt = rs.getInt("cnt");
                        statusCounts.put(status, cnt);
                        
                        totalTransactions += cnt;
                        totalProfitEstimate += rs.getDouble("profit");
                        totalCo2Saved += rs.getDouble("co2");
                    }
                }
            }

            // 3. Monthly Activity
            try (PreparedStatement ps = conn.prepareStatement(monthlyQuery)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        monthlyActivity.put(rs.getString("month_yr"), rs.getInt("cnt"));
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Set attributes
        req.setAttribute("categoryCounts", categoryCounts);
        req.setAttribute("statusCounts", statusCounts);
        req.setAttribute("monthlyActivity", monthlyActivity);
        req.setAttribute("totalCo2Saved", totalCo2Saved);
        req.setAttribute("totalProfitEstimate", totalProfitEstimate);
        req.setAttribute("totalTransactions", totalTransactions);

        req.getRequestDispatcher("analytics.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        doGet(req, res);
    }
}
