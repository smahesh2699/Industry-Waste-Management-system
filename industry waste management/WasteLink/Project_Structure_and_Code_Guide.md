# WasteLink – Smart Waste Exchange Platform
## Project Structure & Source Code Guide

**Mini Project Submitted by:** Mahesh S (1NH25MC064) & Manoj Kumar H M (1NH25MC069)  
**College:** New Horizon College of Engineering, Bengaluru  
**Academic Year:** 2025–2026  

---

## 1. Project Directory Structure Map

Below is the complete directory structure of the **WasteLink** MVC application:

```text
WasteLink/
├── run_wastelink.bat           <-- One-click batch launcher
├── pom.xml                     <-- Maven dependencies and build properties
├── database/
│   └── wastelink_schema.sql    <-- SQL Schema & seeds for MySQL
├── src/
│   └── main/
│       ├── java/
│       │   └── com/wastelink/
│       │       ├── db/
│       │       │   └── DBConnection.java       <-- JDBC connector credentials
│       │       ├── model/                      <-- MVC Model classes
│       │       │   ├── User.java               <-- User profiles bean
│       │       │   ├── Waste.java              <-- Waste listings bean
│       │       │   ├── Recycler.java           <-- Recycler capacities & certifications
│       │       │   └── Match.java              <-- Matching logs bean
│       │       ├── dao/                        <-- MVC Data Access Objects (CRUD)
│       │       │   ├── UserDAO.java            <-- USERS table queries
│       │       │   ├── WasteDAO.java           <-- WASTE table queries
│       │       │   ├── RecyclerDAO.java        <-- RECYCLER table queries
│       │       │   └── MatchDAO.java           <-- MATCHES & NOTIFICATIONS queries
│       │       ├── servlet/                    <-- MVC Controllers (Jakarta Servlets)
│       │       │   ├── RegisterServlet.java    <-- Signups handler
│       │       │   ├── LoginServlet.java       <-- Authentication & Session handler
│       │       │   ├── LogoutServlet.java      <-- Session terminator
│       │       │   ├── ProfileServlet.java     <-- Profile updates (Seller/Recycler)
│       │       │   ├── AddWasteServlet.java    <-- New waste post handler
│       │       │   ├── ManageWasteServlet.java <-- Deletions & updates handler
│       │       │   ├── MarketplaceServlet.java <-- Search filters handler
│       │       │   ├── MatchingServlet.java    <-- Geolocation matching engine
│       │       │   ├── MatchActionServlet.java <-- Accept/reject match handler
│       │       │   ├── AnalyticsServlet.java   <-- SQL chart aggregations
│       │       │   └── NotificationServlet.java<-- Notification read handler
│       │       └── util/                       <-- Helper & Utilities
│       │           ├── LocationUtil.java       <-- Haversine distance calculator
│       │           ├── ProfitUtil.java         <-- Trade profit margins formula
│       │           ├── ImpactUtil.java         <-- CO2 offset & sustainability factors
│       │           └── EmailService.java       <-- Alert simulator stub
│       └── webapp/                             <-- MVC Views (JSP & UI files)
│           ├── WEB-INF/
│           │   └── web.xml                     <-- Deployment descriptor file
│           ├── css/
│           │   └── wastelink.css               <-- Teal design tokens stylesheet
│           ├── js/
│           │   └── wastelink.js                <-- GPS geolocation script
│           ├── includes/
│           │   ├── navbar.jsp                  <-- Dynamic header navbar component
│           │   └── footer.jsp                  <-- Dynamic footer & script component
│           ├── index.jsp                       <-- Platform landing page
│           ├── login.jsp                       <-- Security login card
│           ├── register.jsp                    <-- Sign-up form with GPS detection
│           ├── industry-dashboard.jsp          <-- Seller panel
│           ├── recycler-dashboard.jsp          <-- Buyer panel
│           ├── add-waste.jsp                   <-- Add listing form
│           ├── my-listings.jsp                 <-- Seller listing list & active bids
│           ├── marketplace.jsp                 <-- Buyer browse & filter grid
│           ├── match-requests.jsp              <-- Unified matches history logs
│           ├── analytics.jsp                   <-- Live margins & Chart.js graph boards
│           ├── profile.jsp                     <-- User settings & parameter forms
│           └── notifications.jsp               <-- User alert boards
```

---

## 2. Comprehensive File Code Details

Here is the functional explanation and description of each source code directory:

### 2.1 Database Config (`/database`)
* **`wastelink_schema.sql`**  
  Contains raw DDL definitions for the tables (`USERS`, `WASTE`, `RECYCLER`, `MATCHES`, `NOTIFICATIONS`). Implements key indexes and foreign keys, along with test data insertions for immediate login checks.

### 2.2 Domain Models (`/src/main/java/com/wastelink/model`)
* **`User.java`**: Represents users (both sellers and buyers), mapping contact data, roles, and geolocation parameters (latitude/longitude).
* **`Waste.java`**: Holds properties for listed industrial waste items: type, category, quantity (kg), pricing, description, and listings timestamps.
* **`Recycler.java`**: Extends recycler details including accepted materials categories, monthly capacities (kg), bio, and certificates.
* **`Match.java`**: Tracks transactional matching links between industries, recyclers, profit values, and carbon offset saves.

### 2.3 DB & Business Logic Utilities (`/src/main/java/com/wastelink/util` & `/db`)
* **`DBConnection.java`**: Stores central JDBC connector settings, initializing the `com.mysql.cj.jdbc.Driver` driver.
* **`LocationUtil.java`**: Computes geographical distances using the **Haversine Formula**:
  $$d = 2R \arcsin\left(\sqrt{\sin^2\left(\frac{\Delta\text{lat}}{2}\right) + \cos(\text{lat}_1)\cos(\text{lat}_2)\sin^2\left(\frac{\Delta\text{lon}}{2}\right)}\right)$$
* **`ProfitUtil.java`**: Estimates trade net margins using the platform business rule:
  $$\text{Net Profit} = (\text{Qty} \times \text{Price}) - (8\% \text{ handling fee}) - (\text{Rs. } 0.5/\text{kg transport cost})$$
* **`ImpactUtil.java`**: Calculates CO₂ offsets using category multipliers (e.g. Metal = 1.8x, Plastic = 2.5x) and returns overall sustainability scores.

### 2.4 Data Access Layer (`/src/main/java/com/wastelink/dao`)
* **`UserDAO.java`**: Performs signups, authenticate logins, and pulls user coordinates.
* **`WasteDAO.java`**: Handles postings creations, details editing, listing deletions, and status toggles.
* **`RecyclerDAO.java`**: Queries and updates operational variables (categories, capacity limits).
* **`MatchDAO.java`**: Creates candidate matches, updates status states, and logs system notifications.

### 2.5 Controllers (`/src/main/java/com/wastelink/servlet`)
* **`LoginServlet.java` & `LogoutServlet.java`**: Starts sessions, maps roles (`INDUSTRY` -> Industry Dashboard, `RECYCLER` -> Recycler Dashboard), and terminates active session parameters.
* **`MatchingServlet.java`**: Initiates geolocation sweeps to link matching recyclers within custom radiuses.
* **`MatchActionServlet.java`**: Processes recycler accept/reject bids, updating waste listing states.
* **`AnalyticsServlet.java`**: Aggregates database metrics to generate JSON arrays for Chart.js.

### 2.6 Views & Assets (`/src/main/webapp`)
* **`wastelink.css`**: Renders custom green-teal design systems (glassmorphism details, animations, status tags).
* **`navbar.jsp`**: Embedded component updating notification counts and routes dynamically per role.
* **`index.jsp`**: Landing page including details, stats panels, and CTA blocks.
* **`analytics.jsp`**: Renders charts (categories bar chart, status breakdown doughnut chart, monthly line chart) and features an interactive margin calculator.

---

## 3. How to Convert this Guide to PDF
1. Open this file in **VS Code** (or any Markdown Editor).
2. Install the **Markdown PDF** extension or press **Ctrl+Shift+P** -> Select **Markdown PDF: Export (pdf)**.
3. Alternatively, open the project's documentation folder in your web browser and click **File -> Print -> Save as PDF**.
