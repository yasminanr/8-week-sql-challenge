----- CASE STUDY 8: Fresh Segemnts -----
----------- Interest Analysis ----------
----------------------------------------

-- Question 1: Which interests have been present in all month_year dates in our dataset?
SELECT
	COUNT(DISTINCT month_year) AS unique_month_year
FROM interest_metrics;

WITH interest_month_year AS
(
	SELECT
		interest_id,
        COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
    WHERE month_year IS NOT NULL
    GROUP BY interest_id
)

SELECT
	COUNT(interest_id)
FROM interest_month_year
WHERE total_months = 14;

SELECT
	interest_id,
	COUNT(DISTINCT month_year) AS total_months
FROM interest_metrics
WHERE month_year IS NOT NULL
GROUP BY interest_id
HAVING total_months = 14;

-- Question 2: Using this same total_months measure - 
-- calculate the cumulative percentage of all records starting at 14 months - 
-- which total_months value passes the 90% cumulative percentage value?
WITH month_year_count AS
(
	SELECT
		interest_id,
        COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
    WHERE month_year IS NOT NULL
    GROUP BY interest_id
),

interest_month_year AS
(
	SELECT
		total_months,
        COUNT(DISTINCT interest_id) AS interest_count
	FROM month_year_count
    GROUP BY total_months
)

SELECT 
	total_months,
    interest_count,
    ROUND(100 * SUM(interest_count) OVER (ORDER BY total_months DESC) / (SUM(interest_count) OVER ()), 2) AS cumulative_percentage
FROM interest_month_year
ORDER BY total_months DESC;
        
-- Question 3: If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - 
-- how many total data points would we be removing?
WITH month_year_count AS
(
	SELECT
		interest_id,
        COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
    WHERE month_year IS NOT NULL
    GROUP BY interest_id
)

SELECT
	COUNT(interest_id)
FROM month_year_count
WHERE total_months < 6;

-- Question 4: Does this decision make sense to remove these data points from a business perspective? 
-- Use an example where there are all 14 months present to a removed interest example for your arguments - 
-- think about what it means to have less months present from a segment perspective.
CREATE TABLE filtered_interest_metrics AS
WITH month_year_count AS
(
	SELECT 
		interest_id,
        COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
    WHERE month_year IS NOT NULL
    GROUP BY interest_id
)

SELECT
    met._month,
    met._year,
    mo.interest_id,
    met.composition,
    met.index_value,
    met.ranking,
    met.percentile_ranking,
    met.month_year
FROM month_year_count mo
JOIN interest_metrics met
	USING (interest_id)
WHERE total_months >= 6;

-- Question 5: After removing these interests - how many unique interests are there for each month?
SELECT 
	_month,
    COUNT(DISTINCT interest_id) AS unique_interest
FROM filtered_interest_metrics
GROUP BY _month;