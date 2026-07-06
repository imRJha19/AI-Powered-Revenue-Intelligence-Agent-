/* these are just sql code for the revenue kpis alongside with their usage code */



1. Daily Revenue View
  
CREATE VIEW vw_daily_revenue AS
SELECT
    CAST(order_date AS DATE) AS order_date,
    SUM(sales_amount) AS revenue
FROM dbo.fact_sales
GROUP BY
    CAST(order_date AS DATE);

/*
  Usage
  SELECT *
  FROM vw_daily_revenue
  ORDER BY order_date;  
*/


2. Monthly Revenue View
CREATE VIEW vw_monthly_revenue AS
SELECT
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
    SUM(sales_amount) AS revenue
FROM dbo.fact_sales
GROUP BY
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1);

/*
Usage
SELECT *
FROM vw_monthly_revenue
ORDER BY month_start;
*/


3. Revenue by Country View
CREATE VIEW vw_revenue_by_country AS
SELECT
    c.country,
    SUM(f.sales_amount) AS revenue
FROM dbo.fact_sales f
INNER JOIN dbo.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.country;
/*
Usage
SELECT *
FROM vw_revenue_by_country
ORDER BY revenue DESC;
*/


4. Revenue by Category View
CREATE VIEW vw_revenue_by_category AS
SELECT
    p.category,
    SUM(f.sales_amount) AS revenue
FROM dbo.fact_sales f
INNER JOIN dbo.dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.category;

/*
Usage
SELECT *
FROM vw_revenue_by_category
ORDER BY revenue DESC;
*/


5. Revenue by Product View (Important for Root Cause Analysis)
CREATE VIEW vw_revenue_by_product AS
SELECT
    p.product_name,
    SUM(f.sales_amount) AS revenue
FROM dbo.fact_sales f
INNER JOIN dbo.dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_name;


/*
Usage
SELECT TOP 20 *
FROM vw_revenue_by_product
ORDER BY revenue DESC;
*/


6. Revenue by Customer View
CREATE VIEW vw_revenue_by_customer AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS revenue
FROM dbo.fact_sales f
INNER JOIN dbo.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;





7. Daily orders view 
CREATE VIEW vw_daily_orders AS
SELECT
    CAST(order_date AS DATE) AS order_date,
    COUNT(DISTINCT order_number) AS total_orders
FROM dbo.fact_sales
GROUP BY CAST(order_date AS DATE);


8. Daily QTY view 
CREATE VIEW vw_daily_quantity AS
SELECT
    CAST(order_date AS DATE) AS order_date,
    SUM(quantity) AS total_quantity
FROM dbo.fact_sales
GROUP BY CAST(order_date AS DATE);



9. Daily avg price view 
CREATE VIEW vw_daily_avg_price AS
SELECT
    CAST(order_date AS DATE) AS order_date,
    AVG(price) AS avg_price
FROM dbo.fact_sales
GROUP BY CAST(order_date AS DATE);
