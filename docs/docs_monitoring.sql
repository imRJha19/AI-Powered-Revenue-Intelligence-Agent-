CREATE VIEW [dbo].[vw_daily_revenue_monitoring] AS

WITH daily_revenue AS (

    SELECT
        CAST(order_date AS DATE) AS order_date,
        SUM(sales_amount) AS revenue
    FROM dbo.fact_sales
    GROUP BY CAST(order_date AS DATE)

)

SELECT
    order_date,
    revenue,

    AVG(revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7_day_avg,

    AVG(revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30_day_avg

FROM daily_revenue;


CREATE VIEW vw_daily_revenue_monitoring_v2 AS

WITH daily_revenue AS (

    SELECT
        CAST(order_date AS DATE) AS order_date,
        SUM(sales_amount) AS revenue
    FROM dbo.fact_sales
    GROUP BY CAST(order_date AS DATE)

)

SELECT
    order_date,
    revenue,

    AVG(revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7_day_avg,

    cast(round((
        revenue -
        AVG(revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )
    ) * 100.0
    /
    NULLIF(
        AVG(revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        0
    ),2) as decimal(10,2) ) AS percentage_deviation 

FROM daily_revenue;
