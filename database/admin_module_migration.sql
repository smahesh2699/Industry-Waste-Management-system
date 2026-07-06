USE wastelink_db;

-- 1. Extend USERS to support ADMIN role + account suspension
ALTER TABLE USERS MODIFY role ENUM('INDUSTRY','RECYCLER','ADMIN') NOT NULL;
ALTER TABLE USERS ADD COLUMN account_status ENUM('ACTIVE','SUSPENDED') DEFAULT 'ACTIVE';

-- 2. Extend WASTE to support moderation/flagging
ALTER TABLE WASTE ADD COLUMN flagged BOOLEAN DEFAULT FALSE;
ALTER TABLE WASTE ADD COLUMN flagged_reason VARCHAR(255);

-- 3. New table: audit trail of every admin action
CREATE TABLE IF NOT EXISTS ADMIN_LOGS (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    target_table VARCHAR(50),
    target_id INT,
    details VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES USERS(user_id)
);

-- 4. Seed one admin account directly (NOT through the register.jsp form)
INSERT INTO USERS (full_name, email, password, role, company_name, city, state, latitude, longitude, account_status)
VALUES ('Platform Admin', 'admin@wastelink.com', 'admin123', 'ADMIN', 'WasteLink HQ', 'Bengaluru', 'Karnataka', 12.9716, 77.5946, 'ACTIVE');
