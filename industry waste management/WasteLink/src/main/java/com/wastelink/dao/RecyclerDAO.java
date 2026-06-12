package com.wastelink.dao;

import com.wastelink.db.DBConnection;
import com.wastelink.model.Recycler;
import java.sql.*;

public class RecyclerDAO {

    public Recycler getByUserId(int userId) {
        String query = "SELECT * FROM RECYCLER WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Recycler r = new Recycler();
                    r.setRecyclerId(rs.getInt("recycler_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setAcceptedCategories(rs.getString("accepted_categories"));
                    r.setCapacityKg(rs.getDouble("capacity_kg"));
                    r.setCertification(rs.getString("certification"));
                    r.setBio(rs.getString("bio"));
                    return r;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProfile(Recycler recycler) {
        String query = "UPDATE RECYCLER SET accepted_categories = ?, capacity_kg = ?, certification = ?, bio = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, recycler.getAcceptedCategories());
            ps.setDouble(2, recycler.getCapacityKg());
            ps.setString(3, recycler.getCertification());
            ps.setString(4, recycler.getBio());
            ps.setInt(5, recycler.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
