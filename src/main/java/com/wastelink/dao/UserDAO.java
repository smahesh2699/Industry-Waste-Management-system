package com.wastelink.dao;

import com.wastelink.db.DBConnection;
import com.wastelink.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    
    public boolean registerUser(User user) {
        String query = "INSERT INTO USERS (full_name, email, password, role, company_name, phone, city, state, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getRole());
            ps.setString(5, user.getCompanyName());
            ps.setString(6, user.getPhone());
            ps.setString(7, user.getCity());
            ps.setString(8, user.getState());
            ps.setDouble(9, user.getLatitude());
            ps.setDouble(10, user.getLongitude());
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setUserId(rs.getInt(1));
                    }
                }
                
                // If it is a recycler, also create a blank recycler profile
                if ("RECYCLER".equalsIgnoreCase(user.getRole())) {
                    createDefaultRecyclerProfile(user.getUserId());
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void createDefaultRecyclerProfile(int userId) {
        String query = "INSERT INTO RECYCLER (user_id, accepted_categories, capacity_kg, certification, bio) VALUES (?, '', 0.0, '', '')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public User authenticate(String email, String password) {
        String query = "SELECT * FROM USERS WHERE email = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getById(int userId) {
        String query = "SELECT * FROM USERS WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateUser(User user) {
        String query = "UPDATE USERS SET full_name = ?, company_name = ?, phone = ?, city = ?, state = ?, latitude = ?, longitude = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getCompanyName());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getCity());
            ps.setString(5, user.getState());
            ps.setDouble(6, user.getLatitude());
            ps.setDouble(7, user.getLongitude());
            ps.setInt(8, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getRecyclersByCategory(String category) {
        List<User> list = new ArrayList<>();
        String query = "SELECT u.* FROM USERS u JOIN RECYCLER r ON u.user_id = r.user_id WHERE u.role = 'RECYCLER' AND r.accepted_categories LIKE ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, "%" + category + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));
        u.setCompanyName(rs.getString("company_name"));
        u.setPhone(rs.getString("phone"));
        u.setCity(rs.getString("city"));
        u.setState(rs.getString("state"));
        u.setLatitude(rs.getDouble("latitude"));
        u.setLongitude(rs.getDouble("longitude"));
        return u;
    }
}
