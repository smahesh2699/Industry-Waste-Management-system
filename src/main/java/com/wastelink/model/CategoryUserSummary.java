package com.wastelink.model;

public class CategoryUserSummary {
    private String category;
    private int userId;
    private String companyName;
    private String role;
    private double totalQuantityKg;
    private int count;
    private double percentageShare;

    public CategoryUserSummary() {}

    public CategoryUserSummary(String category, int userId, String companyName, String role, double totalQuantityKg, int count, double percentageShare) {
        this.category = category;
        this.userId = userId;
        this.companyName = companyName;
        this.role = role;
        this.totalQuantityKg = totalQuantityKg;
        this.count = count;
        this.percentageShare = percentageShare;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public double getTotalQuantityKg() {
        return totalQuantityKg;
    }

    public void setTotalQuantityKg(double totalQuantityKg) {
        this.totalQuantityKg = totalQuantityKg;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public double getPercentageShare() {
        return percentageShare;
    }

    public void setPercentageShare(double percentageShare) {
        this.percentageShare = percentageShare;
    }
}
