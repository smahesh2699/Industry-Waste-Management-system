package com.wastelink.model;

public class Recycler {
    private int recyclerId;
    private int userId;
    private String acceptedCategories;
    private double capacityKg;
    private String certification;
    private String bio;

    // Getters and Setters
    public int getRecyclerId() {
        return recyclerId;
    }

    public void setRecyclerId(int recyclerId) {
        this.recyclerId = recyclerId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getAcceptedCategories() {
        return acceptedCategories;
    }

    public void setAcceptedCategories(String acceptedCategories) {
        this.acceptedCategories = acceptedCategories;
    }

    public double getCapacityKg() {
        return capacityKg;
    }

    public void setCapacityKg(double capacityKg) {
        this.capacityKg = capacityKg;
    }

    public String getCertification() {
        return certification;
    }

    public void setCertification(String certification) {
        this.certification = certification;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }
}
