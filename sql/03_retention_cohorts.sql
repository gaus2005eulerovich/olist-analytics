WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE orders_count > 1) AS returning_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders_count > 1) / COUNT(*), 2) AS retention_rate_pct
FROM customer_orders;


WITH first_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
orders_with_cohort AS (
    SELECT
        c.customer_unique_id,
        fo.cohort_month,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_orders fo ON c.customer_unique_id = fo.customer_unique_id
    WHERE o.order_status = 'delivered'
)
SELECT
    cohort_month,
    order_month,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM orders_with_cohort
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;


WITH first_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
orders_with_cohort AS (
    SELECT
        c.customer_unique_id,
        fo.cohort_month,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_orders fo ON c.customer_unique_id = fo.customer_unique_id
    WHERE o.order_status = 'delivered'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS total
    FROM orders_with_cohort
    WHERE cohort_month = order_month
    GROUP BY cohort_month
)
SELECT
    owc.cohort_month,
    (EXTRACT(YEAR FROM owc.order_month) - EXTRACT(YEAR FROM owc.cohort_month)) * 12
        + (EXTRACT(MONTH FROM owc.order_month) - EXTRACT(MONTH FROM owc.cohort_month)) AS month_number,
    COUNT(DISTINCT owc.customer_unique_id) AS customers,
    ROUND(100.0 * COUNT(DISTINCT owc.customer_unique_id) / cs.total, 2) AS retention_pct
FROM orders_with_cohort owc
JOIN cohort_size cs ON owc.cohort_month = cs.cohort_month
GROUP BY owc.cohort_month, month_number, cs.total
ORDER BY owc.cohort_month, month_number;

