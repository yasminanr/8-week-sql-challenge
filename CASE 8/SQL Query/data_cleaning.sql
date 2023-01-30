--- CASE STUDY 8: Fresh Segments ---
----------- Data Cleaning ----------
------------------------------------

-- Question 1: Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE interest_metrics
ADD COLUMN date_temp DATE;

-- Populate the new column with the converted data
UPDATE interest_metrics
SET date_temp = STR_TO_DATE(CONCAT('01-', month_year), '%d-%m-%Y');

-- Drop the original column
ALTER TABLE interest_metrics
DROP COLUMN month_year;

-- Rename the new column to the original name
ALTER TABLE interest_metrics
CHANGE date_temp month_year DATE;

-- Question 2: What is count of records in the fresh_segments.interest_metrics for each month_year value 
-- sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT 
	month_year, 
    COUNT(*) AS count_of_records
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year IS NULL DESC, month_year ASC;

-- Question 3: What do you think we should do with these null values in the fresh_segments.interest_metrics?
SELECT
	COUNT(*),
    COUNT(_month),
    COUNT(_year),
    COUNT(interest_id),
    COUNT(composition),
    COUNT(index_value),
    COUNT(ranking),
    COUNT(percentile_ranking),
    COUNT(month_year)
FROM interest_metrics;

SELECT 
	ROUND(100 * (SUM(CASE WHEN interest_id IS NULL THEN 1 ELSE 0 END) /
    COUNT(*)), 2) AS null_perc
FROM fresh_segments.interest_metrics;

DELETE FROM interest_metrics
WHERE interest_id IS NULL;

-- Question 4: How many interest_id values exist in the fresh_segments.interest_metrics table 
-- but not in the fresh_segments.interest_map table? What about the other way around?

ALTER TABLE interest_map
MODIFY COLUMN id VARCHAR(5);

SELECT
	COUNT(DISTINCT map.id) AS map_id_count,
    COUNT(DISTINCT met.interest_id) AS interest_id_count,
    SUM(CASE WHEN met.interest_id IS NULL THEN 1 ELSE 0 END) AS not_in_map
FROM interest_map map
LEFT JOIN interest_metrics met
	ON map.id = met.interest_id;
    
SELECT
	COUNT(DISTINCT met.interest_id) AS interest_id_count,
    COUNT(DISTINCT map.id) AS map_id_count,
	SUM(CASE WHEN map.id IS NULL THEN 1 ELSE 0 END) AS not_in_metrics
FROM interest_metrics met
LEFT JOIN interest_map map
	ON map.id = met.interest_id
WHERE map.id IS NOT NULL;
    
-- Question 5: Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT
	COUNT(*)
FROM interest_map;

SELECT
	map.id,
    map.interest_name,
    COUNT(*) AS record_count
FROM interest_map map
JOIN interest_metrics met
	ON map.id = met.interest_id
GROUP BY map.id
ORDER BY record_count DESC;

-- Question 6: What sort of table join should we perform for our analysis and why? 
-- Check your logic by checking the rows where interest_id = 21246 in your joined output 
-- and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
SELECT 
	*
FROM interest_map map
JOIN interest_metrics met
	ON map.id = met.interest_id
WHERE met.interest_id = 21246   
	AND met._month IS NOT NULL;
    
-- Question 7: Are there any records in your joined table where the month_year value is before 
-- the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
SELECT
	COUNT(*)
FROM interest_metrics met
JOIN interest_map map
	ON met.interest_id = map.id
WHERE met.month_year < map.created_at;

SELECT
	*
FROM interest_metrics met
JOIN interest_map map
	ON met.interest_id = map.id
WHERE met.month_year < map.created_at;

-- There are 188 records where the month_year date is before the created_at date.
-- However, it looks like these records are created in the same month as month_year. 
-- At the beginning, we set the date on month_year column to be at the start of the month.