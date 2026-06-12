package com.wastelink.servlet;

import com.wastelink.dao.WasteDAO;
import com.wastelink.model.Waste;
import com.wastelink.model.User;
import com.wastelink.util.LocationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/marketplace")
public class MarketplaceServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        WasteDAO wasteDAO = new WasteDAO();
        List<Waste> allAvailable = wasteDAO.getAllAvailable();
        List<Waste> filtered = new ArrayList<>();

        // Get filter params
        String query = req.getParameter("searchQuery");
        String category = req.getParameter("category");
        String maxPriceStr = req.getParameter("maxPrice");
        String maxDistanceStr = req.getParameter("maxDistance");

        double maxPrice = -1;
        try {
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                maxPrice = Double.parseDouble(maxPriceStr);
            }
        } catch (NumberFormatException e) {
            // ignore
        }

        double maxDistance = -1;
        try {
            if (maxDistanceStr != null && !maxDistanceStr.trim().isEmpty()) {
                maxDistance = Double.parseDouble(maxDistanceStr);
            }
        } catch (NumberFormatException e) {
            // ignore
        }

        for (Waste w : allAvailable) {
            // Filter by search query
            if (query != null && !query.trim().isEmpty()) {
                String q = query.toLowerCase();
                boolean matchesQuery = (w.getWasteType() != null && w.getWasteType().toLowerCase().contains(q)) ||
                                       (w.getDescription() != null && w.getDescription().toLowerCase().contains(q));
                if (!matchesQuery) continue;
            }

            // Filter by category
            if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("ALL")) {
                if (!category.equalsIgnoreCase(w.getCategory())) {
                    continue;
                }
            }

            // Filter by price
            if (maxPrice > 0) {
                if (w.getPricePerKg() > maxPrice) {
                    continue;
                }
            }

            // Filter by distance
            if (maxDistance > 0) {
                double distance = LocationUtil.haversineDistance(
                    user.getLatitude(), user.getLongitude(),
                    w.getLatitude(), w.getLongitude()
                );
                if (distance > maxDistance) {
                    continue;
                }
            }

            filtered.add(w);
        }

        req.setAttribute("listings", filtered);
        req.getRequestDispatcher("marketplace.jsp").forward(req, res);
    }
}
