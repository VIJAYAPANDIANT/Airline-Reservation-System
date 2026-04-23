# ✈️ Airline Reservation System Database Design

[![Database](https://img.shields.io/badge/Database-MySQL-blue.svg)](https://www.mysql.com/)
[![SQL](https://img.shields.io/badge/Language-SQL-orange.svg)](https://en.wikipedia.org/wiki/SQL)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📌 Project Overview
The **Airline Reservation System** is a comprehensive relational database solution designed to manage the intricate operations of a modern airline. From global flight scheduling and aircraft seat management to passenger bookings and financial transaction tracking, this system provides a robust foundation for aviation business intelligence.

This project focuses on **data integrity**, **automated workflows**, and **analytical reporting** to ensure a seamless experience for both airline administrators and passengers.

---

## 🚀 Key Features
- **Intelligent Scheduling**: Manage global routes, airports, and flight schedules with automated arrival/departure validation.
- **Dynamic Seat Mapping**: Support for multiple aircraft models with unique seat layouts (Economy, Business, First Class).
- **Secure Bookings**: Automated PNR (Passenger Name Record) generation and booking management.
- **Double-Booking Prevention**: Advanced SQL Triggers ensure no seat is booked twice for the same flight.
- **Financial Tracking**: Integrated payment processing with support for multiple payment methods and refund tracking.
- **Analytical Insights**: Built-in views for revenue tracking, passenger manifests, and flight occupancy reports.

---

## 🏗️ Database Architecture

### 🗺️ Entity Relationship Diagram (ERD)
The schema is designed for high normalization and performance. You can view the visual design here:
> [!TIP]
> **[View Interactive ER Diagram](https://drive.google.com/file/d/1aPpZHlUhFCAFHqKVuJwO90tyL0crX7Ky/view?usp=sharing)**

### 📂 Project Documentation
Access the comprehensive project report and detailed documentation here:
> [!IMPORTANT]
> **[📂 Detailed Project Document](https://drive.google.com/file/d/1wos0Lv9pgOYhve2-ZPyirkn7kaoYTsaX/view?usp=sharing)**

### 🗄️ Core Tables
| Category | Tables | Description |
| :--- | :--- | :--- |
| **User Management** | `roles`, `users` | Handles authentication and administrative access levels. |
| **Aviation Core** | `airports`, `aircraft`, `seats` | Defines the physical infrastructure (ports, planes, layouts). |
| **Operations** | `routes`, `flights`, `passengers` | Manages flight paths, schedules, and traveler data. |
| **Commerce** | `bookings`, `booking_items`, `payments` | Tracks reservations, seat assignments, and financial records. |
| **Pricing** | `flight_pricing` | Manages class-based multipliers for dynamic ticket pricing. |

---

## 🛠️ Setup & Installation

### Prerequisites
- **MySQL Server 8.0+**
- **Windows OS** (for automatic setup) or any OS (for manual setup)

### Option 1: Automatic Setup (Windows)
1. Clone the repository to your local machine.
2. Double-click the `setup_and_test_fixed.bat` file.
3. Follow the on-screen prompts to enter your MySQL credentials.
4. The script will automatically create the database, seed it with sample data, and run verification tests.

### Option 2: Manual Setup
```sql
-- 1. Login to your MySQL Terminal
mysql -u your_username -p

-- 2. Execute the full setup script
SOURCE full_setup.sql;
```

---

## 📊 Business Intelligence & Reporting
The system includes pre-configured Views and Analytical Queries for immediate reporting:

### 1. Detailed Booking Manifest
Provides a complete overview of every passenger, their flight, seat assignment, and payment status.
```sql
SELECT * FROM vw_booking_details;
```

### 2. Revenue Performance Analytics
Calculates total revenue and seat occupancy per flight to identify profitable routes.
```sql
SELECT * FROM vw_flight_revenue;
```

### 3. Cumulative Financial Growth
Tracks daily revenue and calculates cumulative growth over time using advanced window functions.
*(Found in `full_setup.sql` output)*

---

## ⚙️ Advanced Logic & Integrity
- **Triggers**: `before_booking_item_insert` prevents overbooking and ensures seats belong to the correct aircraft.
- **Stored Procedures**: `SP_BookFlight` handles the complex multi-table transaction of booking a seat, processing payment, and updating status in one atomic operation.
- **Stored Procedures**: `SP_CancelBooking` manages the reversal of bookings and payment refunds.

---

## 📂 Repository Structure
```bash
.
├── airline_reservation_system_setup.sql  # Schema, Triggers, and Procedures
├── full_setup.sql                         # Unified script (Schema + Sample Data)
├── setup_and_test_fixed.bat               # Automated Windows Deployment Script
└── Readme.md                              # Project Documentation
```

---

## 👤 Author
**VIJAYAPANDIAN.T**
*Database Designer & Developer*

---

> [!NOTE]
> This project was developed as part of a Database Management System design portfolio. All sample data is synthetic and intended for demonstration purposes.
