/*
===============================================================================
Project: Layoffs Data Cleaning (SQL) & Data Exploratory Data Analysis (EDA)
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




/*
===============================================================================
Objective:
Perform exploratory data analysis on the cleaned layoffs dataset to uncover
trends, patterns, outliers, and business insights related to workforce
reductions across companies, industries, countries, and time periods.

Key Questions:

1. Which companies experienced the largest layoffs?
2. Which industries were most affected?
3. Which countries had the highest number of layoffs?
4. How did layoffs change over time?
5. Which companies completely shut down (100% layoffs)?
6. What are the yearly and monthly layoff trends?

===============================================================================
*/

-- ============================================================================
-- Initial Dataset Inspection
-- Purpose:
-- Review the cleaned dataset before beginning analysis.
-- ============================================================================

SELECT *
FROM world_layoffs.layoffs_staging2;

-- ============================================================================
-- SECTION 1: Identify Maximum Layoffs and Extreme Cases
-- Purpose:
-- Find the largest recorded layoff event and the highest layoff percentage.
-- ============================================================================

SELECT
MAX(total_laid_off) AS highest_layoff_count,
MAX(percentage_laid_off) AS highest_layoff_percentage
FROM world_layoffs.layoffs_staging2;

-- Companies with 100% workforce layoffs
-- These companies laid off their entire workforce.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Analyze layoff percentages to understand the severity
-- of workforce reductions across companies.

SELECT
MAX(percentage_laid_off) AS max_percentage,
MIN(percentage_laid_off) AS min_percentage
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off != '';

-- Display all companies that experienced complete shutdowns.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;

-- Compare fully laid-off companies based on funding raised.
-- This helps identify heavily funded startups that still failed.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;

-- ============================================================================
-- SECTION 2: Company-Level Analysis
-- Purpose:
-- Determine which companies were most affected by layoffs.
-- ============================================================================

-- Largest single layoff events recorded in the dataset.

SELECT
company,
total_laid_off
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the highest cumulative layoffs across all events.

SELECT
company,
SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- ============================================================================
-- SECTION 3: Time Range Analysis
-- Purpose:
-- Determine the date range covered by the dataset.
-- ============================================================================

SELECT
MIN(`date`) AS earliest_date,
MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- ============================================================================
-- SECTION 4: Industry Analysis
-- Purpose:
-- Identify industries that experienced the largest workforce reductions.
-- ============================================================================

SELECT
industry,
SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC
LIMIT 10;

-- ============================================================================
-- SECTION 5: Country Analysis
-- Purpose:
-- Identify countries most impacted by layoffs.
-- ============================================================================

SELECT
country,
SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC
LIMIT 10;

-- ============================================================================
-- SECTION 6: Yearly Layoff Trends
-- Purpose:
-- Analyze how layoffs changed from year to year.
-- ============================================================================

SELECT
YEAR(`date`) AS layoff_year,
SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY layoff_year DESC;

-- ============================================================================
-- SECTION 7: Company Stage Analysis
-- Purpose:
-- Examine which stages of company growth experienced the most layoffs.
-- Examples: Seed, Series A, Series B, Post-IPO, etc.
-- ============================================================================

SELECT
stage,
SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- ============================================================================
-- SECTION 8: Top Companies by Layoffs Each Year
-- Purpose:
-- Identify the top 3 companies with the highest layoffs in each year.
----------------------------------------------------------------------

-- Method:
-- 1. Aggregate layoffs by company and year.
-- 2. Rank companies within each year.
-- 3. Return the top-ranked companies.
-- ============================================================================

WITH Company_Year AS
(
SELECT
company,
YEAR(`date`) AS layoff_year,
SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),

Company_Year_Rank AS
(
SELECT
company,
layoff_year,
total_laid_off,
DENSE_RANK() OVER (
PARTITION BY layoff_year
ORDER BY total_laid_off DESC
) AS ranking
FROM Company_Year
)

SELECT
company,
layoff_year,
total_laid_off,
ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND layoff_year IS NOT NULL
ORDER BY layoff_year ASC, total_laid_off DESC;

-- ============================================================================
-- SECTION 9: Monthly Layoff Trends
-- Purpose:
-- Calculate total layoffs per month.
-- ============================================================================

SELECT
SUBSTRING(`date`, 1, 7) AS month,
SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month
ORDER BY month ASC;

-- ============================================================================
-- SECTION 10: Rolling Monthly Layoff Total
-- Purpose:
-- Track cumulative layoffs over time to observe overall growth trends.
-----------------------------------------------------------------------

-- Window Function:
-- SUM() OVER() is used to calculate a running total.
-- ============================================================================

WITH Date_CTE AS
(
SELECT
SUBSTRING(`date`, 1, 7) AS month,
SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month
)

SELECT
month,
SUM(total_laid_off) OVER (
ORDER BY month ASC
) AS rolling_total_layoffs
FROM Date_CTE
ORDER BY month ASC;
