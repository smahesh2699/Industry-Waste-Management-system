package com.wastelink.servlet;

import com.wastelink.dao.WasteDAO;
import com.wastelink.model.Waste;
import com.wastelink.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/manage-waste")
public class ManageWasteServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");
        int wasteId = Integer.parseInt(req.getParameter("wasteId"));
        WasteDAO dao = new WasteDAO();

        if ("delete".equalsIgnoreCase(action)) {
            boolean success = dao.deleteWaste(wasteId);
            res.sendRedirect("my-listings.jsp?deleted=" + success);
        } else {
            res.sendRedirect("my-listings.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        int wasteId = Integer.parseInt(req.getParameter("wasteId"));
        WasteDAO dao = new WasteDAO();
        Waste waste = dao.getById(wasteId);

        if (waste != null) {
            waste.setWasteType(req.getParameter("wasteType"));
            waste.setCategory(req.getParameter("category"));
            try {
                waste.setQuantityKg(Double.parseDouble(req.getParameter("quantity")));
                waste.setPricePerKg(Double.parseDouble(req.getParameter("price")));
                waste.setLatitude(Double.parseDouble(req.getParameter("latitude")));
                waste.setLongitude(Double.parseDouble(req.getParameter("longitude")));
            } catch (Exception e) {
                // Keep existing values
            }
            waste.setDescription(req.getParameter("description"));
            waste.setLocation(req.getParameter("location"));
            waste.setStatus(req.getParameter("status"));

            boolean success = dao.updateWaste(waste);
            res.sendRedirect("my-listings.jsp?updated=" + success);
        } else {
            res.sendRedirect("my-listings.jsp?error=Listing+not+found");
        }
    }
}
