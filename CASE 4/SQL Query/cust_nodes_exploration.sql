------- CASE STUDY 4: Data Bank ------
------------- Questions --------------
----- CUSTOMER NODES EXPLORATION -----
--------------------------------------

-- Question 1: How many unique nodes are there on the Data Bank system?
SELECT
	COUNT(DISTINCT node_id) AS unique_node
FROM customer_nodes;

-- Question 2: What is the number of nodes per region?
SELECT
	r.region_id,
    r.region_name,
	COUNT(n.node_id) AS node_count
FROM customer_nodes n
JOIN regions r
	USING (region_id)
GROUP BY r.region_id
ORDER BY r.region_id;

-- Question 3: How many customers are allocated to each region?
SELECT
	r.region_id,
    r.region_name,
	COUNT(DISTINCT n.customer_id) AS customer_count
FROM customer_nodes n
JOIN regions r
	USING (region_id)
GROUP BY r.region_id
ORDER BY r.region_id;

-- Question 4: How many days on average are customers reallocated to a different node?
SELECT 
	AVG(TIMESTAMPDIFF(DAY, start_date, end_date)) AS avg_reallocated
FROM customer_nodes
WHERE end_date != '9999-12-31';

-- Question 5: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH reallocation_days AS 
(
	SELECT 
		region_id,
		TIMESTAMPDIFF(DAY, start_date, end_date) AS reallocated_time,
		NTILE(100) OVER reallocation_window AS percentile
	FROM customer_nodes
	WHERE end_date != '9999-12-31'
	WINDOW reallocation_window AS (
		PARTITION BY region_id 
		ORDER BY TIMESTAMPDIFF(DAY, start_date, end_date) ASC
	)
)

SELECT 
	region_id, 
	SUM(reallocated_time) / COUNT(*) AS reallocated_time, 
	percentile 
FROM reallocation_days
WHERE percentile IN (50, 80, 95)
GROUP BY percentile, region_id;