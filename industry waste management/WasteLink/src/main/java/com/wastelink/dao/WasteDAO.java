package com.wastelink.dao;

import com.wastelink.db.DBConnection;
import com.wastelink.model.Waste;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WasteDAO {

    public boolean addWaste(Waste waste) {
        String query = "INSERT INTO WASTE (user_id, waste_type, category, quantity_kg, price_per_kg, description, location, latitude, longitude, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, waste.getUserId());
            ps.setString(2, waste.getWasteType());
            ps.setString(3, waste.getCategory());
            ps.setDouble(4, waste.getQuantityKg());
            ps.setDouble(5, waste.getPricePerKg());
            ps.setString(6, waste.getDescription());
            ps.setString(7, waste.getLocation());
            ps.setDouble(8, waste.getLatitude());
            ps.setDouble(9, waste.getLongitude());
            ps.setString(10, waste.getStatus() != null ? waste.getStatus() : "AVAILABLE");
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        waste.setWasteId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Waste getById(int wasteId) {
        String query = "SELECT * FROM WASTE WHERE waste_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, wasteId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapWaste(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Waste> getByUserId(int userId) {
        List<Waste> list = new ArrayList<>();
        String query = "SELECT * FROM WASTE WHERE user_id = ? ORDER BY listed_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapWaste(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Waste> getAllAvailable() {
        List<Waste> list = new ArrayList<>();
        String query = "SELECT * FROM WASTE WHERE status = 'AVAILABLE' ORDER BY listed_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapWaste(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateWaste(Waste waste) {
        String query = "UPDATE WASTE SET waste_type = ?, category = ?, quantity_kg = ?, price_per_kg = ?, description = ?, location = ?, latitude = ?, longitude = ?, status = ? WHERE waste_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, waste.getWasteType());
            ps.setString(2, waste.getCategory());
            ps.setDouble(3, waste.getQuantityKg());
            ps.setDouble(4, waste.getPricePerKg());
            ps.setString(5, waste.getDescription());
            ps.setString(6, waste.getLocation());
            ps.setDouble(7, waste.getLatitude());
            ps.setDouble(8, waste.getLongitude());
            ps.setString(9, waste.getStatus());
            ps.setInt(10, waste.getWasteId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int wasteId, String status) {
        String query = "UPDATE WASTE SET status = ? WHERE waste_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, status);
            ps.setInt(2, wasteId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteWaste(int wasteId) {
        String query = "DELETE FROM WASTE WHERE waste_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, wasteId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Waste mapWaste(ResultSet rs) throws SQLException {
        Waste w = new Waste();
        w.setWasteId(rs.getInt("waste_id"));
        w.setUserId(rs.getInt("user_id"));
        w.setWasteType(rs.getString("waste_type"));
        w.setCategory(rs.getString("category"));
        w.setQuantityKg(rs.getDouble("quantity_kg"));
        w.setPricePerKg(rs.getDouble("price_per_kg"));
        w.setDescription(rs.getString("description"));
        w.setLocation(rs.getString("location"));
        w.setLatitude(rs.getDouble("latitude"));
        w.setLongitude(rs.getDouble("longitude"));
        w.setStatus(rs.getString("status"));
        w.setListedAt(rs.getTimestamp("listed_at"));
        return w;
    }
}
