package com.wastelink.servlet;

import com.wastelink.dao.MatchDAO;
import com.wastelink.dao.WasteDAO;
import com.wastelink.dao.UserDAO;
import com.wastelink.model.Match;
import com.wastelink.model.Waste;
import com.wastelink.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/match-action")
public class MatchActionServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = req.getParameter("action");

        MatchDAO matchDAO = new MatchDAO();
        WasteDAO wasteDAO = new WasteDAO();
        UserDAO userDAO = new UserDAO();

        if ("request".equalsIgnoreCase(action)) {
            int wasteId = Integer.parseInt(req.getParameter("wasteId"));
            Waste waste = wasteDAO.getById(wasteId);
            if (waste != null) {
                Match match = new Match();
                match.setWasteId(wasteId);
                match.setRecyclerId(user.getUserId());
                match.setIndustryUserId(waste.getUserId());
                match.setStatus("PENDING");
                match.setProfitEstimate(com.wastelink.util.ProfitUtil.estimateProfit(waste.getQuantityKg(), waste.getPricePerKg()));
                match.setCo2SavedKg(com.wastelink.util.ImpactUtil.co2SavedKg(waste.getCategory(), waste.getQuantityKg()));
                
                boolean created = matchDAO.createMatch(match);
                if (created) {
                    // Notify industry user
                    matchDAO.addNotification(waste.getUserId(), 
                        user.getCompanyName() + " has requested a match for your listing: '" + waste.getWasteType() + "'.");
                    res.sendRedirect("marketplace?success=Match+request+submitted!");
                } else {
                    res.sendRedirect("marketplace?error=You+have+already+requested+a+match+for+this+listing.");
                }
            } else {
                res.sendRedirect("marketplace?error=Waste+listing+not+found.");
            }
            return;
        }

        int matchId = Integer.parseInt(req.getParameter("matchId"));
        Match match = matchDAO.getById(matchId);
        if (match != null) {
            Waste waste = wasteDAO.getById(match.getWasteId());
            User recyclerUser = userDAO.getById(match.getRecyclerId());

            if ("accept".equalsIgnoreCase(action)) {
                // Update match status to ACCEPTED
                matchDAO.updateStatus(matchId, "ACCEPTED");
                
                // Update waste listing status to MATCHED
                if (waste != null) {
                    wasteDAO.updateStatus(waste.getWasteId(), "MATCHED");
                }
                
                // Notify the industry seller
                String company = recyclerUser != null ? recyclerUser.getCompanyName() : "A Recycler";
                String wasteName = waste != null ? waste.getWasteType() : "your listing";
                matchDAO.addNotification(match.getIndustryUserId(), 
                    "Your waste listing '" + wasteName + "' has been accepted by " + company + "!");
                
            } else if ("reject".equalsIgnoreCase(action)) {
                // Update match status to REJECTED
                matchDAO.updateStatus(matchId, "REJECTED");
                
                // Optional: notify seller or do nothing
                String company = recyclerUser != null ? recyclerUser.getCompanyName() : "A Recycler";
                String wasteName = waste != null ? waste.getWasteType() : "your listing";
                matchDAO.addNotification(match.getIndustryUserId(), 
                    "Your match request for '" + wasteName + "' was declined by " + company + ".");
            }
            
            res.sendRedirect("recycler-dashboard.jsp?statusUpdated=true");
        } else {
            res.sendRedirect("recycler-dashboard.jsp?error=Match+not+found");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        doPost(req, res);
    }
}
