---- CASE STUDY 5: Data Mart ----
---------- Questions ------------
-------- DATA EXPLORATION -------
---------------------------------

-- Question 1: What day of the week is used for each week_date value?
SELECT DISTINCT
	DAYNAME(week_date) AS day_name
FROM clean_weekly_sales;

-- Question 2: What range of week numbers are missing from the dataset?
WITH RECURSIVE week_num AS
(
	SELECT
		1 AS week_number
	UNION ALL
    SELECT week_number + 1
    FROM week_num
    WHERE week_number < 52
)

SELECT 
	COUNT(w.week_number) AS week_missing
FROM week_num w
LEFT JOIN clean_weekly_sales s
	USING (week_number)
WHERE s.week_number IS NULL;

-- Question 3: How many total transactions were there for each year in the dataset?
SELECT
	calendar_year,
	SUM(transactions) total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

-- Question 4: What is the total sales for each region for each month?
SELECT 
	region,
    month_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- Question 5: What is the total count of transactions for each platform?
SELECT
	platform,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;

-- Question 6: What is the percentage of sales for Retail vs Shopify for each month?
WITH sales_breakdown AS
( 
	SELECT
		calendar_year,
        month_number,
        platform,
        SUM(sales) AS total_sales
	FROM clean_weekly_sales
    GROUP BY calendar_year, month_number, platform
)

SELECT 
	calendar_year,
    month_number,
    ROUND(100 * SUM(
		CASE WHEN platform = 'Retail' THEN total_sales ELSE NULL END) /
        SUM(total_sales), 2) AS retail_percentage,
	ROUND(100 * SUM(
		CASE WHEN platform = 'Shopify' THEN total_sales ELSE NULL END) /
        SUM(total_sales), 2) AS shopify_percentage
FROM sales_breakdown
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;

-- Question 7: What is the percentage of sales by demographic for each year in the dataset?
WITH sales_breakdown AS
( 
	SELECT
		calendar_year,
        demographic,
        SUM(sales) AS total_sales
	FROM clean_weekly_sales
    GROUP BY calendar_year, demographic
)

SELECT
	calendar_year, 
    ROUND(100 * MAX(
		CASE WHEN demographic = 'Families' THEN total_sales ELSE NULL END) /
        SUM(total_sales), 2) AS families_percentage,
	ROUND(100 * MAX(
		CASE WHEN demographic = 'Couples' THEN total_sales ELSE NULL END) /
        SUM(total_sales), 2) AS couples_percentage,
	ROUND(100 * MAX(
		CASE WHEN demographic = 'unknown' THEN total_sales ELSE NULL END) /
        SUM(total_sales), 2) AS unknown_percentage
FROM sales_breakdown
GROUP BY calendar_year
ORDER BY calendar_year;

-- Question 8: Which age_band and demographic values contribute the most to Retail sales?
SELECT
	age_band,
    demographic,
    SUM(sales) AS total_sales,
    ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER (), 2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY contribution_percentage DESC;

-- Question 9: Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
-- If not - how would you calculate it instead?
SELECT
	calendar_year,
    platform,
    ROUND(AVG(avg_transactions), 2) AS avg_row,
    ROUND(SUM(sales) / SUM(transactions), 2) AS avg_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year;
    