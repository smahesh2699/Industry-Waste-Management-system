package com.wastelink.servlet;

import com.wastelink.dao.WasteDAO;
import com.wastelink.model.Waste;
import com.wastelink.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/add-waste")
public class AddWasteServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        Waste waste = new Waste();
        waste.setUserId(user.getUserId());
        waste.setWasteType(req.getParameter("wasteType"));
        waste.setCategory(req.getParameter("category"));
        
        try {
            waste.setQuantityKg(Double.parseDouble(req.getParameter("quantity")));
            waste.setPricePerKg(Double.parseDouble(req.getParameter("price")));
            waste.setLatitude(Double.parseDouble(req.getParameter("latitude")));
            waste.setLongitude(Double.parseDouble(req.getParameter("longitude")));
        } catch (Exception e) {
            waste.setQuantityKg(0.0);
            waste.setPricePerKg(0.0);
            waste.setLatitude(user.getLatitude());
            waste.setLongitude(user.getLongitude());
        }
        
        waste.setDescription(req.getParameter("description"));
        waste.setLocation(req.getParameter("location"));
        waste.setStatus("AVAILABLE");

        WasteDAO dao = new WasteDAO();
        boolean success = dao.addWaste(waste);
        if (success) {
            res.sendRedirect("my-listings.jsp?added=true");
        } else {
            res.sendRedirect("add-waste.jsp?error=Failed+to+post+listing");
        }
    }
}
