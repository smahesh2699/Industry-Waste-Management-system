USE wastelink_db;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE ADMIN_LOGS;
TRUNCATE TABLE NOTIFICATIONS;
TRUNCATE TABLE MATCHES;
TRUNCATE TABLE RECYCLER;
TRUNCATE TABLE WASTE;
TRUNCATE TABLE USERS;
SET FOREIGN_KEY_CHECKS = 1;

-- Seed default user accounts
INSERT INTO USERS (user_id, full_name, email, password, role, company_name, phone, city, state, latitude, longitude, account_status)
VALUES
(1, 'System Administrator', 'admin@wastelink.com', 'admin123', 'ADMIN', 'WasteLink Headquarters', '9900112233', 'Bengaluru', 'Karnataka', 12.9716, 77.5946, 'ACTIVE'),
(2, 'Greenfield Manufacturing', 'industry@wastelink.com', 'pass123', 'INDUSTRY', 'Greenfield Manufacturing Ltd', '9900112244', 'Bengaluru', 'Karnataka', 12.9716, 77.5946, 'ACTIVE'),
(3, 'Apex Recycling Solutions', 'recycler@wastelink.com', 'pass123', 'RECYCLER', 'Apex Recycling Solutions', '9900112255', 'Bengaluru', 'Karnataka', 12.9352, 77.6245, 'ACTIVE');

-- Seed recycler metadata
INSERT INTO RECYCLER (user_id, accepted_categories, capacity_kg, certification, bio)
VALUES
(3, 'METAL,PLASTIC,ELECTRONIC,PAPER', 10000.0, 'ISO-14001 & OHSAS-18001', 'State-of-the-art waste aggregation and processing facility.');
