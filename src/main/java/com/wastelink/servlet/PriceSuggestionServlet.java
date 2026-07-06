package com.wastelink.servlet;

import com.wastelink.db.DBConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/price-suggestion")
public class PriceSuggestionServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();

        String category = req.getParameter("category");
        if (category == null || category.trim().isEmpty()) {
            out.print("{\"error\":\"Invalid category\"}");
            return;
        }

        double avgPrice = 0.0;
        boolean found = false;

        // 1. Try to find the average price of matched/sold items in the category
        String queryMatched = "SELECT AVG(price_per_kg) FROM WASTE WHERE category = ? AND status IN ('MATCHED', 'SOLD')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(queryMatched)) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    avgPrice = rs.getDouble(1);
                    if (avgPrice > 0) {
                        found = true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 2. Fallback to average of all listings in that category
        if (!found) {
            String queryAll = "SELECT AVG(price_per_kg) FROM WASTE WHERE category = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(queryAll)) {
                ps.setString(1, category);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        avgPrice = rs.getDouble(1);
                        if (avgPrice > 0) {
                            found = true;
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // 3. Fallback to default base values if no records exist in the DB
        if (!found) {
            switch (category.toUpperCase()) {
                case "METAL":
                    avgPrice = 20.00;
                    break;
                case "PLASTIC":
                    avgPrice = 14.50;
                    break;
                case "PAPER":
                    avgPrice = 7.00;
                    break;
                case "ELECTRONIC":
                    avgPrice = 45.00;
                    break;
                case "CHEMICAL":
                    avgPrice = 30.00;
                    break;
                case "ORGANIC":
                    avgPrice = 5.00;
                    break;
                default:
                    avgPrice = 12.00;
            }
        }

        out.print("{\"status\":\"success\",\"average\":" + String.format("%.2f", avgPrice) + "}");
    }
}
