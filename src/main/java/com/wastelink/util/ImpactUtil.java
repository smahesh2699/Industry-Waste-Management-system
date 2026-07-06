package com.wastelink.util;

public class ImpactUtil {
    // CO2 saved per kg by category (approximate kg CO2 per kg waste diverted)
    public static double co2SavedKg(String category, double quantityKg) {
        if (category == null) {
            return quantityKg * 1.0;
        }
        double factor = 1.0;
        switch (category.toUpperCase()) {
            case "METAL":
                factor = 1.8;
                break;
            case "PLASTIC":
                factor = 2.5;
                break;
            case "PAPER":
                factor = 1.1;
                break;
            case "ELECTRONIC":
                factor = 3.2;
                break;
            case "CHEMICAL":
                factor = 2.0;
                break;
            case "ORGANIC":
                factor = 0.6;
                break;
            default:
                factor = 1.0;
        }
        return quantityKg * factor;
    }

    public static double sustainabilityScore(double co2Saved, double quantityKg) {
        return Math.min(100.0, (co2Saved / (quantityKg + 1)) * 30);
    }
}
