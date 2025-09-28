CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
  category_id   INT PRIMARY KEY,
  category_name VARCHAR(255) NOT NULL
);

CREATE TABLE customers (
  customer_id   INT PRIMARY KEY,
  name          VARCHAR(255) NOT NULL,
  email         VARCHAR(255) NOT NULL UNIQUE,
  phone         VARCHAR(64),
  address       VARCHAR(255),
  city          VARCHAR(128),
  country       VARCHAR(128)
);

CREATE TABLE products (
  product_id    INT PRIMARY KEY,
  product_name  VARCHAR(255) NOT NULL,
  category_id   INT NOT NULL,
  price         DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
  order_id      INT PRIMARY KEY,
  customer_id   INT NOT NULL,
  order_date    DATE NOT NULL,
  total_amount  DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY,
  order_id      INT NOT NULL,
  product_id    INT NOT NULL,
  quantity      INT NOT NULL CHECK (quantity > 0),
  subtotal      DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
----------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
----------------------------------------------------------------------------------------
-- Indexes (optimization)
ALTER TABLE orders      ADD INDEX idx_orders_date (order_date);
ALTER TABLE products    ADD INDEX idx_products_name (product_name);
ALTER TABLE order_items ADD INDEX idx_order_items_prod_order (product_id, order_id);
--------------------------------------------------------------------------------------------

 -- Views for analysis
CREATE OR REPLACE VIEW v_order_item_details AS
SELECT 
  oi.order_item_id,
  oi.order_id,
  o.order_date,
  o.customer_id,
  c.name         AS customer_name,
  p.product_id,
  p.product_name         AS product_name,
  cat.category_name,
  oi.quantity,
  p.price,
  oi.subtotal
FROM order_items oi
JOIN orders   o   ON o.order_id = oi.order_id
JOIN products p   ON p.product_id = oi.product_id
JOIN customers c  ON c.customer_id = o.customer_id
JOIN categories cat ON cat.category_id = p.category_id;

CREATE OR REPLACE VIEW v_daily_sales AS
SELECT 
  o.order_date,
  COUNT(*)               AS orders_count,
  SUM(o.total_amount)    AS revenue
FROM orders o
GROUP BY o.order_date;

CREATE OR REPLACE VIEW v_customer_ltv AS
SELECT 
  cu.customer_id,
  cu.name AS customer_name,
  COUNT(o.order_id)              AS orders_count,
  IFNULL(SUM(o.total_amount),0)  AS lifetime_value,
  IFNULL(AVG(o.total_amount),0)  AS avg_order_value
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.name;

CREATE OR REPLACE VIEW v_category_sales AS
SELECT 
  cat.category_id,
  cat.category_name,
  SUM(oi.subtotal) AS category_sales
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
GROUP BY cat.category_id, cat.category_name;
-------------------------------------------------------------------------------------------------
-- Queries (SELECT/WHERE/ORDER BY/GROUP BY)
-------------------------------------------------------------------------------------------
-- Daily revenue (SELECT + GROUP BY + ORDER BY)

SELECT * FROM v_daily_sales ORDER BY order_date;

-- Top 5 products by sales revenue (JOIN + GROUP BY + ORDER BY + LIMIT)

SELECT 
  p.product_id, p.product_name AS product_name,
  SUM(oi.quantity) AS units_sold,
  SUM(oi.subtotal) AS sales
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY sales DESC
LIMIT 5;

-- Sales by category (JOIN chain + GROUP BY)

SELECT * FROM v_category_sales ORDER BY category_sales DESC;

-- Customer lifetime value (JOIN + GROUP BY + ORDER BY)
SELECT * FROM v_customer_ltv ORDER BY lifetime_value DESC, customer_name;

-- Customers who placed no orders (LEFT JOIN + WHERE IS NULL)
SELECT cu.customer_id, cu.name, cu.email
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL
ORDER BY cu.customer_id;

-- Customers with average order value above overall average (subquery + aggregate)
SELECT 
  cu.customer_id, cu.name, AVG(o.total_amount) AS avg_order_value
FROM customers cu
JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.name
HAVING AVG(o.total_amount) > (SELECT AVG(total_amount) FROM orders)
ORDER BY avg_order_value DESC;

-- Orders with more than 1 item (JOIN + GROUP BY + HAVING)
SELECT 
  oi.order_id,
  COUNT(*)   AS item_lines,
  SUM(oi.quantity) AS total_units,
  SUM(oi.subtotal) AS items_value
FROM order_items oi
GROUP BY oi.order_id
HAVING COUNT(*) > 1
ORDER BY items_value DESC;

-- Month-to-date revenue for September 2025 (WHERE + GROUP BY)
SELECT 
  DATE_FORMAT(o.order_date, '%Y-%m') AS ym,
  COUNT(*) AS orders_count,
  SUM(o.total_amount) AS revenue
FROM orders o
WHERE o.order_date >= '2025-09-01' AND o.order_date < '2025-10-01'
GROUP BY ym;

-- Highest-grossing category (subquery to get MAX)
SELECT cs.*
FROM v_category_sales cs
WHERE cs.category_sales = (
  SELECT MAX(category_sales) FROM v_category_sales
);

-- Top customers by total units purchased (multi-join + GROUP BY)
SELECT 
  cu.customer_id, cu.name,
  SUM(oi.quantity) AS units_purchased
FROM orders o
JOIN customers cu ON cu.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY cu.customer_id, cu.name
ORDER BY units_purchased DESC, cu.customer_id;

-- RIGHT JOIN example - all customers (even those with zero orders) with latest order date
SELECT 
  cu.customer_id, cu.name, MAX(o.order_date) AS latest_order
FROM orders o
RIGHT JOIN customers cu ON cu.customer_id = o.customer_id
GROUP BY cu.customer_id, cu.name
ORDER BY latest_order IS NULL, latest_order DESC;

-- Subquery: products priced above their category's average price
SELECT p.product_id, p.product_name AS product_name, cat.category_name, p.price
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
WHERE p.price > (
  SELECT AVG(p2.price) 
  FROM products p2 
  WHERE p2.category_id = p.category_id
)
ORDER BY cat.category_name, p.price DESC;



