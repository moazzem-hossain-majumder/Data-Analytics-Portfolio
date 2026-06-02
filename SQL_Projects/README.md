SQL Data Cleaning & Exploratory Data Analysis (EDA) on Layoffs Dataset
Project Overview
This project demonstrates a complete end-to-end SQL workflow using a real-world layoffs dataset. The project consists of two major phases:
Data Cleaning
Removing duplicate records
Standardizing data formats
Handling missing values
Preparing a clean dataset for analysis
Exploratory Data Analysis (EDA)
Identifying trends and patterns
Analyzing layoffs by company, industry, country, and year
Investigating extreme layoff events
Calculating rolling layoff trends over time
The entire project was completed using MySQL and showcases practical SQL skills commonly used in data analytics and business intelligence roles.

Dataset Information
Dataset: Layoffs 2022
Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022
The dataset contains information about company layoffs, including:
Company Name
Industry
Country
Number of Employees Laid Off
Percentage of Workforce Laid Off
Funding Raised
Company Stage
Layoff Date
Source Information

Project Objectives
Data Cleaning Objectives
Preserve raw data by creating staging tables
Detect and remove duplicate records
Standardize company names and date formats
Investigate missing and null values
Remove records with insufficient information
Produce a reliable dataset for analysis
EDA Objectives
Identify companies with the largest layoffs
Analyze industries most affected by layoffs
Determine which countries experienced the highest layoffs
Discover yearly and monthly layoff trends
Identify companies that laid off 100% of employees
Examine layoffs across different company stages

Tools & Technologies
MySQL
SQL Window Functions
Common Table Expressions (CTEs)
Aggregate Functions
Data Cleaning Techniques
Exploratory Data Analysis (EDA)

SQL Concepts Used
Data Cleaning
CREATE TABLE
INSERT INTO
DELETE
ALTER TABLE
DROP COLUMN
TRIM()
STR_TO_DATE()
Data Analysis
GROUP BY
ORDER BY
Aggregate Functions
SUM()
MAX()
MIN()
Common Table Expressions (CTEs)
Window Functions
ROW_NUMBER()
DENSE_RANK()
SUM() OVER()

Data Cleaning Workflow
Step 1: Create Staging Tables
Created separate staging tables to ensure the original dataset remained unchanged during the cleaning process.
Step 2: Remove Duplicate Records
Used the ROW_NUMBER() window function to identify duplicate rows and removed records where the row number exceeded 1.
Step 3: Standardize Data
Performed data standardization by:
Removing leading and trailing spaces
Converting text dates into MySQL DATE format
Ensuring consistent formatting across records
Step 4: Handle Missing Values
Investigated null and blank values and removed records that contained no meaningful layoff information.
Step 5: Remove Temporary Columns
Dropped helper columns used during cleaning to produce the final cleaned dataset.

Exploratory Data Analysis (EDA)
The following business questions were explored:
1. Largest Layoff Events
Maximum employees laid off in a single event
Companies with the largest workforce reductions
2. Complete Company Shutdowns
Companies with 100% workforce layoffs
Relationship between company funding and shutdowns
3. Company-Level Analysis
Companies with the highest cumulative layoffs
Largest single-day layoff events
4. Industry Analysis
Industries most affected by workforce reductions
Industry-wise layoff rankings
5. Country Analysis
Countries experiencing the highest number of layoffs
6. Yearly Trends
Total layoffs by year
Changes in workforce reductions over time
7. Company Stage Analysis
Layoffs by company growth stage
Comparison between startups and mature organizations
8. Top Companies by Year
Top 3 companies with the highest layoffs in each year using DENSE_RANK()
9. Monthly Trends
Monthly layoff totals
Identification of layoff peaks and declines
10. Rolling Layoff Analysis
Running total of layoffs over time using window functions

Key Skills Demonstrated
SQL Query Writing
Data Cleaning
Data Transformation
Exploratory Data Analysis
Window Functions
Common Table Expressions (CTEs)
Data Quality Assessment
Business-Oriented Data Analysis

Repository Structure
├── layoffs_data_cleaning_eda.sql
├── README.md
└── dataset_source.txt


Sample Analysis Questions Answered
Which company laid off the most employees?
Which industry suffered the largest workforce reduction?
Which country experienced the highest layoffs?
How did layoffs evolve over time?
Which companies completely shut down?
What were the top layoff companies each year?

Learning Outcomes
Through this project, I gained hands-on experience with:
Real-world data cleaning techniques
Working with messy datasets
SQL-based exploratory data analysis
Window functions and ranking techniques
Business insight generation from raw data
Preparing datasets for future reporting and visualization

Author
MD. Moazzem Hossain Majumder
SQL Data Cleaning & Exploratory Data Analysis Project
Created as part of my Data Analytics learning journey.

