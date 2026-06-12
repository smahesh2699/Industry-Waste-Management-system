package com.wastelink.util;

public class ProfitUtil {
    public static double estimateProfit(double quantityKg, double pricePerKg) {
        double grossRevenue = quantityKg * pricePerKg;
        double handlingCost = grossRevenue * 0.08; // 8% handling
        double transportCost = quantityKg * 0.5;   // Rs 0.5/kg transport
        return grossRevenue - handlingCost - transportCost;
    }
}
