Sales Analysis Summary Document: SQL + Power BI
1. SQL Queries Overview
1.1 Total Platform Revenue & Trend

SELECT 
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS month,
    SUM(payment_value) AS total_revenue
FROM orders_table o
JOIN payments_table p ON o.order_id = p.order_id
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY month;

1.2 Popular Product Categories

SELECT 
    pt.product_category_name,
    COUNT(oi.order_id) AS total_sales
FROM order_items_table oi
JOIN products_table pt ON oi.product_id = pt.product_id
GROUP BY pt.product_category_name
ORDER BY total_sales DESC;

1.3 Average Spend per Order by Category & Payment Method

SELECT 
    pt.product_category_name,
    pay.payment_type,
    AVG(pay.payment_value) AS avg_spend
FROM orders_table o
JOIN order_items_table oi ON o.order_id = oi.order_id
JOIN products_table pt ON oi.product_id = pt.product_id
JOIN payments_table pay ON o.order_id = pay.order_id
GROUP BY pt.product_category_name, pay.payment_type
ORDER BY avg_spend DESC;

1.4 Active Sellers Over Time

SELECT 
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS month,
    COUNT(DISTINCT oi.seller_id) AS active_sellers
FROM orders_table o
JOIN order_items_table oi ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY month;

1.5 Top-Selling Products and Monthly Trends

-- Top 10 Products by Sales
SELECT TOP 10
    product_id,
    COUNT(order_id) AS total_sales
FROM order_items_table
GROUP BY product_id
ORDER BY total_sales DESC;

-- Monthly Sales Trend of Top Products
SELECT 
    oi.product_id,
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS month,
    COUNT(oi.order_id) AS monthly_sales
FROM order_items_table oi
JOIN orders_table o ON oi.order_id = o.order_id
GROUP BY oi.product_id, FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY oi.product_id, month;

1.6 Impact of Reviews on Sales

SELECT 
    r.review_score,
    COUNT(DISTINCT oi.order_id) AS order_count,
    AVG(p.payment_value) AS avg_revenue
FROM order_items_table oi
JOIN orders_table o ON oi.order_id = o.order_id
JOIN payments_table p ON o.order_id = p.order_id
JOIN customers_review_table r ON o.order_id = r.order_id
GROUP BY r.review_score
ORDER BY r.review_score DESC;

2. Power BI Dashboard Creation

Data Files Used:
- Customers_table.csv
- Orders_table.csv
- Order_items_table.csv
- Payments_table.csv
- Products_table.csv
- Customers_review_table.csv

Steps:
1. Load all files using Home > Get Data > Text/CSV.
2. Set proper data types for keys (order_id, customer_id, etc.)
3. Define relationships in the Model view between these tables.
4. Build visuals using the fields and DAX measures.

3. Key DAX Formulas
Customer Order Count (Measure):

OrderCount = 
CALCULATE(
    COUNTROWS(Orders_table),
    Orders_table[customer_id] = SELECTEDVALUE(Customers_table[customer_id])
)

Customer Type (Calculated Column):

CustomerType = 
VAR OrderCount =
    CALCULATE(
        COUNTROWS(Orders_table),
        FILTER(Orders_table, Orders_table[customer_id] = Customers_table[customer_id])
    )
RETURN IF(OrderCount > 1, "Repeat", "One-Time")


Customer Revenue:

CustomerRevenue = 
CALCULATE(
    SUM(Payments_table[payment_value]),
    FILTER(Orders_table, Orders_table[customer_id] = Customers_table[customer_id])
)

Concatenate Full Name:

FullName = Customers_table[first_name] & " " & Customers_table[last_name]

Customer List Measure:

CustomerList = 
CONCATENATEX(
    VALUES(Customers_table[customer_id]),
    Customers_table[customer_id],
    ", "
)

