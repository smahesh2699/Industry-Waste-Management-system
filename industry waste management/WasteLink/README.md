# WasteLink – Smart Waste Exchange Platform

WasteLink is a Java Web Application (MVC pattern) designed to bridge the gap between waste-generating industries (sellers) and recycling companies (buyers). The platform promotes a circular economy by facilitating the trading of recyclable industrial materials, tracking economic profit margins, and estimating carbon footprint offsets.

---

## 🚀 Key Features

* **Dual-Role Dashboards**: Custom interfaces for **Industries** (Sellers) to list waste and **Recyclers** (Buyers) to browse and bid.
* **Geolocation Matching**: Automatically matches listings with nearby recyclers using the **Haversine Distance Formula** based on latitude and longitude coordinates.
* **Interactive Marketplace**: A searchable directory with category, distance, and price filters for recyclers to easily source materials.
* **Profit Estimator**: Calculates net trade margins automatically by accounting for transportation overheads and handling fees.
* **Sustainability & CO₂ Tracking**: Calculates carbon offset points dynamically based on the category of materials processed.
* **Interactive Dashboards**: Renders statistics (materials, statuses, and monthly transactions) visually using **Chart.js**.
* **System Alerts**: Real-time notifications for matches, requested bids, and transaction confirmations.

---

## 🛠️ Tech Stack

* **Frontend**: HTML5, CSS3, Bootstrap 5, JavaScript, Chart.js
* **Backend**: Java Servlets & JSP (Jakarta EE)
* **Database**: MySQL 8.0
* **Build Tool**: Maven
* **Server**: Apache Tomcat 10 / Embedded Jetty Server

---

## 💻 Setup & Installation

### 1. Database Setup
Import the SQL database schema into your MySQL server:
```sql
source database/wastelink_schema.sql
```

### 2. Configure Credentials
Update the database password inside the JDBC connection manager at `src/main/java/com/wastelink/db/DBConnection.java` to match your local MySQL configuration:
```java
private static final String PASSWORD = "YOUR_MYSQL_PASSWORD";
```

### 3. Run Locally (One-Click)
Run the project instantly on an embedded server (Jetty) without manual Tomcat configuration by double-clicking the batch script:
```bash
run_wastelink.bat
```
Once started, open your web browser and go to: **`http://localhost:8080`**
