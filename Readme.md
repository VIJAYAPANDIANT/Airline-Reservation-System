🛒 Online Retail Sales Database Design
📌 Project Overview

The Online Retail Sales Database Design project implements a fully normalized Third Normal Form (3NF) relational database system for an online retail (e-commerce) platform.

This database is designed to efficiently manage:

👤 Customers

📦 Products

🛍️ Orders

🧾 Order Items

💳 Payments

The schema ensures:

✅ Data integrity using Primary & Foreign Keys

✅ Minimal redundancy (3NF normalization)

✅ Accurate historical transaction tracking

✅ Efficient analytical reporting

✅ Scalability for real-world retail applications

This project demonstrates strong understanding of:

Relational Database Design

Normalization (1NF, 2NF, 3NF)

Entity Relationships

SQL Constraints

Analytical SQL Queries & Views

📂 Project File Structure
File Name	Description
schema.sql	Creates the database OnlineRetailDB and defines all tables with constraints and relationships.
data.sql	Inserts sample data for testing (Customers, Products, Orders, etc.).
queries.sql	Contains analytical queries and reporting Views for business insights.
full_setup.sql	Combined script that executes schema creation, data insertion, and queries in one file.
setup_and_test.bat	Windows automation script to run the complete setup process in one click.
🗄️ Database Schema Reference

The system consists of 5 core tables, carefully structured in 3NF.

1️⃣ Customers Table

Stores customer account and shipping information.

Column	Type	Description
customer_id	INT (PK)	Unique customer identifier
first_name	VARCHAR	Customer first name
last_name	VARCHAR	Customer last name
email	VARCHAR (UNIQUE)	Unique email address
phone	VARCHAR	Contact number
address	VARCHAR	Shipping address
city	VARCHAR	City
state	VARCHAR	State
zip_code	VARCHAR	Postal code
created_at	TIMESTAMP	Account creation date

🔒 Constraints Used:

Primary Key

Unique Constraint (email)

2️⃣ Products Table

Maintains product inventory information.

Column	Type	Description
product_id	INT (PK)	Unique product identifier
name	VARCHAR	Product name
description	TEXT	Product details
price	DECIMAL	Unit price
stock_quantity	INT	Available stock
category	VARCHAR	Product category

📦 Supports inventory tracking and category-based filtering.

3️⃣ Orders Table

Tracks customer purchases.

Column	Type	Description
order_id	INT (PK)	Unique order ID
customer_id	INT (FK)	References Customers
order_date	TIMESTAMP	Date of order
status	ENUM	Pending / Shipped / Delivered / Cancelled
total_amount	DECIMAL	Total order value

🔗 Relationships:

One Customer → Many Orders

4️⃣ Order_Items Table (Junction Table)

Handles the Many-to-Many relationship between Orders and Products.

Column	Type	Description
order_item_id	INT (PK)	Unique ID
order_id	INT (FK)	References Orders
product_id	INT (FK)	References Products
quantity	INT	Units purchased
unit_price	DECIMAL	Price at time of purchase

🧠 Important Design Decision:
unit_price is stored separately to preserve historical pricing even if product prices change later.

5️⃣ Payments Table

Tracks payment transactions for orders.

Column	Type	Description
payment_id	INT (PK)	Unique payment ID
order_id	INT (FK)	Linked order
amount	DECIMAL	Paid amount
payment_method	ENUM	Credit Card / PayPal / Bank Transfer
status	ENUM	Success / Failed

💳 Supports transaction auditing and reconciliation.

🔄 Database Relationships Overview

Customers → Orders (1:M)

Orders → Order_Items (1:M)

Products → Order_Items (1:M)

Orders → Payments (1:M)

The schema strictly follows 3NF principles:

No repeating groups

No partial dependencies

No transitive dependencies

🚀 Setup & Installation
🔧 Prerequisites

MySQL Server 8.0+

MySQL Command Line Client

(Optional) MySQL Workbench

Windows OS (for .bat automation)

⚡ Option 1: Automatic Setup (Windows)

Navigate to the project folder.

Double-click:

setup_and_test.bat

Enter:

MySQL username (default: root)

MySQL password

The script will automatically:

Create database

Create tables

Insert sample data

Execute analytical queries

Display results

✔ Recommended for quick testing.

🛠 Option 2: Manual Setup
Step 1: Login to MySQL
mysql -u root -p
Step 2: Run Schema
SOURCE schema.sql;
Step 3: Insert Sample Data
SOURCE data.sql;
Step 4: Run Reports
SOURCE queries.sql;
📊 Analytical Queries & Views

The queries.sql file contains reporting views for business intelligence.

📈 1. Product Sales Report (ProductSales View)

Analyzes product-level revenue and sales volume.

Columns:

product_name

total_units_sold

total_revenue

Usage:
SELECT * FROM ProductSales;

📌 Helps identify best-selling products.

👑 2. Customer Spending Report (CustomerSpending View)

Identifies high-value customers.

Columns:

full_name

total_orders

total_spent

Usage:
SELECT * FROM CustomerSpending;

📌 Useful for loyalty programs and marketing strategies.

🧠 Learning Outcomes

This project demonstrates:

Advanced SQL Table Design

Normalization to 3NF

Foreign Key Relationships

ENUM Constraints

Analytical Queries

View Creation

Real-world E-commerce Modeling

🔮 Future Improvements

Add indexing for performance optimization

Implement stored procedures

Add triggers for stock auto-update

Add refund handling system

Integrate with frontend application

Add user authentication system

Create dashboard using Power BI / Tableau

📜 Author

Design and Implementation by:

👨‍💻 VIJAYAPANDIAN.T