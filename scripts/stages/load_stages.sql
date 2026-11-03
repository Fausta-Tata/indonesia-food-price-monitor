/*
===============================================================================
Load Script: Load Staging Data
===============================================================================
Script Purpose:
    This script loads cleaned food price data from a CSV file into the
    staging table.

    Process:
    1. Truncates the existing staging table.
    2. Loads cleaned data using BULK INSERT.
    3. Displays the number of rows loaded and loading duration.

Source:
    D:\food-price-project\data\silver\food_prices_cleaned.csv

Target:
    stages.food_prices_cleaned

===============================================================================
*/

DECLARE @start_time DATETIME2 = SYSDATETIME();
DECLARE @rows_loaded BIGINT;

PRINT '================================================';
PRINT 'LOADING STAGING DATA';
PRINT '================================================';

-- Truncate existing data
PRINT '>> TRUNCATING TABLE: stages.food_prices_cleaned';

TRUNCATE TABLE stages.food_prices_cleaned;

-- Load data from CSV
PRINT '>> INSERTING DATA: stages.food_prices_cleaned';

BULK INSERT stages.food_prices_cleaned
FROM 'D:\food-price-project\data\silver\food_prices_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Capture the number of rows loaded
SET @rows_loaded = @@ROWCOUNT;

-- Display loading summary
PRINT '>> ROWS LOADED: ' + CAST(@rows_loaded AS VARCHAR(20));
PRINT '>> LOAD DURATION: ' +
      CAST(DATEDIFF(SECOND, @start_time, SYSDATETIME()) AS VARCHAR(20)) +
      ' seconds';
