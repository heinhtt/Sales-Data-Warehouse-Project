/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    (and any dependent objects) if they already exist. Run this script to
    re-define the DDL structure of the Bronze Layer's tables.
===============================================================================
*/

DROP TABLE IF EXISTS bronze.order_items CASCADE;
CREATE TABLE bronze.order_items (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

DROP TABLE IF EXISTS bronze.orders CASCADE;
CREATE TABLE bronze.orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

DROP TABLE IF EXISTS bronze.order_payments CASCADE;
CREATE TABLE bronze.order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10,2)
);

DROP TABLE IF EXISTS bronze.products CASCADE;
CREATE TABLE bronze.products (
    product_id VARCHAR(50),
    product_category_name   VARCHAR(50),
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

DROP TABLE IF EXISTS bronze.product_category_name_translation CASCADE;
CREATE TABLE bronze.product_category_name_translation (
    product_category_name VARCHAR(50),
    product_category_name_english VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.customers CASCADE;
CREATE TABLE bronze.customers (
    customer_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(50),
    customer_city VARCHAR(50),
    customer_state VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.sellers CASCADE;
CREATE TABLE bronze.sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(50),
    seller_city VARCHAR(50),
    seller_state VARCHAR(50)
);
