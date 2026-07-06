package com.wastelink.util;

import com.wastelink.db.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AuditLogger {
    public static void log(int adminId, String action, String targetTable, int targetId, String details) {
        String sql = "INSERT INTO ADMIN_LOGS (admin_id, action, target_table, target_id, details) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setString(2, action);
            ps.setString(3, targetTable);
            ps.setInt(4, targetId);
            ps.setString(5, details);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("AuditLogger failed: " + e.getMessage());
        }
    }
}
