--- CASE STUDY 2: Pizza Runner ---
----------- Questions ------------
---------- PIZZA METRICS ---------
----------------------------------

-- Question 1: How many pizzas were ordered?
SELECT 
	COUNT(*) AS pizzas_order_count
FROM customer_orders_temp;

-- Question 2: How many unique customer orders were made?
SELECT 
  COUNT(DISTINCT(order_id)) AS unique_orders
FROM customer_orders_temp;

-- Question 3: How many successful orders were delivered by each runner?
SELECT
	runner_id, 
    COUNT(order_id) AS successful_orders
FROM runner_orders_temp
WHERE distance != 0
GROUP BY runner_id;

-- Question 4: How many of each type of pizza was delivered?
SELECT
	c.pizza_id,
    p.pizza_name,
    COUNT(c.pizza_id) AS amount_delivered
FROM customer_orders_temp c
JOIN runner_orders_temp r
	USING (order_id)
JOIN pizza_names p
	USING (pizza_id)
WHERE r.distance != 0
GROUP BY c.pizza_id;

-- Question 5: How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	customer_id,
	SUM(CASE WHEN pizza_id = 1 THEN 1
		ELSE 0 END) meatlovers,
	SUM(CASE WHEN pizza_id = 2 THEN 1
		ELSE 0 END) vegetarian
FROM customer_orders_temp
GROUP BY customer_id;

-- Question 6: What was the maximum number of pizzas delivered in a single order?
SELECT 
	c.order_id,
    COUNT(pizza_id) AS number_of_pizzas
FROM customer_orders_temp c
JOIN runner_orders r
	USING (order_id)
WHERE distance != 0
GROUP BY c.order_id
ORDER BY number_of_pizzas DESC;

-- Question 7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
	c.customer_id,
    SUM(CASE WHEN c.exclusions != '' OR c.extras != '' THEN 1
		ELSE 0
        END) AS with_change,
	SUM(CASE WHEN c.exclusions = '' AND c.extras = '' THEN 1
		ELSE 0
        END) AS no_change
FROM customer_orders_temp c
JOIN runner_orders_temp r
	USING (order_id)
WHERE r.distance != 0
GROUP BY c.customer_id;
    
-- Question 8: How many pizzas were delivered that had both exclusions and extras?
SELECT 
    SUM(CASE WHEN c.exclusions != '' AND c.extras != 0 THEN 1
		ELSE 0
        END) AS both_changes
FROM customer_orders_temp c
JOIN runner_orders_temp r
	USING (order_id)
WHERE r.distance != 0;

-- Question 9: What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  HOUR(order_time) AS hour_of_the_day, 
  COUNT(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day;

-- Question 10: What was the volume of orders for each day of the week?
SELECT 
  DAYNAME(order_time) AS day_of_the_week, 
  COUNT(order_id) AS pizza_count
FROM customer_orders_temp
GROUP BY day_of_the_week
ORDER BY day_of_the_week;


