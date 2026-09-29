SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late'
        ELSE 'on_time'
    END AS delivery_status,
    COUNT(*) AS orders_count,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN '1. on time or early'
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date + INTERVAL '3 days' THEN '2. late 1-3 days'
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date + INTERVAL '7 days' THEN '3. late 4-7 days'
        ELSE '4. late 8+ days'
    END AS delay_bucket,
    COUNT(*) AS orders_count,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delay_bucket
ORDER BY delay_bucket;



WITH customer_delivery AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
            ELSE 0
        END AS is_late
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
),
first_experience AS (
    SELECT
        customer_unique_id,
        MAX(is_late) AS had_late_delivery,
        COUNT(DISTINCT order_id) AS total_orders
    FROM customer_delivery
    GROUP BY customer_unique_id
)
SELECT
    CASE WHEN had_late_delivery = 1 THEN 'had late delivery' ELSE 'always on time' END AS experience,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE total_orders > 1) / COUNT(*), 2) AS repeat_rate_pct
FROM first_experience
GROUP BY experience;


