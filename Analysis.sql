USE E_Commerce;
Select o.order_id,
o.customer_id,
p.payment_type,
p.payment_value,
r.review_score,
oi.product_id,
pr.product_category_name,
oi.seller_id,
oi.price,
oi.freight_value
from Orders_table o
Inner Join Customers_table c -- Join with customers table
on o.customer_id = c.customer_id
Inner Join Payments_table p 
on o.order_id = p.order_id -- Join with payments table
Left Join Customers_review_table r
on o.order_id = r.order_id -- Join with reviews table
Inner Join Order_items_table oi -- Join with order items table 
on o.order_id= oi.order_id
Inner Join Sellers_table s  -- Join with sellers table
on s.seller_id = oi.seller_id
Inner Join Products_table pr -- Join with products table
on oi.product_id = pr.product_id;


----1) How much total money has the platform made so far, and how has it changed over time?
-- Total revenue overall
SELECT SUM(payment_value) AS total_revenue
FROM payments_table;

-- Total revenue per month
SELECT 
    DATEFROMPARTS(
        YEAR(o.order_purchase_timestamp), 
        MONTH(o.order_purchase_timestamp), 
        1
    ) AS month,
    SUM(p.payment_value) AS monthly_revenue
FROM orders_table o
JOIN payments_table p ON o.order_id = p.order_id
GROUP BY 
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY month;

---2)Which product categories are the most popular, and how do their sales numbers compare?
SELECT 
    pr.product_category_name,
    COUNT(oi.order_id) AS total_sales
FROM Order_items_table oi
JOIN products_table pr 
ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY total_sales DESC;

---3) What is the average amount spent per order, and how does it change depending on the product category or payment method?

-- Overall average spend per order
SELECT 
    AVG(payment_value) AS avg_spent_per_order
FROM payments_table;

-- By product category
SELECT 
    pr.product_category_name,
    AVG(p.payment_value) AS avg_spent
FROM orders_table o
JOIN payments_table p 
ON o.order_id = p.order_id
JOIN Order_items_table oi 
ON o.order_id = oi.order_id
JOIN products_table pr 
ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY avg_spent DESC;

-- By payment type
SELECT 
    p.payment_type,
    AVG(p.payment_value) AS avg_spent
FROM payments_table p
GROUP BY p.payment_type;



----4) How many active sellers are there on the platform, and does this number go up or down over time?

-- Total distinct active sellers
SELECT COUNT(DISTINCT seller_id) AS total_active_sellers
FROM Order_items_table;

-- Active sellers by month
SELECT 
    DATEFROMPARTS(
        YEAR(o.order_purchase_timestamp), 
        MONTH(o.order_purchase_timestamp), 
        1
    ) AS month,
    COUNT(DISTINCT oi.seller_id) AS active_sellers
FROM orders_table o
JOIN Order_items_table oi ON o.order_id = oi.order_id
GROUP BY 
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY month;

---5) Which products sell the most, and how have their sales changed over time?
-- Total sales per product
SELECT TOP 10
    oi.product_id,
    COUNT(oi.order_id) AS total_sales
FROM Order_items_table oi
GROUP BY oi.product_id
ORDER BY total_sales DESC;

-- Monthly sales trend of top products
SELECT 
    oi.product_id,
    DATEFROMPARTS(
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp),
        1
    ) AS month,
    COUNT(oi.order_id) AS monthly_sales
FROM orders_table o
JOIN Order_items_table oi ON o.order_id = oi.order_id
GROUP BY 
    oi.product_id,
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY oi.product_id, month;


--6) Do customer reviews and ratings help products sell more or perform better on the platform? (Check sales with higher or lower ratings and identify if any correlation is there)
-- Sales grouped by review score
SELECT 
    r.review_score,
    COUNT(oi.order_id) AS total_sales,
    AVG(p.payment_value) AS avg_order_value
FROM Customers_review_table r
JOIN orders_table o ON r.order_id = o.order_id
JOIN Order_items_table oi ON o.order_id = oi.order_id
JOIN payments_table p ON o.order_id = p.order_id
GROUP BY r.review_score
ORDER BY r.review_score;


