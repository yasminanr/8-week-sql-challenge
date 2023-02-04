----- CASE STUDY 8: Fresh Segments -----
------------ Segment Analysis ----------
----------------------------------------

-- Question 1: Using our filtered dataset by removing the interests with less than 6 months worth of data, 
-- which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
-- Only use the maximum composition value for each interest but you must keep the corresponding month_year
SELECT
	met.interest_id,
    map.interest_name,
    MAX(composition) AS largest_composition,
    month_year
FROM filtered_interest_metrics met
JOIN interest_map map
	ON met.interest_id = map.id
GROUP BY met.interest_id
ORDER BY largest_composition DESC
LIMIT 10;

SELECT
	met.interest_id,
    map.interest_name,
    MAX(composition) AS largest_composition,
    month_year
FROM filtered_interest_metrics met
JOIN interest_map map
	ON met.interest_id = map.id
GROUP BY met.interest_id
ORDER BY largest_composition ASC
LIMIT 10;

-- Question 2: Which 5 interests had the lowest average ranking value?
SELECT 
	met.interest_id,
    map.interest_name,
    AVG(met.ranking) AS avg_ranking
FROM filtered_interest_metrics met
JOIN interest_map map
	ON met.interest_id = map.id
GROUP BY met.interest_id
ORDER BY avg_ranking DESC
LIMIT 5;

-- Question 3: Which 5 interests had the largest standard deviation in their percentile_ranking value?
SELECT
	met.interest_id,
    map.interest_name,
    STDDEV(met.percentile_ranking) AS percentile_std_dev
FROM filtered_interest_metrics met
JOIN interest_map map
	ON met.interest_id = map.id
GROUP BY met.interest_id
ORDER BY percentile_std_dev DESC
LIMIT 5;
    
-- Question 4: For the 5 interests found in the previous question - 
-- what was minimum and maximum percentile_ranking values for each interest 
-- and its corresponding year_month value? Can you describe what is happening for these 5 interests?
WITH stddev_percentile_ranking AS
(
	SELECT
		met.interest_id,
		map.interest_name,
		STDDEV(met.percentile_ranking) AS percentile_std_dev
	FROM filtered_interest_metrics met
	JOIN interest_map map
		ON met.interest_id = map.id
	GROUP BY met.interest_id
	ORDER BY percentile_std_dev DESC
	LIMIT 5
)

SELECT 
	st.interest_id, 
    st.interest_name,
    MAX(met.percentile_ranking) AS max_percentile,
    MIN(met.percentile_ranking) AS min_percentile,
    met.month_year
FROM stddev_percentile_ranking st
JOIN filtered_interest_metrics met
	USING (interest_id)
GROUP BY st.interest_id;

-- Question 5: How would you describe our customers in this segment based off their composition and ranking values? 
-- What sort of products or services should we show to these customers and what should we avoid?
