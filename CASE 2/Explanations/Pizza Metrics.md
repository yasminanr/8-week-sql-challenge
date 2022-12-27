# <p align="center" style="margin-top: 0px;">🍕 Pizza Metrics 🍕

## Solution and Explanation

### Question 1: How many pizzas were ordered?

````sql
SELECT 
	COUNT(*) AS pizzas_order_count
FROM customer_orders_temp;
````

#### Steps:
The table ```customer_orders``` contains every pizzas ordered by all customers.
We can simply count all rows to get the total amount of pizzas ordered.

#### Output:
|pizzas_order_count|
|------------------|
|        14        |

- Total of 14 pizzas were ordered.

### Question 2: How many unique customer orders were made?

````sql
SELECT 
    COUNT(DISTINCT(order_id)) AS unique_orders
FROM customer_orders_temp;
````

#### Steps:
A customer can order multiple pizzas at a time, hence one ```order_id``` can appear more than one time in the ```customer_orders``` table, according to how many pizzas were ordered. To get the number of unique orders we use the function COUNT with DISTINCT so the same ```order_id``` will not be repeated.

#### Output:
|unique_orders|
|-------------|
|     10      |

- There are 10 unique customer orders.

### Question 3: How many successful orders were delivered by each runner?

````sql
SELECT
	runner_id, 
    COUNT(order_id) AS successful_orders
FROM runner_orders_temp
WHERE distance != 0
GROUP BY runner_id;
````

#### Steps:
- The information about the orders that each runner gets is in the ```runner_orders``` table.
- We get the number of orders using by counting the ```order_id```, grouping by the ```runner_id```.
- We get only the number of successful orders and eliminating the canceled order by filtering using the WHERE clause.

#### Output:
runner_id | successful_orders
-- | --
1 | 4
2 | 3
3 | 1

- Runner 1 has 4 successful delivered orders.
- Runner 2 has 3 successful delivered orders.
- Runner 3 has 1 successful delivered order.

### Question 4: How many of each type of pizza was delivered?

````sql
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
````

#### Steps:
- The informations about the pizza_id, name, and the number of pizzas ordered are actually available in the ```customer_orders``` and ```pizza_names``` table.
- However, we need to eliminate the canceled orders, and that information is available in the ```runner_orders``` table.
- We count the number of pizzas ordered, grouping by the ```pizza_id```.
- Only get the delivered amount by eliminating the orders where the distance is 0.

#### Output:
pizza_id | pizza_name | amount_delivered
-- | -- | --
1 | Meatlovers | 9
2 | Vegetarian | 3

- There are 9 delivered meatlover pizzas and 3 vegetarian pizzas.

### Question 5: How many Vegetarian and Meatlovers were ordered by each customer?

````sql
SELECT 
	customer_id,
	SUM(CASE WHEN pizza_id = 1 THEN 1
		ELSE 0 END) meatlovers,
	SUM(CASE WHEN pizza_id = 2 THEN 1
		ELSE 0 END) vegetarian
FROM customer_orders_temp
GROUP BY customer_id;
````

#### Output:
customer_id | meatlovers | vegetarian
-- | -- | --
101 | 2 | 1
102 | 2 | 1
103 | 3 | 1
104 | 3 | 0
105 | 0 | 1  

- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 3 Meatlovers pizzas.
- Customer 105 ordered 1 Vegetarian pizza.

### Question 6: What was the maximum number of pizzas delivered in a single order?

````sql
SELECT 
	c.order_id,
    COUNT(pizza_id) AS number_of_pizzas
FROM customer_orders_temp c
JOIN runner_orders r
	USING (order_id)
WHERE distance != 0
GROUP BY c.order_id
ORDER BY number_of_pizzas DESC;
````

#### Output:
order_id | number_of_pizzas 
-- | -- 
4 | 3
3 | 2 
10 | 2
1 | 1
2 | 1
5 | 1
7 | 1
8 | 1

- Maximum number of pizza delivered in a single order is 3 pizzas.

### Question 7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
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
````

#### Output:
customer_id | with_change | no_change
-- | -- | --
101 | 0 | 2
102 | 0 | 3
103 | 3 | 0
104 | 2 | 1
105 | 1 | 0

- Customer 101 and 102 like their pizzas with the original recipe. They ordered pizzas without requesting any change.
- Customer 103 ordered 3 with pizzas change.
- Customer 104 ordered pizzas 2 with change and 1 without change.
- Customer 105 ordered 1 pizza with change.

### Question 8: How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT 
    SUM(CASE WHEN c.exclusions != '' AND c.extras != 0 THEN 1
		ELSE 0
        END) AS both_changes
FROM customer_orders_temp c
JOIN runner_orders_temp r
	USING (order_id)
WHERE r.distance != 0;
````

#### Output:
|both_changes|
|------------|
|      1     |

- Only 1 pizza delivered had both extra and exclusion topping.

### Question 9: What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT 
	HOUR(order_time) AS hour_of_the_day, 
	COUNT(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day;
````

#### Output:
hour_of_the_day | pizza_count
-- | --
11 | 1
13 | 3
18 | 3
19 | 1
21 | 3
23 | 3

- Highest volume of pizza ordered is at 1:00 pm, 6:00 pm and 9:00 pm.
- Lowest volume of pizza ordered is at 11:00 am, 7:00 pm and 11:00 pm.

### Question 10: What was the volume of orders for each day of the week?

````sql
SELECT 
	DAYNAME(order_time) AS day_of_the_week, 
	COUNT(order_id) AS pizza_count
FROM customer_orders_temp
GROUP BY day_of_the_week
ORDER BY day_of_the_week;
````

#### Output:
day_of_the_week | pizza_count
-- | --
Wednesday | 5
Thursday | 3
Friday | 1
Saturday | 5

- There were 5 pizzas ordered on Wednesday and Saturday.
- There were 3 pizzas ordered on Thursday.
- There was 1 pizza ordered on Friday.