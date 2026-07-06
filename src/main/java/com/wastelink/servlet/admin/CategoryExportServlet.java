package com.wastelink.servlet.admin;

import com.wastelink.dao.CategoryReportDAO;
import com.wastelink.model.CategoryUserSummary;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/category-export")
public class CategoryExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("text/csv");
        res.setHeader("Content-Disposition", "attachment; filename=wastelink_categorical_exchanged.csv");
        PrintWriter out = res.getWriter();

        // CSV Header
        out.println("Category,Company Name,Role,Total Quantity (kg),Exchanges Count,Percentage Share (%)");

        CategoryReportDAO dao = new CategoryReportDAO();
        Map<String, List<CategoryUserSummary>> share = dao.getRecyclerSharePerCategory();

        for (Map.Entry<String, List<CategoryUserSummary>> entry : share.entrySet()) {
            String category = entry.getKey();
            for (CategoryUserSummary sum : entry.getValue()) {
                out.println(String.format("%s,\"%s\",%s,%.2f,%d,%.1f",
                    category,
                    sum.getCompanyName().replace("\"", "\"\""),
                    sum.getRole(),
                    sum.getTotalQuantityKg(),
                    sum.getCount(),
                    sum.getPercentageShare()
                ));
            }
        }
    }
}
