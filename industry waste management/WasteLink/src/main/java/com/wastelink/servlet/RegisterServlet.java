package com.wastelink.servlet;

import com.wastelink.dao.UserDAO;
import com.wastelink.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        User user = new User();
        user.setFullName(req.getParameter("fullName"));
        user.setEmail(req.getParameter("email"));
        user.setPassword(req.getParameter("password")); // in production, hash password
        user.setRole(req.getParameter("role"));
        user.setCompanyName(req.getParameter("companyName"));
        user.setPhone(req.getParameter("phone"));
        user.setCity(req.getParameter("city"));
        user.setState(req.getParameter("state"));
        
        try {
            user.setLatitude(Double.parseDouble(req.getParameter("latitude")));
            user.setLongitude(Double.parseDouble(req.getParameter("longitude")));
        } catch (Exception e) {
            user.setLatitude(12.9716); // fallback to Bengaluru lat
            user.setLongitude(77.5946); // fallback to Bengaluru lon
        }

        UserDAO dao = new UserDAO();
        boolean success = dao.registerUser(user);
        if (success) {
            res.sendRedirect("login.jsp?registered=true");
        } else {
            res.sendRedirect("register.jsp?error=Email+already+exists");
        }
    }
}
