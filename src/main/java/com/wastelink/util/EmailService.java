package com.wastelink.util;

public class EmailService {
    public static void sendEmail(String to, String subject, String body) {
        // Stub implementation to avoid blocking on SMTP configuration issues
        System.out.println("----- EMAIL SIMULATOR -----");
        System.out.println("To: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Body: " + body);
        System.out.println("---------------------------");
    }
}
