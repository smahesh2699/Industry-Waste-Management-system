package com.wastelink.dao;

import com.wastelink.db.DBConnection;
import com.wastelink.model.Match;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MatchDAO {

    public boolean createMatch(Match match) {
        // First check if match already exists to avoid duplicates
        String checkQuery = "SELECT match_id FROM MATCHES WHERE waste_id = ? AND recycler_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkPs = conn.prepareStatement(checkQuery)) {
            checkPs.setInt(1, match.getWasteId());
            checkPs.setInt(2, match.getRecyclerId());
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    return false; // Already matched
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        String query = "INSERT INTO MATCHES (waste_id, recycler_id, industry_user_id, status, profit_estimate, co2_saved_kg) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, match.getWasteId());
            ps.setInt(2, match.getRecyclerId());
            ps.setInt(3, match.getIndustryUserId());
            ps.setString(4, match.getStatus() != null ? match.getStatus() : "PENDING");
            ps.setDouble(5, match.getProfitEstimate());
            ps.setDouble(6, match.getCo2SavedKg());
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        match.setMatchId(rs.getInt(1));
                    }
                }
                // Also trigger notification for recycler
                addNotification(match.getRecyclerId(), "New waste match found for waste listing ID: " + match.getWasteId());
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Match getById(int matchId) {
        String query = "SELECT * FROM MATCHES WHERE match_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMatch(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Match> getByRecyclerId(int recyclerId) {
        List<Match> list = new ArrayList<>();
        String query = "SELECT * FROM MATCHES WHERE recycler_id = ? ORDER BY matched_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, recyclerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMatch(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Match> getByIndustryId(int industryId) {
        List<Match> list = new ArrayList<>();
        String query = "SELECT * FROM MATCHES WHERE industry_user_id = ? ORDER BY matched_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, industryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMatch(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Match> getByWasteId(int wasteId) {
        List<Match> list = new ArrayList<>();
        String query = "SELECT * FROM MATCHES WHERE waste_id = ? ORDER BY matched_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, wasteId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMatch(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int matchId, String status) {
        String query = "UPDATE MATCHES SET status = ? WHERE match_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, status);
            ps.setInt(2, matchId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // --- Notification Helpers in DAO ---
    public void addNotification(int userId, String message) {
        String query = "INSERT INTO NOTIFICATIONS (user_id, message, is_read) VALUES (?, ?, false)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            ps.setString(2, message);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<String[]> getNotifications(int userId) {
        List<String[]> list = new ArrayList<>();
        String query = "SELECT notif_id, message, is_read, created_at FROM NOTIFICATIONS WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{
                        String.valueOf(rs.getInt("notif_id")),
                        rs.getString("message"),
                        String.valueOf(rs.getBoolean("is_read")),
                        rs.getTimestamp("created_at").toString()
                    });
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getUnreadNotificationsCount(int userId) {
        String query = "SELECT COUNT(*) FROM NOTIFICATIONS WHERE user_id = ? AND is_read = false";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean markAllNotificationsRead(int userId) {
        String query = "UPDATE NOTIFICATIONS SET is_read = true WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Match mapMatch(ResultSet rs) throws SQLException {
        Match m = new Match();
        m.setMatchId(rs.getInt("match_id"));
        m.setWasteId(rs.getInt("waste_id"));
        m.setRecyclerId(rs.getInt("recycler_id"));
        m.setIndustryUserId(rs.getInt("industry_user_id"));
        m.setStatus(rs.getString("status"));
        m.setProfitEstimate(rs.getDouble("profit_estimate"));
        m.setCo2SavedKg(rs.getDouble("co2_saved_kg"));
        m.setMatchedAt(rs.getTimestamp("matched_at"));
        return m;
    }
}
