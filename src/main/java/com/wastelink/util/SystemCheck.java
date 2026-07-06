package com.wastelink.util;

import com.wastelink.db.DBConnection;
import com.wastelink.dao.UserDAO;
import com.wastelink.dao.WasteDAO;
import com.wastelink.dao.MatchDAO;
import com.wastelink.model.User;
import com.wastelink.model.Waste;
import java.sql.Connection;
import java.util.List;

public class SystemCheck {

    public static void main(String[] args) {
        System.out.println("=================================================");
        System.out.println("          🌿 WasteLink Module Verification 🌿    ");
        System.out.println("=================================================");
        System.out.println();

        boolean allPassed = true;

        // 1. Test DB Connection
        System.out.print("[TEST 1] Database Connection: ");
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("PASSED (Successfully connected to wastelink_db)");
            } else {
                System.out.println("FAILED (Connection returned null)");
                allPassed = false;
            }
        } catch (Exception e) {
            System.out.println("FAILED (Exception: " + e.getMessage() + ")");
            allPassed = false;
        }

        // 2. Test User Authentication (UserDAO)
        System.out.print("[TEST 2] User authentication (UserDAO): ");
        try {
            UserDAO userDAO = new UserDAO();
            User ind = userDAO.authenticate("industry@wastelink.com", "pass123");
            User rec = userDAO.authenticate("recycler@wastelink.com", "pass123");
            if (ind != null && rec != null && "INDUSTRY".equals(ind.getRole()) && "RECYCLER".equals(rec.getRole())) {
                System.out.println("PASSED (Industry & Recycler accounts authenticated)");
            } else {
                System.out.println("FAILED (Authentication failed or returned incorrect roles)");
                allPassed = false;
            }
        } catch (Exception e) {
            System.out.println("FAILED (Exception: " + e.getMessage() + ")");
            allPassed = false;
        }

        // 3. Test Waste Listings (WasteDAO)
        System.out.print("[TEST 3] Fetching Waste Listings (WasteDAO): ");
        try {
            WasteDAO wasteDAO = new WasteDAO();
            List<Waste> list = wasteDAO.getAllAvailable();
            System.out.println("PASSED (Found " + list.size() + " active listings in system)");
        } catch (Exception e) {
            System.out.println("FAILED (Exception: " + e.getMessage() + ")");
            allPassed = false;
        }

        // 4. Test Geolocation (LocationUtil)
        System.out.print("[TEST 4] Geolocation Haversine Distance: ");
        try {
            // Distance between Bengaluru (12.9716, 77.5946) and Koramangala (12.9352, 77.6245) is approx 5-6 km
            double dist = LocationUtil.haversineDistance(12.9716, 77.5946, 12.9352, 77.6245);
            if (dist > 4.0 && dist < 6.0) {
                System.out.println("PASSED (Distance computed correctly: " + String.format("%.2f", dist) + " km)");
            } else {
                System.out.println("FAILED (Calculated incorrect distance: " + dist + " km)");
                allPassed = false;
            }
        } catch (Exception e) {
            System.out.println("FAILED (Exception: " + e.getMessage() + ")");
            allPassed = false;
        }

        // 5. Test Margin Estimator (ProfitUtil)
        System.out.print("[TEST 5] Trade Profit Estimator: ");
        try {
            // Qty=1000, Price=10. Gross=10000. Handling=800. Transport=500. Net=8700
            double profit = ProfitUtil.estimateProfit(1000, 10);
            if (profit == 8700.0) {
                System.out.println("PASSED (Formula result verified: \u20B9" + profit + ")");
            } else {
                System.out.println("FAILED (Calculated incorrect profit: \u20B9" + profit + ")");
                allPassed = false;
            }
        } catch (Exception e) {
            System.out.println("FAILED (Exception: " + e.getMessage() + ")");
            allPassed = false;
        }

        // 6. Test Sustainability metrics (ImpactUtil)
        System.out.print("[TEST 6] Sustainability CO2 Offsets: ");
        try {
            double co2 = ImpactUtil.co2SavedKg("PLASTIC", 100); // 100 * 2.5 = 250
            double score = ImpactUtil.sustainabilityScore(co2, 100);
            if (co2 == 250.0 && score > 0) {
                System.out.println("PASSED (CO2 savings calculated: " + co2 + " kg, Sustainability score: " + String.format("%.1f", score) + "%)");
            } else {
                System.out.println("FAILED (Calculated incorrect metrics)");
                allPassed = false;
            }
        } catch (Exception e) {
            System.out.println("FAILED (Exception: " + e.getMessage() + ")");
            allPassed = false;
        }

        System.out.println();
        System.out.println("=================================================");
        if (allPassed) {
            System.out.println("      [PASSED] ALL MODULES ARE WORKING SUCCESSFULLY!   ");
        } else {
            System.out.println("      [FAILED] SYSTEM HAS MODULE ERRORS. CHECK LOGS.  ");
        }
        System.out.println("=================================================");
    }
}
