package com.wastelink.servlet;

import com.wastelink.dao.UserDAO;
import com.wastelink.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        UserDAO dao = new UserDAO();
        User user = dao.authenticate(email, password);

        if (user != null) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("role", user.getRole());

            if ("INDUSTRY".equals(user.getRole())) {
                res.sendRedirect("industry-dashboard.jsp");
            } else {
                res.sendRedirect("recycler-dashboard.jsp");
            }
        } else {
            res.sendRedirect("login.jsp?error=Invalid+credentials");
        }
    }
}
