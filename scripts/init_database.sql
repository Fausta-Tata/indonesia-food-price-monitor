/*
===============================================================================
Database Setup Script
===============================================================================
Script Purpose:
    This script creates the FoodPrice database and initializes the schemas
    and shared utilities required for the food price data warehouse project.

    It performs the following operations:
    1. Switches to the master database.
    2. Drops the FoodPrice database if it already exists.
    3. Creates a new FoodPrice database.
    4. Creates the required schemas:
       - stages: Stores staged data during the ETL process.
       - gold: Stores business-ready data for analytics and reporting.
    5. Creates the utility function dbo.ToProperCase, used by the Gold
       scripts to turn names like 'KOTA MEDAN' into 'Kota Medan'.

WARNING:
    Running this script will permanently delete the existing FoodPrice
    database and all its data before recreating it. After running it,
    reload the staging table and then run the Gold script.

===============================================================================
*/

USE master;
GO

-- Drop and recreate database
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'FoodPrice'
)
BEGIN
    ALTER DATABASE FoodPrice
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE FoodPrice;
END;
GO

-- Create database
CREATE DATABASE FoodPrice;
GO

-- Switch to FoodPrice database
USE FoodPrice;
GO

-- Create schemas
CREATE SCHEMA stages;
GO

CREATE SCHEMA gold;
GO

-- Utility function: proper case ('KALIMANTAN BARAT' -> 'Kalimantan Barat')
CREATE OR ALTER FUNCTION dbo.ToProperCase (@Teks NVARCHAR(150))
RETURNS NVARCHAR(150)
AS
BEGIN
    IF @Teks IS NULL OR LEN(LTRIM(RTRIM(@Teks))) = 0
        RETURN @Teks;

    DECLARE @Hasil NVARCHAR(150) = LOWER(LTRIM(RTRIM(@Teks)));
    DECLARE @Index INT = CHARINDEX(' ', @Hasil);

    -- Capitalise the first letter of the first word
    SET @Hasil = STUFF(@Hasil, 1, 1, UPPER(SUBSTRING(@Hasil, 1, 1)));

    -- Capitalise the letter after every space
    WHILE @Index > 0
    BEGIN
        SET @Hasil = STUFF(@Hasil, @Index + 1, 1, UPPER(SUBSTRING(@Hasil, @Index + 1, 1)));
        SET @Index = CHARINDEX(' ', @Hasil, @Index + 1);
    END

    RETURN @Hasil;
END;
GO