WITH order_revenue AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        SUM(oi.price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id, c.customer_unique_id
)
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    ROUND(SUM(order_value) / COUNT(DISTINCT customer_unique_id), 2) AS revenue_per_customer
FROM order_revenue;

SELECT
    ct.product_category_name_english AS category,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 2) AS revenue_share_pct,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC
LIMIT 15;


SELECT
    p.payment_type,
    COUNT(*) AS payments_count,
    ROUND(AVG(p.payment_installments), 1) AS avg_installments,
    ROUND(SUM(p.payment_value), 2) AS total_value,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_pct
FROM order_payments p
GROUP BY p.payment_type
ORDER BY total_value DESC;


SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;


