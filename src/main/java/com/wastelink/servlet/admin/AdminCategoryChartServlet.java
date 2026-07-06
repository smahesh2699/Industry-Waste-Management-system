package com.wastelink.servlet.admin;

import com.wastelink.dao.CategoryReportDAO;
import com.wastelink.model.CategoryUserSummary;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/category-chart")
public class AdminCategoryChartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();

        CategoryReportDAO dao = new CategoryReportDAO();
        Map<String, List<CategoryUserSummary>> share = dao.getRecyclerSharePerCategory();

        StringBuilder json = new StringBuilder();
        json.append("{");
        boolean firstCat = true;
        for (Map.Entry<String, List<CategoryUserSummary>> entry : share.entrySet()) {
            if (!firstCat) {
                json.append(",");
            }
            firstCat = false;

            json.append("\"").append(entry.getKey()).append("\":[");
            boolean firstItem = true;
            for (CategoryUserSummary sum : entry.getValue()) {
                if (!firstItem) {
                    json.append(",");
                }
                firstItem = false;

                json.append("{")
                    .append("\"companyName\":\"").append(sum.getCompanyName().replace("\"", "\\\"")).append("\",")
                    .append("\"totalQuantityKg\":").append(sum.getTotalQuantityKg()).append(",")
                    .append("\"percentageShare\":").append(sum.getPercentageShare())
                    .append("}");
            }
            json.append("]");
        }
        json.append("}");

        out.print(json.toString());
    }
}
