# <p align="center" style="margin-top: 0px;">💰 Customer Nodes Exploration 💰

## Solution and Explanation

### Question 1: How many unique nodes are there on the Data Bank system?

````sql
SELECT
	COUNT(DISTINCT node_id) AS unique_node
FROM customer_nodes;
````

### Steps:
- Use COUNT DISTINCT to calculate the number of unique nodes. 

#### Output:
<img width="82" alt="nodes1" src="https://user-images.githubusercontent.com/70214561/211248677-7a0e3e33-084d-4d09-bc56-a91b5d33de3c.png">

- There are 5 unique nodes on the Data Bank system.

### Question 2: What is the number of nodes per region?

````sql
SELECT
	r.region_id,
    r.region_name,
	COUNT(n.node_id) AS node_count
FROM customer_nodes n
JOIN regions r
	USING (region_id)
GROUP BY r.region_id
ORDER BY r.region_id;
````

#### Steps:
- Join the table ```customer_nodes``` and ```regions```.
- Use the COUNT function to count the number of node ID.
- Group by the region ID.

#### Output:
<img width="205" alt="nodes2" src="https://user-images.githubusercontent.com/70214561/211248764-34802dfd-9b00-41a0-a57f-a8db79150ddf.png">

- All regions has 5 unique nodes.
- Australia has 770 nodes, the largest number of all regions.
- America comes second with 735 nodes.
- Africa has 714 nodes.
- Asia has 665 nodes.
- Europe has 616 nodes, the least number of all.

### Question 3: How many customers are allocated to each region?

````sql
SELECT
	r.region_id,
    r.region_name,
	COUNT(DISTINCT n.customer_id) AS customer_count
FROM customer_nodes n
JOIN regions r
	USING (region_id)
GROUP BY r.region_id
ORDER BY r.region_id;
````

#### Steps:
- Join the table ```customer_nodes``` and ```regions```.
- Use COUNT DISTINCT to count the unique number of customer ID.
- Group by the region ID.

#### Output:
<img width="226" alt="nodes3" src="https://user-images.githubusercontent.com/70214561/211248791-16257a69-e53a-4479-98a8-be20bdc80175.png">
	
- Australia has the most customers: 110.
- America has 105 customers.
- Africa has 102 customers.
- Asia has 95 customers.
- European has 88 customers.

### Question 4: How many days on average are customers reallocated to a different node?

````sql
SELECT 
	AVG(TIMESTAMPDIFF(DAY, start_date, end_date)) AS avg_reallocated
FROM customer_nodes
WHERE end_date != '9999-12-31';
````

#### Steps:
- Use TIMESTAMPDIFF to find the difference between start and end date, measured in days.
- Get the average reallocation time with the AVG function.

#### Output:
<img width="94" alt="nodes4" src="https://user-images.githubusercontent.com/70214561/211248842-0727ec7f-26a0-42dc-b30c-c3571647b437.png">
	
- On average, customers are reallocated to different nodes within 14 days.

### Question 5: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
````sql
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
````

#### Steps:
- Use TIMESTAMPDIFF to find the difference between start and end date, measured in days.
- Use the NTILE() window function to count the percentiles.
- Get the 50th, 80th, and 95th percentiles.

#### Output:
<img width="210" alt="nodes5" src="https://user-images.githubusercontent.com/70214561/211248878-8edaf686-44c5-45bb-8b88-df52650a1f52.png">
