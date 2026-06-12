package com.wastelink.model;

import java.sql.Timestamp;

public class Match {
    private int matchId;
    private int wasteId;
    private int recyclerId;
    private int industryUserId;
    private String status; // PENDING, ACCEPTED, REJECTED, COMPLETED
    private double profitEstimate;
    private double co2SavedKg;
    private Timestamp matchedAt;

    // Getters and Setters
    public int getMatchId() {
        return matchId;
    }

    public void setMatchId(int matchId) {
        this.matchId = matchId;
    }

    public int getWasteId() {
        return wasteId;
    }

    public void setWasteId(int wasteId) {
        this.wasteId = wasteId;
    }

    public int getRecyclerId() {
        return recyclerId;
    }

    public void setRecyclerId(int recyclerId) {
        this.recyclerId = recyclerId;
    }

    public int getIndustryUserId() {
        return industryUserId;
    }

    public void setIndustryUserId(int industryUserId) {
        this.industryUserId = industryUserId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getProfitEstimate() {
        return profitEstimate;
    }

    public void setProfitEstimate(double profitEstimate) {
        this.profitEstimate = profitEstimate;
    }

    public double getCo2SavedKg() {
        return co2SavedKg;
    }

    public void setCo2SavedKg(double co2SavedKg) {
        this.co2SavedKg = co2SavedKg;
    }

    public Timestamp getMatchedAt() {
        return matchedAt;
    }

    public void setMatchedAt(Timestamp matchedAt) {
        this.matchedAt = matchedAt;
    }
}
