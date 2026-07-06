package com.wastelink.servlet.admin;

import com.wastelink.dao.CategoryReportDAO;
import com.wastelink.model.CategoryUserSummary;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/category-report")
public class AdminCategoryReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        CategoryReportDAO dao = new CategoryReportDAO();

        Map<String, List<CategoryUserSummary>> listingsByCategory = dao.getListingsByCategory();
        Map<String, List<CategoryUserSummary>> recyclerShareByCategory = dao.getRecyclerSharePerCategory();

        req.setAttribute("listingsByCategory", listingsByCategory);
        req.setAttribute("recyclerShareByCategory", recyclerShareByCategory);

        req.getRequestDispatcher("/admin-category-report.jsp").forward(req, res);
    }
}
