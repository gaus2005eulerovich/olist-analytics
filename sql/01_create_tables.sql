-- Чистим на случай повторного запуска
DROP TABLE IF EXISTS customers CASCADE;

-- Клиенты маркетплейса
CREATE TABLE customers (
    customer_id              VARCHAR PRIMARY KEY,
    customer_unique_id       VARCHAR,
    customer_zip_code_prefix INTEGER,
    customer_city            VARCHAR,
    customer_state           VARCHAR
);

DROP TABLE IF EXISTS sellers CASCADE;

CREATE TABLE sellers (
    seller_id              VARCHAR PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city            VARCHAR,
    seller_state           VARCHAR
);

DROP TABLE IF EXISTS products CASCADE;

CREATE TABLE products (
    product_id                 VARCHAR PRIMARY KEY,
    product_category_name      VARCHAR,
    product_name_lenght        INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           INTEGER,
    product_length_cm          INTEGER,
    product_height_cm          INTEGER,
    product_width_cm           INTEGER
);

DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
    order_id                      VARCHAR PRIMARY KEY,
    customer_id                   VARCHAR,
    order_status                  VARCHAR,
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

DROP TABLE IF EXISTS order_items CASCADE;

CREATE TABLE order_items (
    order_id            VARCHAR,
    order_item_id       INTEGER,
    product_id          VARCHAR,
    seller_id           VARCHAR,
    shipping_limit_date TIMESTAMP,
    price               NUMERIC,
    freight_value       NUMERIC
);

DROP TABLE IF EXISTS order_payments CASCADE;

CREATE TABLE order_payments (
    order_id             VARCHAR,
    payment_sequential   INTEGER,
    payment_type         VARCHAR,
    payment_installments INTEGER,
    payment_value        NUMERIC
);

DROP TABLE IF EXISTS order_reviews CASCADE;

CREATE TABLE order_reviews (
    review_id               VARCHAR,
    order_id                VARCHAR,
    review_score            INTEGER,
    review_comment_title    VARCHAR,
    review_comment_message  VARCHAR,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

DROP TABLE IF EXISTS geolocation CASCADE;

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             NUMERIC,
    geolocation_lng             NUMERIC,
    geolocation_city            VARCHAR,
    geolocation_state           VARCHAR
);

DROP TABLE IF EXISTS category_translation CASCADE;

CREATE TABLE category_translation (
    product_category_name         VARCHAR,
    product_category_name_english VARCHAR
);

TRUNCATE TABLE order_reviews;
TRUNCATE TABLE order_reviews;

COPY order_reviews
FROM '/Users/max/olist-analytics/data/olist_order_reviews_dataset.csv'
WITH (FORMAT csv, HEADER true, QUOTE '"', ESCAPE '"');

TRUNCATE customers, sellers, products, orders, order_items,
         order_payments, order_reviews, geolocation, category_translation;


COPY customers FROM '/Users/max/olist-analytics/data/olist_customers_dataset.csv'
WITH (FORMAT csv, HEADER true);

COPY sellers FROM '/Users/max/olist-analytics/data/olist_sellers_dataset.csv'
WITH (FORMAT csv, HEADER true);

COPY products FROM '/Users/max/olist-analytics/data/olist_products_dataset.csv'
WITH (FORMAT csv, HEADER true);

COPY orders FROM '/Users/max/olist-analytics/data/olist_orders_dataset.csv'
WITH (FORMAT csv, HEADER true);

COPY order_items FROM '/Users/max/olist-analytics/data/olist_order_items_dataset.csv'
WITH (FORMAT csv, HEADER true);

COPY order_payments FROM '/Users/max/olist-analytics/data/olist_order_payments_dataset.csv'
WITH (FORMAT csv, HEADER true);

COPY geolocation FROM '/Users/max/olist-analytics/data/olist_geolocation_dataset.csv'
WITH (FORMAT csv, HEADER true);

COPY category_translation FROM '/Users/max/olist-analytics/data/product_category_name_translation.csv'
WITH (FORMAT csv, HEADER true);



SELECT 'customers'            AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'sellers',              COUNT(*) FROM sellers
UNION ALL SELECT 'products',             COUNT(*) FROM products
UNION ALL SELECT 'orders',               COUNT(*) FROM orders
UNION ALL SELECT 'order_items',          COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments',       COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',        COUNT(*) FROM order_reviews
UNION ALL SELECT 'geolocation',          COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation
ORDER BY rows DESC;