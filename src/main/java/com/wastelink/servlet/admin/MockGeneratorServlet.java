package com.wastelink.servlet.admin;

import com.wastelink.db.DBConnection;
import com.wastelink.model.User;
import com.wastelink.util.AuditLogger;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

@WebServlet("/admin/mock-generator")
public class MockGeneratorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        User loggedUser = (User) session.getAttribute("user");
        if (!"ADMIN".equals(loggedUser.getRole())) {
            res.sendRedirect(req.getContextPath() + "/index.jsp?error=Access+Denied");
            return;
        }

        String action = req.getParameter("action");
        if ("populate".equalsIgnoreCase(action)) {
            boolean success = populateMockData();
            if (success) {
                AuditLogger.log(loggedUser.getUserId(), "POPULATE_MOCK_DATA", "USERS", 0, "Seeded demo mock data for project review");
                res.sendRedirect(req.getContextPath() + "/admin-dashboard.jsp?success=Mock+data+seeded+successfully!");
            } else {
                res.sendRedirect(req.getContextPath() + "/admin-dashboard.jsp?error=Failed+to+seed+mock+data");
            }
        } else if ("reset".equalsIgnoreCase(action)) {
            boolean success = resetDatabase();
            if (success) {
                AuditLogger.log(loggedUser.getUserId(), "RESET_DATABASE", "USERS", 0, "Reset platform database to clean state");
                res.sendRedirect(req.getContextPath() + "/admin-dashboard.jsp?success=Database+reset+complete!");
            } else {
                res.sendRedirect(req.getContextPath() + "/admin-dashboard.jsp?error=Failed+to+reset+database");
            }
        } else {
            res.sendRedirect(req.getContextPath() + "/admin-dashboard.jsp");
        }
    }

    private boolean populateMockData() {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (Statement stmt = conn.createStatement()) {
                // Clear any transactional data but keep basic users (1, 2, 3)
                stmt.addBatch("SET FOREIGN_KEY_CHECKS = 0;");
                stmt.addBatch("TRUNCATE TABLE ADMIN_LOGS;");
                stmt.addBatch("TRUNCATE TABLE NOTIFICATIONS;");
                stmt.addBatch("TRUNCATE TABLE MATCHES;");
                stmt.addBatch("DELETE FROM RECYCLER WHERE user_id > 3;");
                stmt.addBatch("TRUNCATE TABLE WASTE;");
                stmt.addBatch("DELETE FROM USERS WHERE user_id > 3;");
                stmt.addBatch("SET FOREIGN_KEY_CHECKS = 1;");

                // Insert Mock Users (Industries 4, 5, 6; Recyclers 7, 8, 9)
                stmt.addBatch("INSERT INTO USERS (user_id, full_name, email, password, role, company_name, phone, city, state, latitude, longitude) VALUES " +
                    "(4, 'TechCorp Electronics', 'industry_tech@wastelink.com', 'pass123', 'INDUSTRY', 'TechCorp Electronics Ltd', '9911223344', 'Bengaluru', 'Karnataka', 12.9805, 77.6055), " +
                    "(5, 'BioChem Industries', 'industry_chem@wastelink.com', 'pass123', 'INDUSTRY', 'BioChem Industries Ltd', '9911223355', 'Bengaluru', 'Karnataka', 12.9602, 77.5841), " +
                    "(6, 'MetalWorks Corp', 'industry_metal@wastelink.com', 'pass123', 'INDUSTRY', 'MetalWorks Corp', '9911223366', 'Bengaluru', 'Karnataka', 12.9912, 77.6120), " +
                    "(7, 'E-Waste Solutions Ltd', 'recycler_ewaste@wastelink.com', 'pass123', 'RECYCLER', 'E-Waste Solutions Ltd', '9911223377', 'Bengaluru', 'Karnataka', 12.9344, 77.6200), " +
                    "(8, 'BioSafe Organics', 'recycler_bio@wastelink.com', 'pass123', 'RECYCLER', 'BioSafe Organics Ltd', '9911223388', 'Bengaluru', 'Karnataka', 12.9510, 77.6350), " +
                    "(9, 'PaperBack Recycling', 'recycler_paper@wastelink.com', 'pass123', 'RECYCLER', 'PaperBack Recycling Ltd', '9911223399', 'Bengaluru', 'Karnataka', 12.9212, 77.6015);");

                // Insert Recycler Profiles
                stmt.addBatch("INSERT INTO RECYCLER (user_id, accepted_categories, capacity_kg, certification, bio) VALUES " +
                    "(7, 'ELECTRONIC,METAL', 8000.0, 'ISO-27001 Certified', 'Secure and environment-friendly electronics processing.'), " +
                    "(8, 'ORGANIC,OTHER', 4000.0, 'Organic Bio-Safeguard', 'Composting and organic recycling aggregates.'), " +
                    "(9, 'PAPER,PLASTIC', 12000.0, 'FSC and ISO-14001', 'Eco-safe paper pulping and plastic extrusion.');");

                // Insert Waste Listings
                stmt.addBatch("INSERT INTO WASTE (waste_id, user_id, waste_type, category, quantity_kg, price_per_kg, description, location, latitude, longitude, status) VALUES " +
                    "(1, 2, 'Scrap Steel Rods', 'METAL', 1200, 18.5, 'Structural steel pipe offcuts from construction site.', 'Ballari, Karnataka', 12.9716, 77.5946, 'SOLD'), " +
                    "(2, 2, 'Cardboard Storage Boxes', 'PAPER', 850, 5.0, 'Corrugated packaging boxes, flattened.', 'Ballari, Karnataka', 12.9716, 77.5946, 'SOLD'), " +
                    "(3, 4, 'Defective Printed Circuits', 'ELECTRONIC', 350, 45.0, 'Mixed motherboard scraps containing heavy metals.', 'Bengaluru, Karnataka', 12.9805, 77.6055, 'AVAILABLE'), " +
                    "(4, 5, 'Spent Plastic Containers', 'PLASTIC', 1500, 12.0, 'High-density polyethylene drums.', 'Bengaluru, Karnataka', 12.9602, 77.5841, 'MATCHED'), " +
                    "(5, 5, 'Organic Sludge', 'ORGANIC', 2200, 2.5, 'Biodegradable agricultural residue.', 'Bengaluru, Karnataka', 12.9602, 77.5841, 'MATCHED'), " +
                    "(6, 6, 'Aluminium Castings', 'METAL', 950, 35.0, 'Machine block housings and castings.', 'Bengaluru, Karnataka', 12.9912, 77.6120, 'AVAILABLE'), " +
                    "(7, 6, 'Copper Wiring Scraps', 'METAL', 450, 75.0, 'Pure copper wire offcuts stripped.', 'Bengaluru, Karnataka', 12.9912, 77.6120, 'SOLD'), " +
                    "(8, 2, 'Low-Density Polyethylene Sheets', 'PLASTIC', 1800, 15.0, 'Shrink wraps and packaging material.', 'Ballari, Karnataka', 12.9716, 77.5946, 'AVAILABLE');");

                // Insert Matches
                stmt.addBatch("INSERT INTO MATCHES (match_id, waste_id, recycler_id, industry_user_id, status, profit_estimate, co2_saved_kg) VALUES " +
                    "(1, 1, 3, 2, 'COMPLETED', 21000.0, 2200.0), " +
                    "(2, 2, 9, 2, 'COMPLETED', 3850.0, 950.0), " +
                    "(3, 4, 9, 5, 'ACCEPTED', 17200.0, 3750.0), " +
                    "(4, 5, 8, 5, 'PENDING', 4900.0, 1100.0), " +
                    "(5, 7, 3, 6, 'COMPLETED', 32000.0, 1800.0);");

                // Add Notifications
                stmt.addBatch("INSERT INTO NOTIFICATIONS (user_id, message, is_read) VALUES " +
                    "(2, 'Your steel rods listing has been matched with Apex Recycling.', 0), " +
                    "(3, 'New metal listing match request pending approval.', 0), " +
                    "(5, 'Reviewer mock match completed successfully.', 0);");

                stmt.executeBatch();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean resetDatabase() {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (Statement stmt = conn.createStatement()) {
                stmt.addBatch("SET FOREIGN_KEY_CHECKS = 0;");
                stmt.addBatch("TRUNCATE TABLE ADMIN_LOGS;");
                stmt.addBatch("TRUNCATE TABLE NOTIFICATIONS;");
                stmt.addBatch("TRUNCATE TABLE MATCHES;");
                stmt.addBatch("DELETE FROM RECYCLER WHERE user_id > 3;");
                stmt.addBatch("TRUNCATE TABLE WASTE;");
                stmt.addBatch("DELETE FROM USERS WHERE user_id > 3;");
                stmt.addBatch("SET FOREIGN_KEY_CHECKS = 1;");
                stmt.executeBatch();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
