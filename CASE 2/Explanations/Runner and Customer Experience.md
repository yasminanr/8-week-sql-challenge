# <p align="center" style="margin-top: 0px;">🍕 Runner and Customer Experience 🍕

## Solution and Explanation

### Question 1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT 
	WEEK(registration_date) AS registration_week, 
	COUNT(runner_id) AS num_of_runners
FROM runners
GROUP BY registration_week;
````

#### Steps:
- Use the WEEK() function which returns the week number for a given date (a number from 0 to 53).
- I add the second parameter as 5 because the first day of 2021 was Friday, but this is optional. No need to add this parameter if we want to apply this to different years.
- COUNT the ```runner_id``` from the runners table, grouping by the registration week.

#### Output:
registration_week | num_of_runners
-- | --
0 | 2
1 | 1
2 | 1

- In this case, the week starts from zero because the year 2021 begins at the end of a week.
- On Week 1 of 2021, 2 new runners signed up.
- On Week 2 and 3 of 2021, 1 new runner signed up.

### Question 2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
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
	ROUND(AVG(pickup_minutes)) AS average_in_minutes
FROM time_diff
WHERE pickup_minutes > 1
GROUP BY runner_id;
````

#### Steps:
- Creating a CTE, using the TIMESTAMPDIFF function to get the difference between order and pickup time.
- Grouping by the order ID.
- Using WHERE clause to select only the orders that are not canceled (where the distance is not zero).
- Selecting the runner ID and use the AVG function to get the average pickup time for each runner.

#### Output:
runner_id | average_in_minutes
-- | --
1 | 14
2 | 20
3 | 10

- The average time required for runner 1 to take an order is 14 minutes.
- The average time required for runner 2 to take an order is 20 minutes.
- The average time required for runner 3 to take an order is 10 minutes.

### Question 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
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
	ROUND(AVG(prep_time)) AS avg_prep_minutes
FROM pizza_prep
WHERE prep_time > 1
GROUP BY pizza_order;
````

#### Steps:
- Creating a CTE, get the pizza order count for each order ID
- Using the TIMESTAMPDIFF function to get the pizza preparation time.
- Grouping by the order ID.
- Using WHERE clause to select only the orders that are not canceled (where the distance is not zero).
- Selecting the pizza order count and use the AVG function to get the average preparation time for each amount of pizza order count.

#### Output:
pizza_order | avg_prep_minutes
-- | --
1 | 12
2 | 18
3 | 29

- The number of pizzas ordered seems to be correlated to the preparation time.
- The more the number of pizzas ordered, the preparation time takes longer.

### Question 4: What was the average distance travelled for each customer?

````sql
SELECT
	c.customer_id,
    ROUND(AVG(r.distance), 2) AS avg_distance
FROM customer_orders_temp c
JOIN runner_orders_temp r
		USING (order_id)
WHERE r.distance != 0
GROUP BY c.customer_id;
````

#### Output:
customer_id | avg_distance
-- | --
101 | 20.00
102 | 16.73
103 | 23.40
104 | 10.00
105 | 25.00

- Assuming that distance is calculated from Pizza Runner HQ to customer’s place, customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.

### Question 5: What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT MAX(duration) - MIN(duration) AS delivery_time_difference
FROM runner_orders_temp
WHERE duration != 0;
````

#### Output:
| delivery_time_difference |
| -- |
| 30 |

- The difference between the longest and the shortest delivery times for all orders is 30 minutes.

### Question 6: What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
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
````

#### Output:
runner_id | order_id | pizza_count | avg_speed
-- | -- | -- | --
1 | 1 | 1 | 37.50
1 | 2 | 1 | 44.44
1 | 3 | 2 | 40.20
1 | 10 | 2 | 60.00
2 | 4 | 3 | 35.10
2 | 7 | 1 | 60.00
2 | 8 | 1 | 93.60
3 | 5 | 1 | 40.00

- Runner 1’s average speed runs from 37.5km/h to 60km/h.
- Runner 2’s average speed runs from 35.1km/h to 93.6km/h. It should be investigated why Runner 2 has the highest fluctuation in speed.
- Runner 3’s average speed is 40km/h

````sql
SELECT 
	r.runner_id, 
	COUNT(r.order_id) AS order_count, 
	ROUND(AVG(r.distance/r.duration * 60), 2) AS avg_speed
FROM runner_orders_temp r
WHERE distance != 0
GROUP BY r.runner_id
ORDER BY r.runner_id;
````

#### Output:
runner_id | order_count | avg_speed
-- | -- | --
1 | 4 | 45.54
2 | 3 | 62.90
3 | 1 | 40.00

- All in all, Runner 2 has the highest speed average compared to other runners.
- Runner 3 has the lowest speed average.

### Question 7: What is the successful delivery percentage for each runner?

````sql
SELECT
	runner_id,
    ROUND(100 * SUM(
		CASE WHEN distance = 0 THEN 0
		ELSE 1 END) / COUNT(*)) AS successful_percentage
FROM runner_orders_temp
GROUP BY runner_id
ORDER BY successful_percentage DESC;
````

#### Output:
runner_id | successful_percentage
-- | --
1 | 100
2 | 75
3 | 50

- Runner 1 has 100% successful delivery.
- Runner 2 has 75% successful delivery.
- Runner 3 has 50% successful delivery.
- Bear in mind that the unsuccessful deliveries were due to canceled orders.