/*
===============================================================================
DDL Script: Create Staging Table
===============================================================================
Script Purpose:
    This script creates the staging table used to store cleaned food price
    data before loading it into the Gold layer.

    The table contains:
    - Geographic information (location and coordinates)
    - Price observation dates
    - Commodity information
    - Food price data and related indicators
    - Data quality flags

Table:
    stages.food_prices_cleaned

WARNING:
    If the table already exists, it will be dropped and recreated.
    All existing data in this table will be lost.

===============================================================================
*/

-- Drop existing staging table if it exists
IF OBJECT_ID('stages.food_prices_cleaned', 'U') IS NOT NULL
    DROP TABLE stages.food_prices_cleaned;
GO

-- Create staging table
CREATE TABLE stages.food_prices_cleaned (
    geo_id             NVARCHAR(50),
    mkt_name           NVARCHAR(150),
    adm1_name          NVARCHAR(100),
    adm2_name          NVARCHAR(100),
    island_region      NVARCHAR(50),
    lat                FLOAT,
    lon                FLOAT,
    price_date         DATE,
    year               INT,
    month              INT,
    commodity          NVARCHAR(50),
    price              FLOAT,
    price_observed     FLOAT,
    is_observed        INT,
    inflation_yoy_pct  FLOAT,
    trust              FLOAT,
    mom_pct             FLOAT,
    is_outlier         INT,
    is_invalid_price   INT
);
GO