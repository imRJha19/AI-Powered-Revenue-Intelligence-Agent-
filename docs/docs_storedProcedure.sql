-- storedprocedure for RCA 

CREATE PROCEDURE usp_RootCauseAnalysis
    @anomaly_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- 1. PRIMARY DRIVER
    ------------------------------------------------------------
    SELECT
        order_date,
        revenue_change_pct,
        orders_change_pct,
        quantity_change_pct,
        price_change_pct,

        CASE
            WHEN ABS(orders_change_pct) >= ABS(price_change_pct)
             AND ABS(quantity_change_pct) >= ABS(price_change_pct)
            THEN 'Demand Driven'

            WHEN ABS(price_change_pct) > ABS(orders_change_pct)
             AND ABS(price_change_pct) > ABS(quantity_change_pct)
            THEN 'Price Driven'

            ELSE 'Mixed Driver'
        END AS primary_driver

    FROM vw_revenue_driver_monitoring
    WHERE order_date = @anomaly_date;


    ------------------------------------------------------------
    -- 2. COUNTRY RCA
    ------------------------------------------------------------
    ;WITH anomaly_day AS
    (
        SELECT
            c.country,
            SUM(f.sales_amount) AS anomaly_revenue
        FROM fact_sales f
        INNER JOIN dim_customers c
            ON f.customer_key = c.customer_key
        WHERE CAST(f.order_date AS DATE) = @anomaly_date
        GROUP BY c.country
    ),

    previous_7_days AS
    (
        SELECT
            country,
            AVG(daily_revenue) AS avg_7day_revenue
        FROM
        (
            SELECT
                CAST(f.order_date AS DATE) AS order_date,
                c.country,
                SUM(f.sales_amount) AS daily_revenue
            FROM fact_sales f
            INNER JOIN dim_customers c
                ON f.customer_key = c.customer_key
            WHERE CAST(f.order_date AS DATE)
                BETWEEN DATEADD(DAY,-7,@anomaly_date)
                    AND DATEADD(DAY,-1,@anomaly_date)
            GROUP BY
                CAST(f.order_date AS DATE),
                c.country
        ) x
        GROUP BY country
    )

    SELECT
        a.country,
        a.anomaly_revenue,
        p.avg_7day_revenue,
        CAST(
            ROUND(
                (a.anomaly_revenue-p.avg_7day_revenue)
                *100.0/
                NULLIF(p.avg_7day_revenue,0),
            2)
        AS DECIMAL(10,2)) AS revenue_change_pct

    FROM anomaly_day a
    LEFT JOIN previous_7_days p
        ON a.country=p.country
    ORDER BY revenue_change_pct DESC;


    ------------------------------------------------------------
    -- 3. CATEGORY RCA
    ------------------------------------------------------------
    ;WITH anomaly_day AS
    (
        SELECT
            p.category,
            SUM(f.sales_amount) AS anomaly_revenue
        FROM fact_sales f
        INNER JOIN dim_products p
            ON f.product_key=p.product_key
        WHERE CAST(f.order_date AS DATE)=@anomaly_date
        GROUP BY p.category
    ),

    previous_7_days AS
    (
        SELECT
            category,
            AVG(daily_revenue) AS avg_7day_revenue
        FROM
        (
            SELECT
                CAST(f.order_date AS DATE) AS order_date,
                p.category,
                SUM(f.sales_amount) AS daily_revenue
            FROM fact_sales f
            INNER JOIN dim_products p
                ON f.product_key=p.product_key
            WHERE CAST(f.order_date AS DATE)
                BETWEEN DATEADD(DAY,-7,@anomaly_date)
                    AND DATEADD(DAY,-1,@anomaly_date)
            GROUP BY
                CAST(f.order_date AS DATE),
                p.category
        ) x
        GROUP BY category
    )

    SELECT
        a.category,
        a.anomaly_revenue,
        p.avg_7day_revenue,
        CAST(
            ROUND(
                (a.anomaly_revenue-p.avg_7day_revenue)
                *100.0/
                NULLIF(p.avg_7day_revenue,0),
            2)
        AS DECIMAL(10,2)) AS revenue_change_pct

    FROM anomaly_day a
    LEFT JOIN previous_7_days p
        ON a.category=p.category
    ORDER BY revenue_change_pct DESC;


    ------------------------------------------------------------
    -- 4. PRODUCT RCA
    ------------------------------------------------------------
    ;WITH anomaly_day AS
    (
        SELECT
            p.product_name,
            SUM(f.sales_amount) AS anomaly_revenue
        FROM fact_sales f
        INNER JOIN dim_products p
            ON f.product_key=p.product_key
        WHERE CAST(f.order_date AS DATE)=@anomaly_date
        GROUP BY p.product_name
    ),

    previous_7_days AS
    (
        SELECT
            product_name,
            AVG(daily_revenue) AS avg_7day_revenue
        FROM
        (
            SELECT
                CAST(f.order_date AS DATE) AS order_date,
                p.product_name,
                SUM(f.sales_amount) AS daily_revenue
            FROM fact_sales f
            INNER JOIN dim_products p
                ON f.product_key=p.product_key
            WHERE CAST(f.order_date AS DATE)
                BETWEEN DATEADD(DAY,-7,@anomaly_date)
                    AND DATEADD(DAY,-1,@anomaly_date)
            GROUP BY
                CAST(f.order_date AS DATE),
                p.product_name
        ) x
        GROUP BY product_name
    )

    SELECT TOP (10)
        a.product_name,
        a.anomaly_revenue,
        p.avg_7day_revenue,
        CAST(
            ROUND(
                (a.anomaly_revenue-p.avg_7day_revenue)
                *100.0/
                NULLIF(p.avg_7day_revenue,0),
            2)
        AS DECIMAL(10,2)) AS revenue_change_pct

    FROM anomaly_day a
    LEFT JOIN previous_7_days p
        ON a.product_name=p.product_name
    ORDER BY revenue_change_pct DESC;

END;
GO

