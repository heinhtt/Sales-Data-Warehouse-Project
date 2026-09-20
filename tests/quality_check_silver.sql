/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    Validates data quality, standardization, and consistency in the Silver
    layer, after cleansing but before it feeds the Gold layer.

    Checks performed:
    - Null or duplicate primary/business keys
    - Unwanted leading/trailing whitespace in string fields
    - Standardization/consistency of categorical values
    - Invalid or out-of-order dates
    - Invalid numeric ranges (negative prices, zero/negative dimensions)
    - Orphaned foreign keys (referential integrity within Silver)

Usage:
    - Run each block individually and review results. 
    - An EMPTY result = PASS. 
    - Any returned rows indicate the exact records that violate the rule.
===============================================================================
*/

-- =============================================================================
-- silver.customers
-- =============================================================================

-- Check: NULL or duplicate customer_id (primary key)
-- Expectation: No results
SELECT
	customer_id,
	COUNT(*) AS occurrences
FROM silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1 
	OR customer_id IS NULL;

-- Check: unwanted whitespace in city/state
-- Expectation: No results
SELECT 
	customer_id, 
	customer_city, 
	customer_state
FROM silver.customers
WHERE customer_city <> TRIM(customer_city)
   OR customer_state <> TRIM(customer_state);

-- Check: customer_state standardization — should always be exactly 2 uppercase letters
-- Expectation: No results
SELECT DISTINCT customer_state
FROM silver.customers
WHERE customer_state !~ '^[A-Z]{2}$';

-- =============================================================================
-- silver.sellers
-- =============================================================================

-- Check: NULL or duplicate seller_id (primary key)
-- Expectation: No results
SELECT 
	seller_id, 
	COUNT(*) AS occurrences
FROM silver.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1 
	OR seller_id IS NULL;

-- Check: unwanted whitespace in city/state
-- Expectation: No results
SELECT 
	seller_id, 
	seller_city, 
	seller_state
FROM silver.sellers
WHERE seller_city <> TRIM(seller_city)
   OR seller_state <> TRIM(seller_state);

-- Check: seller_state standardization
-- Expectation: No results
SELECT DISTINCT seller_state
FROM silver.sellers
WHERE seller_state !~ '^[A-Z]{2}$';

-- =============================================================================
-- silver.orders
-- =============================================================================

-- Check: NULL or duplicate order_id (primary key)
-- Expectation: No results
SELECT 
	order_id, 
	COUNT(*) AS occurrences
FROM silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1 
	OR order_id IS NULL;

-- Check: order_status standardization — review the full set of distinct values
-- Expectation: only the 8 known statuses
SELECT DISTINCT order_status
FROM silver.orders
ORDER BY order_status;

-- Check: invalid date sequencing — approval before purchase
-- Expectation: No results
SELECT 
	order_id, 
	order_purchase_timestamp, 
	order_approved_at
FROM silver.orders
WHERE order_approved_at IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;

-- Check: invalid date sequencing — delivery before purchase or before approval
-- Expectation: No results
SELECT
	order_id, 
	order_purchase_timestamp, 
	order_approved_at, 
	order_delivered_customer_date
FROM silver.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND (
  	order_delivered_customer_date < order_purchase_timestamp
	OR (order_approved_at IS NOT NULL AND order_delivered_customer_date < order_approved_at)
  );

-- Check: orders marked 'delivered' but missing a delivered date
-- Expectation: No results 
SELECT 
	order_id, 
	order_status, 
	order_delivered_customer_date
FROM silver.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- =============================================================================
-- silver.order_items
-- =============================================================================

-- Check: NULLs in key columns (order_id, product_id, seller_id are mandatory FKs)
-- Expectation: No results
SELECT
	sale_id, 
	order_id, 
	product_id, 
	seller_id
FROM silver.order_items
WHERE order_id IS NULL 
	OR product_id IS NULL 
	OR seller_id IS NULL;

-- Check: negative or zero price/freight — not valid for a real sale
-- Expectation: No results
SELECT 
	sale_id, 
	order_id, 
	price, 
	freight_value
FROM silver.order_items
WHERE price <= 0 
	OR freight_value < 0;

-- Check: orphaned order_id — every order_item should trace back to a real order
-- Expectation: No results
SELECT 
	oi.sale_id, 
	oi.order_id
FROM silver.order_items oi
LEFT JOIN silver.orders o 
	ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- =============================================================================
-- silver.order_payments
-- =============================================================================

-- Check: NULLs in order_id or negative payment_value
-- Expectation: No results
SELECT 
	order_id, 
	payment_sequential, 
	payment_value
FROM silver.order_payments
WHERE order_id IS NULL 
	OR payment_value < 0;

-- Check: payment_installments should be at least 1
-- Expectation: No results
SELECT 
	order_id, 
	payment_sequential, 
	payment_installments
FROM silver.order_payments
WHERE payment_installments < 1;

-- Check: payment_type standardization — review distinct values
-- Expectation: only the 4 known payment types
SELECT DISTINCT payment_type
FROM silver.order_payments
ORDER BY payment_type;

-- Check: orphaned order_id — every payment should trace back to a real order
-- Expectation: No results
SELECT op.order_id
FROM silver.order_payments op
LEFT JOIN silver.orders o 
	ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- =============================================================================
-- silver.products
-- =============================================================================

-- Check: NULL or duplicate product_id (primary key)
-- Expectation: No results
SELECT 
	product_id, 
	COUNT(*) AS occurrences
FROM silver.products
GROUP BY product_id
HAVING COUNT(*) > 1 
	OR product_id IS NULL;

-- Check: non-positive dimensions/weight where present (should be NULL, never <= 0)
-- Expectation: No results
SELECT 
	product_id, 
	product_weight_g, 
	product_length_cm, 
	product_height_cm, 
	product_width_cm
FROM silver.products
WHERE product_weight_g <= 0
	OR product_length_cm <= 0
    OR product_height_cm <= 0
    OR product_width_cm <= 0;

-- Check: products whose category has no match in the translation table
-- Expectation: No results 
SELECT 
	DISTINCT p.product_category_name,
	t.product_category_name_english
FROM silver.products p
LEFT JOIN silver.product_category_name_translation t
	ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
	AND t.product_category_name IS NULL;

-- =============================================================================
-- silver.product_category_name_translation
-- =============================================================================

-- Check: NULL or duplicate product_category_name (primary key)
-- Expectation: No results
SELECT
	product_category_name, 
	COUNT(*) AS occurrences
FROM silver.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1 
	OR product_category_name IS NULL;
