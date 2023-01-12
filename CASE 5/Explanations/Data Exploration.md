# <p align="center" style="margin-top: 0px;">🛒 Data Exploration 🛒

## Solution and Explanation

### Question 1: What day of the week is used for each week_date value?

````sql
SELECT DISTINCT
	DAYNAME(week_date) AS day_name
FROM clean_weekly_sales;
````

#### Steps:
- Use function DAYNAME() to get the day of the week_date.

#### Output:

- Monday is the day used for each week_date value.

### Question 2: What range of week numbers are missing from the dataset?

````sql
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
````

#### Steps:
- Use recursive CTE to generate week number 1 to 52. (This can be easier in PostgreSQL using the GENERATE_SERIES())
- LEFT JOIN the CTE table with the ```clean_weekly_sales``` table.
- Count the number of week_number missing in the joined table, use the WHERE clause to get the data where week_number is NULL.


#### Output:

- There are 28 week numbers that are not in the dataset

### Question 3: How many total transactions were there for each year in the dataset?

````sql
SELECT
	calendar_year,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
````

#### Steps:
- SELECT calendar_year.
- Use SUM to get the number of total transactions, grouping by the calendar_year.

#### Output:

- The year 2020 has the highest number of total transactions compared to the previous years

### Question 4: What is the total sales for each region for each month?

````sql
SELECT 
	region,
    month_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
````

#### Steps:
- SELECT region and month_number.
- Use SUM to get the total sales.
- Group by the region, then the month_number.

#### Output:

- There are 7 regions and the result came up to 49 rows. 

### Question 5: What is the total count of transactions for each platform?

````sql
SELECT
	platform,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;
````

#### Steps:
- SELECT platform.
- Use SUM to get the number of total transactions, grouping by the platform.

#### Output:

- The retail platform has higher number of transactions than shopify.

### Question 6: What is the percentage of sales for Retail vs Shopify for each month?

````sql
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
````

#### Steps:
- Create CTE containing the sales breakdown for each calendar year, month, and platform.
- Using CASE WHEN, calculate the percentage sales of retail and shopify, grouping by the calendar_year and month_number.

#### Output:


### Question 7: What is the percentage of sales by demographic for each year in the dataset?

````sql
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
````

#### Steps:
- Create CTE containing the sales breakdown for each calendar year and demographic.
- Using CASE WHEN, calculate the percentage sales of the family, couples, and unknown
- Group by the calendar_year.

#### Output:

- The unknown category has the highest sales percentage overall.
- The couples category has the lowest sales percentage.

### Question 8: Which age_band and demographic values contribute the most to Retail sales?

````sql
SELECT
	age_band,
    demographic,
    SUM(sales) AS total_sales,
    ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER (), 2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY contribution_percentage DESC;
````

#### Output:

- The unknown age_band and demographic contributes the most to retail sales, followed by retirees.
- The young adults age_band contributes the least to retail sales.

### Question 9: Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?


