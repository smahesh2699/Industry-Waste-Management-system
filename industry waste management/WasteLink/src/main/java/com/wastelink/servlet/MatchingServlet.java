package com.wastelink.servlet;

import com.wastelink.dao.*;
import com.wastelink.model.*;
import com.wastelink.util.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/match")
public class MatchingServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        int wasteId = Integer.parseInt(req.getParameter("wasteId"));
        double radiusKm = 100.0; // default radius
        try {
            radiusKm = Double.parseDouble(req.getParameter("radius"));
        } catch (Exception e) {
            // keep default
        }

        WasteDAO wasteDAO = new WasteDAO();
        UserDAO userDAO = new UserDAO();
        MatchDAO matchDAO = new MatchDAO();

        Waste waste = wasteDAO.getById(wasteId);
        if (waste == null) {
            res.sendRedirect("my-listings.jsp?error=Listing+not+found");
            return;
        }

        List<User> recyclers = userDAO.getRecyclersByCategory(waste.getCategory());

        int matchCount = 0;
        for (User recycler : recyclers) {
            // Avoid matching with themselves (though they should be role-based, double check)
            if (recycler.getUserId() == waste.getUserId()) {
                continue;
            }

            boolean nearby = LocationUtil.isWithinRadius(
                waste.getLatitude(), waste.getLongitude(),
                recycler.getLatitude(), recycler.getLongitude(),
                radiusKm
            );
            if (nearby) {
                Match match = new Match();
                match.setWasteId(wasteId);
                match.setRecyclerId(recycler.getUserId());
                match.setIndustryUserId(waste.getUserId());
                match.setStatus("PENDING");
                match.setProfitEstimate(ProfitUtil.estimateProfit(waste.getQuantityKg(), waste.getPricePerKg()));
                match.setCo2SavedKg(ImpactUtil.co2SavedKg(waste.getCategory(), waste.getQuantityKg()));
                
                boolean created = matchDAO.createMatch(match);
                if (created) {
                    matchCount++;
                }
            }
        }

        res.sendRedirect("my-listings.jsp?matches=" + matchCount);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        doPost(req, res);
    }
}
