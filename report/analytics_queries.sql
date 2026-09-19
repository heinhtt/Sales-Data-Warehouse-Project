/*
=====================================================================================
Query 1: Revenue & Order Volume by Product Category
=====================================================================================
Business question: 1. Which product categories drive the most revenue?
				           2. How does that compare to order volume?
Purpose: Identify which product categories drive the most revenue and
         compare that against order volume (bulk-buy vs. broad-reach categories).
Functions used: COUNT(DISTINCT), COUNT(), SUM(), AVG(), ROUND(), CAST (::numeric)
=====================================================================================
*/

SELECT
    d_p.product_cat_name_eng AS product_category,
    COUNT(DISTINCT f_s.order_id) AS order_count,
    COUNT(f_s.sale_id) AS items_sold,
    ROUND(SUM(f_s.unit_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(f_s.unit_price)::numeric, 2) AS avg_item_price
FROM gold.fact_sales AS f_s
JOIN gold.dim_products AS d_p 
	ON f_s.product_id = d_p.product_id
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 10;

/*
=====================================================================================
Query 2: Monthly Revenue Trend
=====================================================================================
Business question: 1. Is revenue growing month over month? 
				           2. Are there seasonal spikes?
Purpose: Track revenue and order volume over time to spot growth or seasonality.
Functions used: DATE_TRUNC(), COUNT(DISTINCT), SUM(), ROUND(), CAST
=====================================================================================
*/

SELECT
    DATE_TRUNC('month', d_o.order_purchase_timestamp)::date AS order_month,
    COUNT(DISTINCT f_s.order_id) AS order_count,
    ROUND(SUM(f_s.unit_price)::numeric, 2) AS total_revenue
FROM gold.fact_sales AS f_s
JOIN gold.dim_orders AS d_o 
	ON f_s.order_id = d_o.order_id
WHERE d_o.order_status
	NOT IN ('canceled', 'unavailable')
GROUP BY order_month
ORDER BY order_month;

/*
=====================================================================================
Query 3: Top 10 Sellers by Revenue
=====================================================================================
Business question: 1. Who are the highest-performing sellers?
				           2. Where are they located?
Purpose: Rank sellers by revenue and surface their location, so performance
         can later be cross-checked against geography or delivery speed.
Functions used: COUNT(), SUM(), ROUND(), CAST
=====================================================================================
*/

SELECT
    d_s.seller_id,
    d_s.seller_city,
    d_s.seller_state,
    COUNT(f_s.sale_id) AS items_sold,
    ROUND(SUM(f_s.unit_price)::numeric, 2) AS total_revenue
FROM gold.fact_sales AS f_s
JOIN gold.dim_sellers AS d_s
	ON f_s.seller_id = d_s.seller_id
GROUP BY d_s.seller_id, d_s.seller_city, d_s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;

/*
=====================================================================================
Query 4: Delivery Performance — Actual vs. Estimated
=====================================================================================
Business question: 1. How reliable is the delivery estimate?
				           2. What share of orders arrive late?
Purpose: Measure average delivery time and the share of orders that arrive
         later than the estimated delivery date, broken out by order status.
Functions used: EXTRACT(EPOCH FROM ...), AVG(), CASE WHEN, SUM(),
                NULLIF() (divide-by-zero guard), ROUND()
=====================================================================================
*/

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(AVG(EXTRACT(
      EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400
    )::numeric, 1) AS avg_days_to_deliver,
    ROUND(100.0 * SUM(
      CASE WHEN
			  order_delivered_customer_date > order_estimated_delivery_date
				THEN 1
				ELSE 0
		  END
    ) / NULLIF(COUNT(order_delivered_customer_date), 0), 1) AS delivered_late_rate
FROM gold.dim_orders
GROUP BY order_status
ORDER BY order_count DESC;

/*
=====================================================================================
Query 5: Customer payment behavior
=====================================================================================
Business question: 1. How do customers prefer to pay? 
				           2. How much do they finance via installments?
Purpose: Understand how customers pay (credit card, boleto, voucher, etc.)
         and how heavily they rely on installment financing.
Functions used: COUNT(), AVG(), SUM(), ROUND(), CAST
=====================================================================================
*/

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(AVG(payment_installments)::numeric, 1) AS avg_installments,
    ROUND(SUM(payment_value)::numeric, 2) AS total_paid,
    ROUND(AVG(payment_value)::numeric, 2) AS avg_payment_value
FROM gold.dim_payments
GROUP BY payment_type
ORDER BY total_paid DESC;

/*
=====================================================================================
Query 6: Revenue by Customers' Geography
=====================================================================================
Business question: 1. Which states generate the most revenue?
				           2. What's the average order value there?
Purpose: Identify which states generate the most revenue and what the
         average order value looks like there.
Functions used: COUNT(DISTINCT), SUM(), ROUND(), CAST
=====================================================================================
*/

SELECT
    d_c.customer_state,
    COUNT(DISTINCT f_s.order_id) AS order_count,
    ROUND(SUM(f_s.unit_price)::numeric, 2) AS total_revenue,
    ROUND(SUM(f_s.unit_price)::numeric / COUNT(DISTINCT f_s.order_id), 2) AS avg_order_value
FROM gold.fact_sales AS f_s
JOIN gold.dim_customers AS d_c
	ON f_s.customer_id = d_c.customer_id
GROUP BY d_c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;

/*
=====================================================================================
Query 7: Order distribution 
=====================================================================================
Business question: What share of orders never make it to delivery?
Purpose: See what share of orders end in each status (delivered, canceled,
         unavailable, etc.) to gauge fulfillment reliability.
Functions used: COUNT(), window function SUM(COUNT(*)) OVER (), ROUND()
=====================================================================================
*/

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentage_of_total
FROM gold.dim_orders
GROUP BY order_status
ORDER BY order_count DESC;

/*
=====================================================================================
Query 8: Order Item Total vs. Amount Paid (Aggregate-Then-Join Pattern)
=====================================================================================
Business question: Does the sum of item prices per order match what was actually paid? 
Purpose: Cross-check whether the sum of item prices per order matches what
         was actually paid.
Functions used: CTEs (WITH), SUM(), COUNT(), ROUND(), CAST, ABS()
=====================================================================================
*/

WITH sales_per_order AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(unit_price + unit_freight_value) AS total_order_amt
    FROM gold.fact_sales
    GROUP BY order_id
),
payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_paid_amt
    FROM gold.dim_payments
    GROUP BY order_id
)
SELECT
    d_o.order_id,
    d_o.order_status,
    so.item_count,
    ROUND(so.total_order_amt::numeric, 2) AS total_order_amt,
    ROUND(po.total_paid_amt::numeric, 2) AS total_paid_amt,
    ROUND((po.total_paid_amt - so.total_order_amt)::numeric, 2) AS difference
FROM gold.dim_orders AS d_o
JOIN sales_per_order AS so
	ON so.order_id = d_o.order_id
JOIN payments_per_order AS po
	ON po.order_id = d_o.order_id
ORDER BY (po.total_paid_amt - so.total_order_amt) DESC  
LIMIT 10;
