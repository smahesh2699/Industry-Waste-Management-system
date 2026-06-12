package com.wastelink.servlet;

import com.wastelink.dao.UserDAO;
import com.wastelink.dao.RecyclerDAO;
import com.wastelink.model.User;
import com.wastelink.model.Recycler;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        int userId = sessionUser.getUserId();

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getById(userId);

        user.setFullName(req.getParameter("fullName"));
        user.setCompanyName(req.getParameter("companyName"));
        user.setPhone(req.getParameter("phone"));
        user.setCity(req.getParameter("city"));
        user.setState(req.getParameter("state"));
        
        try {
            user.setLatitude(Double.parseDouble(req.getParameter("latitude")));
            user.setLongitude(Double.parseDouble(req.getParameter("longitude")));
        } catch (Exception e) {
            // keep old coords
        }

        boolean userUpdated = userDAO.updateUser(user);

        // If Recycler, also update recycler-specific details
        if ("RECYCLER".equals(user.getRole())) {
            RecyclerDAO recyclerDAO = new RecyclerDAO();
            Recycler recycler = recyclerDAO.getByUserId(userId);
            if (recycler == null) {
                recycler = new Recycler();
                recycler.setUserId(userId);
            }
            
            // Build string for accepted categories
            String[] categories = req.getParameterValues("acceptedCategories");
            String acceptedCats = "";
            if (categories != null) {
                acceptedCats = String.join(",", categories);
            }
            
            recycler.setAcceptedCategories(acceptedCats);
            try {
                recycler.setCapacityKg(Double.parseDouble(req.getParameter("capacity")));
            } catch (Exception e) {
                recycler.setCapacityKg(0.0);
            }
            recycler.setCertification(req.getParameter("certification"));
            recycler.setBio(req.getParameter("bio"));

            recyclerDAO.updateProfile(recycler);
        }

        // Refresh session user data
        session.setAttribute("user", userDAO.getById(userId));
        res.sendRedirect("profile.jsp?updated=true");
    }
}
