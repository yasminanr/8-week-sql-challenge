--- CASE STUDY 2: Pizza Runner ---
---------- Data Cleaning ---------
----------------------------------

-- customer_orders
SELECT @@GLOBAL.sql_mode global, @@SESSION.sql_mode session;
SET sql_mode = '';
SET GLOBAL sql_mode = '';

DROP TEMPORARY TABLE IF EXISTS customer_orders_temp;

CREATE TEMPORARY TABLE customer_orders_temp AS 
SELECT 
	order_id, 
    customer_id, 
    pizza_id, 
	CASE WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
		ELSE exclusions
		END AS exclusions,
	CASE WHEN extras IS NULL OR extras LIKE 'null' THEN ''
		ELSE extras
		END AS extras,
	order_time
FROM customer_orders;

-- runner_orders
DROP TEMPORARY TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT 
	order_id, 
	runner_id,  
	CASE
		WHEN pickup_time IS NULL OR pickup_time LIKE 'null' THEN ''
		ELSE pickup_time
		END AS pickup_time,
	CASE
		WHEN distance IS NULL OR distance LIKE 'null' THEN ''
		WHEN distance LIKE '%km' THEN TRIM('km' from distance)
		ELSE distance 
		END AS distance,
	CASE
		WHEN duration IS NULL OR duration LIKE 'null' THEN ''
		WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
		WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
		ELSE duration
		END AS duration,
	CASE
		WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN ''
		ELSE cancellation
		END AS cancellation
FROM runner_orders;

ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration INT;

SELECT *
FROM customer_orders_temp;

SELECT *
FROM runner_orders_temp;
