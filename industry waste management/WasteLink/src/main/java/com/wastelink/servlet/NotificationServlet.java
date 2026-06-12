package com.wastelink.servlet;

import com.wastelink.dao.MatchDAO;
import com.wastelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        MatchDAO matchDAO = new MatchDAO();
        
        List<String[]> notifications = matchDAO.getNotifications(user.getUserId());
        req.setAttribute("notifications", notifications);
        
        req.getRequestDispatcher("notifications.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        MatchDAO matchDAO = new MatchDAO();
        
        String action = req.getParameter("action");
        if ("markRead".equalsIgnoreCase(action)) {
            matchDAO.markAllNotificationsRead(user.getUserId());
        }
        
        res.sendRedirect("notifications");
    }
}
