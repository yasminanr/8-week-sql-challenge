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
<img width="68" alt="exp1" src="https://user-images.githubusercontent.com/70214561/212103627-eec717aa-dcbe-4f9d-a7b6-3bec3bdd2523.png">
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
<img width="85" alt="exp2" src="https://user-images.githubusercontent.com/70214561/212103740-63c40e32-eb15-41df-9820-de8452776551.png">
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
<img width="181" alt="exp3" src="https://user-images.githubusercontent.com/70214561/212104178-dbfa3c60-7946-4e95-b263-35a15ccf6ca4.png">
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
<img width="210" alt="exp4" src="https://user-images.githubusercontent.com/70214561/212104352-5351acce-e29d-467d-aea1-d5928ed3945d.png">	
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
<img width="151" alt="exp5" src="https://user-images.githubusercontent.com/70214561/212104455-4334a05e-853c-4fe1-b2b5-a96259a367a3.png">	
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
<img width="372" alt="exp6" src="https://user-images.githubusercontent.com/70214561/212104608-1bf4f929-fba8-49e0-bd75-04307d3b0e87.png">
	
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
<img width="417" alt="exp7" src="https://user-images.githubusercontent.com/70214561/212104703-dec44897-fdfa-4520-80e1-ff69725e1932.png">	
- The unknown category has the highest sales percentage overall.
<br>
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
<img width="358" alt="exp8" src="https://user-images.githubusercontent.com/70214561/212104807-9a3277a8-9ad2-47a0-9875-17bc70b98416.png">	
- The unknown age_band and demographic contributes the most to retail sales, followed by retirees.
<br>
- The young adults age_band contributes the least to retail sales.

### Question 9: Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?


