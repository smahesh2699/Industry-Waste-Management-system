package com.wastelink.servlet.admin;

import com.wastelink.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet(urlPatterns = {"/admin/analytics", "/admin/dashboard"})
public class AdminAnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        int totalUsers = 0;
        int totalListings = 0;
        int totalMatches = 0;
        double totalCo2Saved = 0.0;

        try (Connection conn = DBConnection.getConnection()) {
            // Total Users
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM USERS");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalUsers = rs.getInt(1);
            }
            // Total Listings
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM WASTE");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalListings = rs.getInt(1);
            }
            // Total Matches
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM MATCHES");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalMatches = rs.getInt(1);
            }
            // Total CO2 saved
            try (PreparedStatement ps = conn.prepareStatement("SELECT SUM(co2_saved_kg) FROM MATCHES WHERE status = 'ACCEPTED'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalCo2Saved = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalListings", totalListings);
        req.setAttribute("totalMatches", totalMatches);
        req.setAttribute("totalCo2Saved", totalCo2Saved);

        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, res);
    }
}
