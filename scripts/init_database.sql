/*
======================================================
Creating Datawarehouse Database and Schemas
======================================================

Script's Purpose:
    This script creates a database named 'sales_data_warehouse' after checking its existence.
    Besides that, it sets up three schemas - 'bronze', 'silver', and 'gold' - within the database.

Important note:
    Run each of these queries separately to avoid possible errors.
*/

-- Step 1: run while connected to 'postgres'
DROP DATABASE IF EXISTS sales_data_warehouse WITH (FORCE);

CREATE DATABASE sales_data_warehouse
    WITH
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0;

-- Step 2: reconnect to 'datawarehouse', then run:
DROP SCHEMA IF EXISTS bronze CASCADE;
DROP SCHEMA IF EXISTS silver CASCADE;
DROP SCHEMA IF EXISTS gold CASCADE;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;

COMMENT ON SCHEMA bronze IS 'Raw, unprocessed data ingested as-is from source systems';
COMMENT ON SCHEMA silver IS 'Cleaned, standardized, and conformed data';
COMMENT ON SCHEMA gold IS 'Analytics-ready, aggregated data modeled for consumption';
