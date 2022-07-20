USE datamart;
SELECT *
FROM weekly_sales
LIMIT 10;

## Data Cleansing
CREATE TABLE clean_weekly_sales
SELECT week_date, week(week_date) AS week_number, month(week_date) AS month_number, year(week_date) AS calender_year,
region, platform, 
CASE
	WHEN segment = 'null' THEN 'Unknown'
    ELSE segment
    END AS segment,
CASE
	WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) IN ('3','4') THEN 'Retiries'
    ELSE 'Unknown'
    END AS age_band,
    CASE
		WHEN LEFT(segment,1) = 'C' THEN 'Couples'
		WHEN LEFT(segment,1) = 'F' THEN 'Famylies'
    ELSE 'Unknown'
    END AS demographic,
    customer_type, transactions, sales, ROUND(sales/transactions,2) AS 'avg_transaction'
    FROM weekly_sales;
    
    SELECT *
    FROM clean_weekly_sales
    LIMIT 10;
    
## Data Exploration

CREATE TABLE seq100(x int auto_increment primary key)
INSERT INTO seq100 VALUES (),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 VALUES (),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 VALUES (),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 VALUES (),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 VALUES (),(),(),(),(),(),(),(),(),();
SELECT *
FROM seq100; # First 50 values
# Next 50 values
INSERT INTO seq100 
SELECT x + 50
FROM seq100;

CREATE TABLE seq52 AS (SELECT X FROM seq100 LIMIT 52);
SELECT *
FROM seq52;

## Week number present in seq52 but not in week_numbers

SELECT DISTINCT x AS week_day FROM seq52
WHERE x NOT IN (SELECT DISTINCT week_number FROM clean_weekly_sales);

## Weekdays present in clean_weekly_sales

SELECT DISTINCT week_number 
FROM clean_weekly_sales;

## Total Transactions

SELECT calender_year, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calender_year;

## Total Sales for each region

SELECT region, month_number, SUM(sales) AS  total_sales
FROM clean_weekly_sales
GROUP BY month_number, region;

## Total count of transaction for each play form

SELECT platform, SUM(transactions) AS total_transaction
FROM clean_weekly_sales
GROUP BY platform;

## % of sales retail and shopify fro each month
## Create a TEMPORARY TABLE to save monthly sales -- called creating CTE (common table expression)

WITH cte_monthly_platform_sales AS 
(SELECT month_number, calender_year, platform, SUM(sales) AS monthly_sales
FROM clean_weekly_sales
GROUP BY month_number, calender_year, platform)

SELECT month_number, calender_year, ROUND(100*MAX(CASE WHEN platform = 'Retail' 
	THEN 'Monthly_sales' ELSE NULL END)/SUM(monthly_sales),2) AS retail_percentage, 
    ROUND(100*MAX(CASE WHEN platform = 'Shopify' 
	THEN 'Monthly_sales' ELSE NULL END)/SUM(monthly_sales),2) AS shopify_percentage
FROM cte_monthly_platform_sales 
GROUP BY month_number, calender_year;

## Percentage of slaes by demographic

SELECT calender_year, demographic, SUM(sales) AS yearly_sales,
round(100*SUM(sales)/SUM(SUM(sales))
OVER (PARTITION BY demographic),2) AS percentage
FROM clean_weekly_sales
GROUP BY calender_year, demographic;

## Age band and dempgraphic that contribute to retail sales

SELECT age_band, demographic, SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE platform ='Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;