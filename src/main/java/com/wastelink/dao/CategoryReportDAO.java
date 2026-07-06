package com.wastelink.dao;

import com.wastelink.db.DBConnection;
import com.wastelink.model.CategoryUserSummary;
import java.sql.*;
import java.util.*;

public class CategoryReportDAO {

    public Map<String, List<CategoryUserSummary>> getListingsByCategory() {
        Map<String, List<CategoryUserSummary>> report = new LinkedHashMap<>();
        String sql = "SELECT w.category, u.user_id, u.company_name, u.role, " +
                     "SUM(w.quantity_kg) AS total_qty, COUNT(DISTINCT w.waste_id) AS cnt " +
                     "FROM WASTE w " +
                     "JOIN USERS u ON w.user_id = u.user_id " +
                     "GROUP BY w.category, u.user_id " +
                     "ORDER BY w.category, total_qty DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String category = rs.getString("category");
                CategoryUserSummary summary = new CategoryUserSummary();
                summary.setCategory(category);
                summary.setUserId(rs.getInt("user_id"));
                summary.setCompanyName(rs.getString("company_name"));
                summary.setRole(rs.getString("role"));
                summary.setTotalQuantityKg(rs.getDouble("total_qty"));
                summary.setCount(rs.getInt("cnt"));

                report.computeIfAbsent(category, k -> new ArrayList<>()).add(summary);
            }

            // Compute percentage share
            for (List<CategoryUserSummary> list : report.values()) {
                double total = getCategoryTotal(list);
                for (CategoryUserSummary sum : list) {
                    if (total > 0) {
                        double share = (sum.getTotalQuantityKg() / total) * 100;
                        sum.setPercentageShare(Math.round(share * 10.0) / 10.0);
                    } else {
                        sum.setPercentageShare(0.0);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }

    public Map<String, List<CategoryUserSummary>> getRecyclerSharePerCategory() {
        Map<String, List<CategoryUserSummary>> report = new LinkedHashMap<>();
        String sql = "SELECT w.category, u.user_id, u.company_name, u.role, " +
                     "SUM(w.quantity_kg) AS total_qty, COUNT(DISTINCT m.match_id) AS cnt " +
                     "FROM MATCHES m " +
                     "JOIN WASTE w ON m.waste_id = w.waste_id " +
                     "JOIN USERS u ON m.recycler_id = u.user_id " +
                     "WHERE m.status IN ('ACCEPTED','COMPLETED') " +
                     "GROUP BY w.category, u.user_id " +
                     "ORDER BY w.category, total_qty DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String category = rs.getString("category");
                CategoryUserSummary summary = new CategoryUserSummary();
                summary.setCategory(category);
                summary.setUserId(rs.getInt("user_id"));
                summary.setCompanyName(rs.getString("company_name"));
                summary.setRole(rs.getString("role"));
                summary.setTotalQuantityKg(rs.getDouble("total_qty"));
                summary.setCount(rs.getInt("cnt"));

                report.computeIfAbsent(category, k -> new ArrayList<>()).add(summary);
            }

            // Compute percentage share
            for (List<CategoryUserSummary> list : report.values()) {
                double total = getCategoryTotal(list);
                for (CategoryUserSummary sum : list) {
                    if (total > 0) {
                        double share = (sum.getTotalQuantityKg() / total) * 100;
                        sum.setPercentageShare(Math.round(share * 10.0) / 10.0);
                    } else {
                        sum.setPercentageShare(0.0);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }

    public List<CategoryUserSummary> getRecyclerShareForCategory(String category) {
        Map<String, List<CategoryUserSummary>> all = getRecyclerSharePerCategory();
        return all.getOrDefault(category, new ArrayList<>());
    }

    public double getCategoryTotal(List<CategoryUserSummary> usersInCategory) {
        double total = 0.0;
        if (usersInCategory != null) {
            for (CategoryUserSummary summary : usersInCategory) {
                total += summary.getTotalQuantityKg();
            }
        }
        return total;
    }
}
