# E-commerce SQL Database  

## 📌 Project Overview  
This project implements an **E-commerce relational database** in MySQL to store, manage, and analyze data about categories, customers, products, orders, and order items.  

The goal was to design tables with proper relationships, enforce constraints, optimize with indexes, and write SQL queries for data analysis and reporting.  

---

## 📂 Repository Structure  
```
D:\Data Analyst Internship\Task_4\ecommerce
│── Ecommerce SQL Script.sql        # SQL script for database schema, views & queries
│── Screenshots\                    # Output screenshots of SQL queries
│── README.md                       # Documentation (this file)
```

---

## 🗄️ Database Schema  
The database consists of the following tables (with foreign key relationships):  

1. **categories** – Stores product categories  
2. **customers** – Stores customer details  
3. **products** – Stores products linked to categories  
4. **orders** – Stores customer orders with total amounts  
5. **order_items** – Stores order details (products, quantities, subtotals)  

### ERD (Conceptual)  
```
categories ───< products ───< order_items >─── orders >─── customers
```

---

## ⚡ Features Implemented  
- **Schema Design:** Primary keys, foreign keys, unique constraints, and check constraints.  
- **Indexes:** Created for faster lookups on order dates, product names, and product/order combinations.  
- **Views for Analysis:**  
  - `v_order_item_details` – Detailed breakdown of each order  
  - `v_daily_sales` – Daily revenue & orders count  
  - `v_customer_ltv` – Customer lifetime value and average order value  
  - `v_category_sales` – Category-wise sales summary  

---

## 🔍 Data Analysis Queries  
The script demonstrates SQL for:  
- Daily revenue and order count (`GROUP BY`, `ORDER BY`)  
- Top 5 products by sales (`JOIN`, `LIMIT`)  
- Sales by category (`JOIN`, `GROUP BY`)  
- Customer lifetime value (`JOIN`, `HAVING`)  
- Customers with no orders (`LEFT JOIN`, `WHERE IS NULL`)  
- Customers with above-average order value (subquery)  
- Orders with more than 1 item (`HAVING COUNT(*) > 1`)  
- Month-to-date revenue (filter by date range)  
- Highest-grossing category (subquery with `MAX()`)  
- Top customers by total units purchased (multi-join)  
- RIGHT JOIN example to include customers with zero orders  
- Products priced above category average (subquery)  

---

## 📊 Deliverables  
- **SQL File:** [`Ecommerce SQL Script.sql`](./Ecommerce%20SQL%20Script.sql)  
- **Screenshots of Outputs:** Located in `D:\Data Analyst Internship\Task_4\ecommerce\Screenshots`  
- **README.md:** This documentation file  

---

## 🚀 How to Run  
1. Open MySQL Workbench (or CLI).  
2. Run the script:  
   ```sql
   SOURCE D:/Data Analyst Internship/Task_4/ecommerce/Ecommerce SQL Script.sql;
   ```
3. Verify tables, views, and queries using:  
   ```sql
   SHOW TABLES;
   SHOW FULL TABLES WHERE table_type = 'VIEW';
   ```

---

## 📝 Author  
   Kadimella Sahana  
