----- CASE STUDY 5: Data Mart ----
---------- Data Cleaning ---------
----------------------------------

DROP TABLE IF EXISTS clean_weekly_sales;

CREATE TABLE clean_weekly_sales AS
SELECT
	STR_TO_DATE(week_date, '%d/%m/%Y') AS week_date,
    WEEKOFYEAR(STR_TO_DATE(week_date, '%d/%m/%Y')) AS week_number,
    MONTH(STR_TO_DATE(week_date, '%d/%m/%Y')) AS month_number,
    YEAR(STR_TO_DATE(week_date, '%d/%m/%Y')) AS calendar_year,
    region,
    platform,
    segment,
    CASE WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
		WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
		WHEN RIGHT(segment, 1) in ('3','4') THEN 'Retirees'
		ELSE 'unknown' END AS age_band,
    CASE WHEN LEFT(segment,1) = 'C' THEN 'Couples'
		WHEN LEFT(segment,1) = 'F' THEN 'Families'
		ELSE 'unknown' END AS demographic,
	customer_type,
    transactions,
    sales,
    ROUND(sales/transactions, 2) AS avg_transactions
FROM weekly_sales;
    
