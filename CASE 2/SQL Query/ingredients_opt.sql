--- CASE STUDY 2: Pizza Runner ---
----------- Questions ------------
---- INGREDIENT OPTIMISATION -----
----------------------------------

-- Question 1: What are the standard ingredients for each pizza?
CREATE TEMPORARY TABLE pizza_recipes_toppings (
    pizza_id INTEGER, 
    toppings INTEGER
);

INSERT INTO pizza_recipes_toppings VALUES 
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);

SELECT
	n.pizza_name,
    GROUP_CONCAT(t.topping_name SEPARATOR ', ') AS ingredients
FROM pizza_names n
JOIN pizza_recipes_toppings r
	USING (pizza_id)
JOIN pizza_toppings t
	ON r.toppings = t.topping_id
GROUP BY r.pizza_id;
    
-- Question 2: What was the most commonly added extra?
WITH extras_cte AS 
(
	SELECT 
		order_id,
		pizza_id,
		extras AS extras
	FROM customer_orders
	WHERE LENGTH(extras) = 1
	AND extras NOT LIKE '' AND extras NOT LIKE 'null' AND extras IS NOT NULL 

UNION ALL 

	SELECT 
		order_id,
		pizza_id,
		SUBSTRING(extras, 1, 1) AS extras
	FROM customer_orders
	WHERE LENGTH(extras) > 2
    AND extras NOT LIKE '' AND extras NOT LIKE 'null' AND extras IS NOT NULL 

UNION ALL

	SELECT 
		order_id,
		pizza_id,
		SUBSTRING(extras, 4) AS extras
	FROM customer_orders
	WHERE LENGTH(extras) > 2
    AND extras NOT LIKE '' AND extras NOT LIKE 'null' AND extras IS NOT NULL 
)

SELECT 
	t.topping_name,
    COUNT(e.extras) AS extras_count
FROM extras_cte e
JOIN pizza_toppings t
    ON e.extras = t.topping_id
GROUP BY e.extras
;

-- Question 3: What was the most common exclusion?
WITH exclusions_cte AS 
(
	SELECT 
		order_id,
		pizza_id,
		exclusions AS exclusions
	FROM customer_orders
	WHERE LENGTH(exclusions) = 1
	AND exclusions NOT LIKE '' AND exclusions NOT LIKE 'null' AND exclusions IS NOT NULL  

UNION ALL 

	SELECT 
		order_id,
		pizza_id,
		SUBSTR(exclusions, 1, 1)  AS exclusions
	FROM customer_orders
	WHERE LENGTH(exclusions) > 2
    AND exclusions NOT LIKE '' AND exclusions NOT LIKE 'null' AND exclusions IS NOT NULL  

UNION ALL

	SELECT 
		order_id,
		pizza_id,
		SUBSTR(exclusions, 4, 1) AS exclusions
	FROM customer_orders
	WHERE LENGTH(exclusions) > 2
    AND exclusions NOT LIKE '' AND exclusions NOT LIKE 'null' AND exclusions IS NOT NULL  
)

SELECT 
	t.topping_name,
    COUNT(e.exclusions) AS exclusions_count
FROM exclusions_cte e
JOIN pizza_toppings t
    ON e.exclusions = t.topping_id
GROUP BY e.exclusions
;

-- Question 4: Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

DROP TEMPORARY TABLE IF EXISTS order_item;
CREATE TEMPORARY TABLE order_item AS
WITH customer_orders_with_id AS (
	SELECT (@rn := @rn + 1) AS customer_order_id, customer_orders.*
	FROM customer_orders CROSS JOIN
			(SELECT @rn := 0) vars
)
SELECT 
	order_id,
	CONCAT_WS(' - ', 
		GROUP_CONCAT(DISTINCT(pizza_name)), 
		CONCAT("Exclude ",GROUP_CONCAT(DISTINCT(excluded_topping.topping_name) SEPARATOR ', ')),
		CONCAT("Extra ", GROUP_CONCAT(DISTINCT(extra_topping.topping_name) SEPARATOR ', '))
	) AS new_order_items
FROM customer_orders_with_id
LEFT JOIN pizza_toppings excluded_topping ON JSON_CONTAINS(CAST(CONCAT('[', exclusions, ']') AS JSON), CAST(excluded_topping.topping_id AS JSON))
LEFT JOIN pizza_toppings extra_topping ON JSON_CONTAINS(CAST(CONCAT('[', extras, ']') AS JSON), CAST(extra_topping.topping_id AS JSON))
LEFT JOIN pizza_names ON customer_orders_with_id.pizza_id = pizza_names.pizza_id
GROUP BY customer_order_id;

SELECT 
	o.order_id,
    c.customer_id,
    c.pizza_id,
    c.exclusions,
    c.extras,
    c.order_time,
    o.new_order_items
FROM order_item o
JOIN customer_orders_temp c
	USING (order_id);

