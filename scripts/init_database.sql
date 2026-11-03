/*
===============================================================================
Database Setup Script
===============================================================================
Script Purpose:
    This script creates the FoodPrice database and initializes the schemas
    required for the food price data warehouse project.

    It performs the following operations:
    1. Switches to the master database.
    2. Drops the FoodPrice database if it already exists.
    3. Creates a new FoodPrice database.
    4. Creates the required schemas:
       - stages: Stores staged data during the ETL process.
       - gold: Stores business-ready data for analytics and reporting.

WARNING:
    Running this script will permanently delete the existing FoodPrice
    database and all its data before recreating it.

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