# ✈️ Airline Reservation System Database Design

📌 Project Overview
This project implements a robust relational database for an Airline Reservation System. It is designed to handle complex aviation operations, including flight scheduling, aircraft seat configurations, passenger bookings, and financial transaction tracking. The schema ensures data integrity using constraints and triggers, preventing issues like double-booking while supporting deep analytical reporting.

📂 File Structure
| File | Description |
| :--- | :--- |
| airline_reservation_system_setup.sql | Defines the core database structure, including tables, indexes, triggers, and stored procedures. |
| full_setup.sql | A unified script combining schema creation, data insertion, and sample analytical queries. |
| setup_and_test_fixed.bat | An automated Windows batch script to find MySQL, execute the setup, and display results. |

🗄️ Database Schema Reference
The database consists of structured tables tailored for airline management.

### 🗺️ Entity Relationship Diagram (ERD)

You can view the visual schema design here: [DB Diagram - Google Drive](https://drive.google.com/file/d/1aPpZHlUhFCAFHqKVuJwO90tyL0crX7Ky/view?usp=sharing)

1. Aircraft & Seats

- **Aircraft**: Tracks the fleet (model, manufacturer, year).
- **Seats**: Manages seat layout (seat_number, class: Economy/Business/First) for each aircraft.

2. Routes & Flights

- **Airports**: Stores global airport details (IATA codes, city, country).
- **Routes**: Defines connections between airports with base pricing.
- **Flights**: Specific schedules for aircraft on given routes.

3. Passengers & Users

- **Users**: System users/agents who manage bookings.
- **Passengers**: Detailed traveler information including passport data.

4. Bookings & Items

- **Bookings**: Master record for a reservation with a unique 6-character PNR.
- **Booking_Items**: Specific seat assignments for passengers on specific flights.

5. Payments

- **Payments**: Records transaction details, methods (Credit Card, PayPal), and success/refund status.

🚀 Setup and Installation
Prerequisites

- MySQL Server 8.0 or higher.
- MySQL added to System PATH (optional, the script attempts to find it).

Option 1: Automatic Setup (Windows)

1. Navigate to the project folder.
2. Double-click **setup_and_test_fixed.bat**.
3. Enter your MySQL credentials when prompted.
4. The script will initialize the database and run all analysis tests.

Option 2: Manual Execution

1. Login to MySQL: `mysql -u root -p`
2. Run the unified setup: `SOURCE full_setup.sql;`

📊 Analytical Queries & Views
The system includes built-in views for business intelligence:

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
