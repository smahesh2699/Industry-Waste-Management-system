CREATE DATABASE IF NOT EXISTS wastelink_db;
USE wastelink_db;

CREATE TABLE USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('INDUSTRY', 'RECYCLER') NOT NULL,
    company_name VARCHAR(150),
    phone VARCHAR(15),
    city VARCHAR(100),
    state VARCHAR(100),
    latitude DOUBLE DEFAULT 12.9716,
    longitude DOUBLE DEFAULT 77.5946,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE WASTE (
    waste_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    waste_type VARCHAR(100) NOT NULL,
    category ENUM('METAL','PLASTIC','PAPER','CHEMICAL','ELECTRONIC','ORGANIC','OTHER') NOT NULL,
    quantity_kg DOUBLE NOT NULL,
    price_per_kg DOUBLE NOT NULL,
    description TEXT,
    location VARCHAR(200),
    latitude DOUBLE,
    longitude DOUBLE,
    status ENUM('AVAILABLE','MATCHED','SOLD') DEFAULT 'AVAILABLE',
    listed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

CREATE TABLE RECYCLER (
    recycler_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    accepted_categories VARCHAR(255),
    capacity_kg DOUBLE,
    certification VARCHAR(200),
    bio TEXT,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

CREATE TABLE MATCHES (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    waste_id INT NOT NULL,
    recycler_id INT NOT NULL,
    industry_user_id INT NOT NULL,
    status ENUM('PENDING','ACCEPTED','REJECTED','COMPLETED') DEFAULT 'PENDING',
    profit_estimate DOUBLE,
    co2_saved_kg DOUBLE,
    matched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (waste_id) REFERENCES WASTE(waste_id),
    FOREIGN KEY (recycler_id) REFERENCES USERS(user_id),
    FOREIGN KEY (industry_user_id) REFERENCES USERS(user_id)
);

CREATE TABLE NOTIFICATIONS (
    notif_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(500) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- Sample data
INSERT INTO USERS (full_name, email, password, role, company_name, city, state, latitude, longitude)
VALUES
('Steel Corp India', 'industry@wastelink.com', 'pass123', 'INDUSTRY', 'Steel Corp India Pvt Ltd', 'Bengaluru', 'Karnataka', 12.9716, 77.5946),
('GreenRecycle Ltd', 'recycler@wastelink.com', 'pass123', 'RECYCLER', 'GreenRecycle Ltd', 'Bengaluru', 'Karnataka', 12.9352, 77.6245);
