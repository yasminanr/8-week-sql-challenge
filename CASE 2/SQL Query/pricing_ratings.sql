--- CASE STUDY 2: Pizza Runner ---
----------- Questions ------------
------- PRICING & RATINGS --------
----------------------------------

-- Question 1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes -
-- how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
	SUM(
		CASE WHEN c.pizza_id = 1 THEN 12
        ELSE 10
        END) AS earning
FROM customer_orders_temp c
JOIN runner_orders_temp r
	USING (order_id)
WHERE r.distance != 0;

-- Question 2: What if there was an additional $1 charge for any pizza extras?
SELECT pizza_earning + extras_earning AS total_earning
FROM
(SELECT 
	SUM(
		CASE WHEN c.pizza_id = 1 THEN 12
        ELSE 10
        END) AS pizza_earning,
	SUM(
		CASE WHEN LENGTH(c.extras) = 1 THEN 1
        WHEN LENGTH(c.extras) > 2 THEN 2
        END) AS extras_earning
FROM customer_orders_temp c
JOIN runner_orders_temp r
	USING (order_id)
WHERE r.distance != 0) AS earnings;

-- Question 5: If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
-- and each runner is paid $0.30 per kilometre traveled - 
-- how much money does Pizza Runner have left over after these deliveries?

SELECT SUM(earning) AS earning_minus_delivery
FROM
(
	SELECT 
		SUM(
			CASE WHEN c.pizza_id = 1 THEN 12
			ELSE 10
			END) AS earning
	FROM customer_orders_temp c
	JOIN runner_orders_temp r
		USING (order_id)
	WHERE r.distance != 0
    
    UNION ALL
    
    SELECT 
		SUM(distance) * -0.3 AS earning
	FROM runner_orders
	WHERE distance != 0
) AS earnings;
