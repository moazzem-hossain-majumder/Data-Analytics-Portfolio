/*
===============================================================================
Project: Layoffs Data Cleaning (SQL)
Dataset: Layoffs 2022
Source : https://www.kaggle.com/datasets/swaptr/layoffs-2022

Description:
This project demonstrates a complete SQL data-cleaning workflow on a layoffs
dataset. The cleaning process includes:

1. Creating a staging table to preserve raw data
2. Identifying and removing duplicate records
3. Standardizing text and date formats
4. Handling missing and null values
5. Removing unnecessary rows and columns

===============================================================================
*/

-- View raw dataset
SELECT * FROM layoffs;

-- ============================================================================
-- STEP 1: CREATE A STAGING TABLE
-- Purpose:
-- Create a working copy of the dataset so the original/raw table remains
-- unchanged throughout the cleaning process.
-- ============================================================================

DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

-- ============================================================================
-- STEP 2: IDENTIFY AND REMOVE DUPLICATES
-- Purpose:
-- Detect records that appear more than once based on all meaningful columns.
-- ROW_NUMBER() is used to assign a sequence number to duplicate groups.
-- Records with row_num > 1 are considered duplicates.
-- ============================================================================

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, `source`, date_added) AS row_num
FROM layoffs_staging;

-- Display duplicate records

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, `source`, date_added) AS row_num
FROM layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- ============================================================================
-- Create a second staging table to safely remove duplicates
-- ============================================================================

DROP TABLE IF EXISTS layoffs_staging2;

CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    total_laid_off TEXT,
    `date` TEXT,
    percentage_laid_off TEXT,
    industry TEXT,
    `source` TEXT,
    stage TEXT,
    funds_raised TEXT,
    country TEXT,
    date_added TEXT,
    row_num INT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

-- Insert records along with duplicate identification number

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, `source`, date_added) AS row_num
FROM layoffs_staging;

-- Review duplicate records

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Remove duplicate records

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Verify duplicates have been removed

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- ============================================================================
-- STEP 3: STANDARDIZE DATA
-- Purpose:
-- Ensure consistent formatting across all records.
-- Tasks:
-- 1. Remove unwanted spaces
-- 2. Convert date columns to DATE datatype
-- ============================================================================

SELECT *
FROM layoffs_staging2;

-- Remove leading/trailing spaces from company names

SELECT company,
       TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Check distinct industry values

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Check distinct country values

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Convert date string to MySQL DATE format

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Convert date_added string to MySQL DATE format

SELECT date_added,
       STR_TO_DATE(date_added, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date_added DATE;

-- Verify standardized data

SELECT *
FROM layoffs_staging2;

-- ============================================================================
-- STEP 4: HANDLE NULLS AND MISSING VALUES
-- Purpose:
-- Investigate incomplete records and remove rows that contain no useful
-- layoff information.
-- ============================================================================

-- Records with missing layoff counts

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- Records where both layoff count and percentage are missing

SELECT *
FROM layoffs_staging2
WHERE total_laid_off = ''
AND percentage_laid_off = '';

-- Check missing industry values

SELECT *
FROM layoffs_staging2
WHERE industry = '';

-- Investigate specific companies with missing information

SELECT *
FROM layoffs_staging2
WHERE company = 'Appsmith';

SELECT *
FROM layoffs_staging2
WHERE company = 'Eyeo';

-- Remove records that contain no layoff information

DELETE
FROM layoffs_staging2
WHERE total_laid_off = ''
AND percentage_laid_off = '';

SELECT *
FROM layoffs_staging2
WHERE source = '';

-- ============================================================================
-- STEP 5: REMOVE TEMPORARY COLUMNS
-- Purpose:
-- Drop helper columns that were only needed during cleaning.
-- ============================================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final cleaned dataset

SELECT *
FROM layoffs_staging2;