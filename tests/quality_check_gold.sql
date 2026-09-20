/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    Validates the integrity of the Gold layer's star schema after the views
    have been built — specifically:
    - Uniqueness of each dimension's business key
    - Referential integrity between fact_sales and each dimension
    - No unintended row multiplication (fan-out) introduced by the view joins
    - Sanity checks on measures (no negative revenue, etc.)

Usage:
    - Run each block individually and review results. 
	  - An EMPTY result set = PASS. 
	  - Any returned rows indicate the exact records that violate the rule.
===============================================================================
*/

-- =============================================================================
-- Dimension key uniqueness
-- =============================================================================

-- gold.dim_customers: customer_id should be unique
-- Expectation: No results
SELECT
	customer_id, 
	COUNT(*) AS occurrences
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- gold.dim_orders: order_id should be unique
-- Expectation: No results
SELECT 
	order_id, 
	COUNT(*) AS occurrences
FROM gold.dim_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- gold.dim_products: product_id should be unique
-- Expectation: No results
SELECT 
	product_id, 
	COUNT(*) AS occurrences
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- gold.dim_sellers: seller_id should be unique
-- Expectation: No results
SELECT 
	seller_id, 
	COUNT(*) AS occurrences
FROM gold.dim_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- gold.dim_payments: (order_id, payment_sequential) is its composite key —
-- Expectation: No results 
SELECT 
	order_id, 
	payment_sequential, 
	COUNT(*) AS occurrences
FROM gold.dim_payments
GROUP BY
	order_id, 
	payment_sequential
HAVING COUNT(*) > 1;

-- =============================================================================
-- gold.fact_sales: key integrity
-- =============================================================================

-- Check: NULL or duplicate sale_id (fact table's own key)
-- Expectation: No results
SELECT 
	sale_id, 
	COUNT(*) AS occurrences
FROM gold.fact_sales
GROUP BY sale_id
HAVING COUNT(*) > 1 
	OR sale_id IS NULL;

-- Check: row count of fact_sales should exactly match silver.order_items —
-- Expectation: both counts are equal
SELECT
    (SELECT COUNT(*) FROM gold.fact_sales) AS fact_sales_rows,
    (SELECT COUNT(*) FROM silver.order_items) AS silver_order_items_rows;

-- =============================================================================
-- Referential integrity: fact_sales -> each dimension
-- =============================================================================

-- Check: every order_id in fact_sales exists in dim_orders
-- Expectation: No results
SELECT DISTINCT fs.order_id
FROM gold.fact_sales fs
LEFT JOIN gold.dim_orders d 
	ON fs.order_id = d.order_id
WHERE d.order_id IS NULL;

-- Check: every product_id in fact_sales exists in dim_products
-- Expectation: No results
SELECT DISTINCT fs.product_id
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products d 
	ON fs.product_id = d.product_id
WHERE d.product_id IS NULL;

-- Check: every seller_id in fact_sales exists in dim_sellers
-- Expectation: No results
SELECT DISTINCT fs.seller_id
FROM gold.fact_sales fs
LEFT JOIN gold.dim_sellers d 
	ON fs.seller_id = d.seller_id
WHERE d.seller_id IS NULL;

-- Check: every customer_id in fact_sales exists in dim_customers
-- Expectation: No results
SELECT DISTINCT fs.customer_id
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers d 
	ON fs.customer_id = d.customer_id
WHERE fs.customer_id IS NOT NULL
  AND d.customer_id IS NULL;

-- Check: fact_sales rows where the LEFT JOIN to orders produced no customer_id at all
-- Expectation: No results
SELECT sale_id, order_id
FROM gold.fact_sales
WHERE customer_id IS NULL;

-- =============================================================================
-- Referential integrity: dim_payments -> dim_orders
-- =============================================================================

-- Check: every order_id in dim_payments exists in dim_orders
-- Expectation: No results
SELECT DISTINCT dp.order_id
FROM gold.dim_payments dp
LEFT JOIN gold.dim_orders d 
	ON dp.order_id = d.order_id
WHERE d.order_id IS NULL;

-- =============================================================================
-- Measure sanity checks
-- =============================================================================

-- Check: negative or zero-priced items in fact_sales
-- Expectation: No results
SELECT 
	sale_id, 
	order_id, 
	unit_price, 
	unit_freight_value
FROM gold.fact_sales
WHERE unit_price <= 0 
	OR unit_freight_value < 0;

-- Check: negative payment values in dim_payments
-- Expectation: No results
SELECT 
	order_id, 
	payment_sequential, 
	payment_value
FROM gold.dim_payments
WHERE payment_value < 0;
