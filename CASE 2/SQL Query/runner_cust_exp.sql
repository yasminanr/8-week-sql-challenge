--- CASE STUDY 2: Pizza Runner ---
----------- Questions ------------
---- RUNNER & CUST EXPERIENCE ----
----------------------------------

-- Question 1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	WEEK(registration_date) AS registration_week, 
	COUNT(runner_id) AS num_of_runners
FROM runners
GROUP BY registration_week;

-- Question 2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH time_diff AS
(
	SELECT
		r.runner_id,
		c.order_id,
        c.order_time,
        r.pickup_time,
        TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
	FROM customer_orders_temp c
	JOIN runner_orders_temp r
		USING (order_id)
	WHERE r.distance != 0
    GROUP BY c.order_id
)

SELECT
	runner_id,
	AVG(pickup_minutes) AS average_in_minutes
FROM time_diff
WHERE pickup_minutes > 1
GROUP BY runner_id;

-- Question 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizza_prep AS
(
	SELECT
		c.order_id, 
		COUNT(c.order_id) AS pizza_order, 
		c.order_time, 
		r.pickup_time, 
		TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time
	FROM customer_orders_temp c
	JOIN runner_orders_temp r
		USING (order_id)
	WHERE r.distance != 0
	GROUP BY c.order_id
)

SELECT 
	pizza_order, 
	AVG(prep_time) AS avg_prep_minutes
FROM pizza_prep
WHERE prep_time > 1
GROUP BY pizza_order;

-- Question 4: What was the average distance travelled for each customer?
SELECT
	c.customer_id,
    ROUND(AVG(r.distance), 2) AS avg_distance
FROM customer_orders_temp c
JOIN runner_orders_temp r
		USING (order_id)
WHERE r.distance != 0
GROUP BY c.customer_id;

-- Question 5: What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS delivery_time_difference
FROM runner_orders_temp
WHERE duration != 0;

-- Question 6: What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
	r.runner_id, 
	c.order_id, 
	COUNT(c.order_id) AS pizza_count, 
	ROUND((r.distance/r.duration * 60), 2) AS avg_speed
FROM runner_orders_temp r
JOIN customer_orders_temp AS c
	USING (order_id)
WHERE distance != 0
GROUP BY r.runner_id, c.order_id
ORDER BY r.runner_id;

SELECT 
	r.runner_id, 
	COUNT(r.order_id) AS order_count, 
	ROUND(AVG(r.distance/r.duration * 60), 2) AS avg_speed
FROM runner_orders_temp r
WHERE distance != 0
GROUP BY r.runner_id
ORDER BY r.runner_id;

-- Question 7: What is the successful delivery percentage for each runner?
SELECT
	runner_id,
    ROUND(100 * SUM(
		CASE WHEN distance = 0 THEN 0
		ELSE 1 END) / COUNT(*)) AS success_percentage
FROM runner_orders_temp
GROUP BY runner_id;

