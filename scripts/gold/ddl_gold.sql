/*
===============================================================================
DDL Script: Create Gold Layer Tables
===============================================================================
Script Purpose:
    This script creates the Gold Layer tables for the FoodPrice data warehouse.

    The Gold Layer contains business-ready data structured using a Star Schema
    to support analytical queries and reporting.

    Tables Created:
        1. gold.dim_area
           Stores geographic information, including province, city, market,
           and coordinates.

        2. gold.dim_commodity
           Stores commodity information and its category.

        3. gold.dim_date
           Stores date-related attributes for time-based analysis.

        4. gold.fact_price
           Stores food price observations and related indicators, connected
           to the dimension tables.

Data Source:
    stages.food_prices_cleaned

===============================================================================
*/

-- =============================================================================
-- 1. Create Dimension: gold.dim_area
-- =============================================================================

DROP TABLE IF EXISTS gold.dim_area;
GO

-- Identify unique geographic areas
WITH area AS (
    SELECT
        geo_id,
        MAX(island_region) island_region,
        MAX(adm1_name) adm1_name,
        MAX(adm2_name) adm2_name,
        MAX(mkt_name) mkt_name,
        MAX(lat) latitude,
        MAX(lon) longitude
    FROM stages.food_prices_cleaned
    GROUP BY geo_id
)

-- Create area dimension table
SELECT
    ROW_NUMBER() OVER (
        ORDER BY adm1_name, adm2_name, mkt_name
    ) AS area_key,
    geo_id,
    island_region,
    dbo.ToProperCase(adm1_name) province,
    dbo.ToProperCase(adm2_name) city,
    mkt_name market,
    latitude,
    longitude
INTO gold.dim_area
FROM area;
GO


-- =============================================================================
-- 2. Create Dimension: gold.dim_commodity
-- =============================================================================

DROP TABLE IF EXISTS gold.dim_commodity;
GO

-- Define commodity mapping and create commodity dimension
SELECT
    ROW_NUMBER() OVER (
        ORDER BY v.commodity_name
    ) commodity_key,
    v.commodity_code,
    v.commodity_name,
    v.category
INTO gold.dim_commodity
FROM (VALUES
        ('rice',         'Rice',         'Staple'),
        ('oil',          'Cooking oil',  'Staple'),
        ('sugar',        'Sugar',        'Staple'),
        ('eggs',         'Eggs',         'Protein'),
        ('meat_chicken', 'Chicken meat', 'Protein'),
        ('onions',       'Onions',       'Vegetable')
     ) AS v (commodity_code, commodity_name, category)
WHERE v.commodity_code IN (
    SELECT DISTINCT commodity
    FROM stages.food_prices_cleaned
);
GO


-- =============================================================================
-- 3. Create Dimension: gold.dim_date
-- =============================================================================

DROP TABLE IF EXISTS gold.dim_date;
GO

-- Generate date attributes from distinct observation dates
SELECT
    ROW_NUMBER() OVER (
        ORDER BY price_date
    ) date_key,
    price_date full_date,
    YEAR(price_date) year,
    DATEPART(QUARTER, price_date) quarter,
    MONTH(price_date) month,
    DATENAME(MONTH, price_date) month_name,
    FORMAT(price_date, 'yyyy-MM') year_month
INTO gold.dim_date
FROM (
    SELECT DISTINCT price_date
    FROM stages.food_prices_cleaned
) d;
GO


-- =============================================================================
-- 4. Create Fact Table: gold.fact_price
-- =============================================================================

DROP TABLE IF EXISTS gold.fact_price;
GO

-- Combine price observations with their corresponding dimension keys
SELECT
    d.date_key,
    a.area_key,
    c.commodity_key,
    s.price,
    s.price_observed,
    s.is_observed,
    s.inflation_yoy_pct,
    s.trust,
    s.mom_pct,
    s.is_outlier,
    s.is_invalid_price
INTO gold.fact_price
FROM stages.food_prices_cleaned s
JOIN gold.dim_date d
    ON d.full_date = s.price_date
JOIN gold.dim_area a
    ON a.geo_id = s.geo_id
JOIN gold.dim_commodity c
    ON c.commodity_code = s.commodity;
GO


-- =============================================================================
-- 5. Validation: Check Gold Layer Tables
-- =============================================================================

SELECT * FROM gold.dim_area;
SELECT * FROM gold.dim_commodity;
SELECT * FROM gold.dim_date;
SELECT * FROM gold.fact_price;
GO