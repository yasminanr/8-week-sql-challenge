---- CASE STUDY 5: Data Mart ----
---------- Questions ------------
--------- BEFORE & AFTER --------
---------------------------------

-- Question 1: What is the total sales for the 4 weeks before and after 2020-06-15? 
-- What is the growth or reduction rate in actual values and percentage of sales?
SELECT DISTINCT
	week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';

WITH sales_change AS
( 
	SELECT
		SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN sales END) AS sales_before,
        SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN sales END) AS sales_after
	FROM clean_weekly_sales
    WHERE calendar_year = 2020
)

SELECT
	sales_before,
    sales_after,
    sales_after - sales_before AS actual_difference,
    ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS percentage
FROM sales_change;

-- Question 2: What about the entire 12 weeks before and after?
WITH sales_change AS
( 
	SELECT
		SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN sales END) AS sales_before,
        SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN sales END) AS sales_after
	FROM clean_weekly_sales
    WHERE calendar_year = 2020
)

SELECT
	sales_before,
    sales_after,
    sales_after - sales_before AS actual_difference,
    ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS percentage
FROM sales_change;

-- Question 3: How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- A. How do the sale metrics for 4 weeks before and after compare with the previous years in 2018 and 2019?
WITH sales_change AS
( 
	SELECT
		calendar_year,
		SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN sales END) AS sales_before,
        SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN sales END) AS sales_after
	FROM clean_weekly_sales
    GROUP BY calendar_year
    ORDER BY calendar_year
)

SELECT
	calendar_year,
	sales_before,
    sales_after,
    sales_after - sales_before AS actual_difference,
    ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS percentage
FROM sales_change;

-- B. How do the sale metrics for 12 weeks before and after compare with the previous years in 2018 and 2019?
WITH sales_change AS
( 
	SELECT
		calendar_year,
		SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN sales END) AS sales_before,
        SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN sales END) AS sales_after
	FROM clean_weekly_sales
    GROUP BY calendar_year
    ORDER BY calendar_year
)

SELECT
	calendar_year,
	sales_before,
    sales_after,
    sales_after - sales_before AS actual_difference,
    ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS percentage
FROM sales_change;