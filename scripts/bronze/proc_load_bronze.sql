/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'Bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Performs the `Full Load` in the form of the COPY command to load data from
      CSV files into the Bronze Layer's tables.
    - Since it's based on the Truncate & Insert principle, it should be executed
      every day in order to insert the newest data into the tables.

Parameters:
    The stored procedure doesn't accept any parameters or return any values.

Usage Example:
    CALL bronze.load_bronze();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$

DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    batch_start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '=========================================';

    -- order_items ------------------------------------------------------
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: bronze.order_items';
    TRUNCATE TABLE bronze.order_items;

    RAISE NOTICE '>> Inserting Data Into: bronze.order_items';
    COPY bronze.order_items
    FROM 'G:\Data_proj\DWH_analytics_proj\Dataset\order_items.csv'
    DELIMITER ','
    CSV HEADER;
    RAISE NOTICE 'Rows inserted: %', (SELECT COUNT(*) FROM bronze.order_items);
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '-----------------------------------------';

    -- orders -------------------------------------------------------------
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: bronze.orders';
    TRUNCATE TABLE bronze.orders;

    RAISE NOTICE '>> Inserting Data Into: bronze.orders';
    COPY bronze.orders
    FROM 'G:\Data_proj\DWH_analytics_proj\Dataset\orders.csv'
    DELIMITER ','
    CSV HEADER;
    RAISE NOTICE 'Rows inserted: %', (SELECT COUNT(*) FROM bronze.orders);
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '-----------------------------------------';

    -- order_payments -------------------------------------------------------
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: bronze.order_payments';
    TRUNCATE TABLE bronze.order_payments;

    RAISE NOTICE '>> Inserting Data Into: bronze.order_payments';
    COPY bronze.order_payments
    FROM 'G:\Data_proj\DWH_analytics_proj\Dataset\order_payments.csv'
    DELIMITER ','
    CSV HEADER;
    RAISE NOTICE 'Rows inserted: %', (SELECT COUNT(*) FROM bronze.order_payments);
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '-----------------------------------------';

    -- products -------------------------------------------------------------
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: bronze.products';
    TRUNCATE TABLE bronze.products;

    RAISE NOTICE '>> Inserting Data Into: bronze.products';
    COPY bronze.products
    FROM 'G:\Data_proj\DWH_analytics_proj\Dataset\products.csv'
    DELIMITER ','
    CSV HEADER;
    RAISE NOTICE 'Rows inserted: %', (SELECT COUNT(*) FROM bronze.products);
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '-----------------------------------------';

    -- product_category_name_translation ------------------------------------
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: bronze.product_category_name_translation';
    TRUNCATE TABLE bronze.product_category_name_translation;

    RAISE NOTICE '>> Inserting Data Into: bronze.product_category_name_translation';
    COPY bronze.product_category_name_translation
    FROM 'G:\Data_proj\DWH_analytics_proj\Dataset\product_category_name_translation.csv'
    DELIMITER ','
    CSV HEADER;
    RAISE NOTICE 'Rows inserted: %', (SELECT COUNT(*) FROM bronze.product_category_name_translation);
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '-----------------------------------------';

    -- customers -------------------------------------------------------------
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: bronze.customers';
    TRUNCATE TABLE bronze.customers;

    RAISE NOTICE '>> Inserting Data Into: bronze.customers';
    COPY bronze.customers
    FROM 'G:\Data_proj\DWH_analytics_proj\Dataset\customers.csv'
    DELIMITER ','
    CSV HEADER;
    RAISE NOTICE 'Rows inserted: %', (SELECT COUNT(*) FROM bronze.customers);
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '-----------------------------------------';

    -- sellers -------------------------------------------------------------
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: bronze.sellers';
    TRUNCATE TABLE bronze.sellers;

    RAISE NOTICE '>> Inserting Data Into: bronze.sellers';
    COPY bronze.sellers
    FROM 'G:\Data_proj\DWH_analytics_proj\Dataset\sellers.csv'
    DELIMITER ','
    CSV HEADER;
    RAISE NOTICE 'Rows inserted: %', (SELECT COUNT(*) FROM bronze.sellers);
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '-----------------------------------------';

    batch_end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'Bronze Layer Loading is Completed';
    RAISE NOTICE 'Total Load Duration: % seconds', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
    RAISE NOTICE '=========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '=========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING BRONZE LAYER LOADING';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'Error State: %', SQLSTATE;
        RAISE NOTICE '=========================================';

END;
$$;
