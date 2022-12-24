# <p align="center" style="margin-top: 0px;">🍜 Case Study #1 - Danny's Diner 🍜

<img src="https://user-images.githubusercontent.com/70214561/209445477-7db03c12-4e77-492c-b518-e2d4c9275483.png" alt="Image" width="500" height="520">

Read the case study [here](https://8weeksqlchallenge.com/case-study-1/).

Danny seriously loves Japanese food, so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their **visiting patterns**, **how much money they’ve spent** and also **which menu items are their favourite**. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

## Entity Relationship Diagram

![case1erd](https://user-images.githubusercontent.com/70214561/209445503-71e6449f-269a-4780-b384-90e8c3354745.png)

## Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. (BONUS) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. (BONUS) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

***

# Solution and Explanation

### Question 1: What is the total amount each customer spent at the restaurant?

````sql
SELECT 
    s.customer_id, 
    SUM(m.price) AS total_spent
FROM sales s
JOIN menu m 
	USING (product_id)
GROUP BY customer_id;
````

#### Steps:
- Use SUM ```price``` and GROUP BY to find the total amount spent by each customer (```total_spent```).
- JOIN ```sales``` and ```menu``` tables because ```customer_id``` and ```price``` columns are in different tables.

#### Output:
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

### Question 2: How many days has each customer visited the restaurant?

````sql
SELECT 
    customer_id, 
    COUNT(DISTINCT (order_date)) AS visit_count
FROM sales
GROUP BY customer_id;
````

#### Steps:
- Use COUNT and GROUP BY to find the the number of days each customer visits the restaurant
- Use DISTINCT ```order_date``` to find unique days. If we do not use DISTINCT, the dates may be repeated.

#### Output:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

### Question 3: What was the first item from the menu purchased by each customer?

````sql
WITH sales_ordered AS
(
	SELECT 
		s.customer_id, 
		s.order_date, 
		m.product_name,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_menu
	FROM sales s
	JOIN menu m
		USING (product_id)
)

SELECT 
	customer_id, 
	product_name
FROM sales_ordered
WHERE rank_menu = 1
GROUP BY customer_id, product_name;
````

#### Steps:
- Create a common table expression ```sales_ordered```.
- Use windows function with DENSE_RANK to create a new column ```rank_menu``` based on ```order_date```.
- GROUP BY all columns and show only the menus with rank = 1.

#### Output:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | sushi        | 
| A           | curry        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are sushi and curry.
- Customer B's first order is curry.
- Customer C's first order is ramen.

### Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT 
	m.product_name,
	COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m
	USING (product_id)
GROUP BY s.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;
````

#### Steps: 
- Use COUNT ```product_id``` and GROUP BY to find how many times an item was purchased.
- ORDER BY ```purchase_count``` with descending order.
- Use LIMIT to show the most purchased item.

#### Output:
| product_name | purchase_count | 
| ----------- | ----------- |
| ramen      | 8   |

- Ramen is the most purchased item on the menu. It has been purchased 8 times.

### Question 5: Which item was the most popular for each customer?

````sql
WITH popular_menu AS
(
	SELECT 
		s.customer_id, 
		m.product_name, 
		COUNT(s.product_id) AS order_count,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank_fav
	FROM menu m
	JOIN sales s
		USING (product_id)
	GROUP BY s.customer_id, m.product_name
)

SELECT 
	customer_id, 
	product_name, 
	order_count
FROM popular_menu
WHERE rank_fav = 1;
````

#### Steps:
- Create a common table expression ```popular_menu```.
- Use COUNT and GROUP BY to find the how many times an item purchased by each customer.
- Use DENSE_RANK to rank the ```order_count``` for each product by descending order for each customer.
- Show only the menus with rank_fav = 1.

#### Output:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | curry        |  2   |
| B           | sushi        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite menu is ramen.
- Customer B enjoys all items on the menu equally.

### Question 6: Which item was purchased first by the customer after they became a member?

````sql
WITH sales_member AS
(
	SELECT 
		s.customer_id, 
		m.join_date,
		s.order_date,
		s.product_id,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_order_date
	FROM sales s
	JOIN members m
		USING (customer_id)
	WHERE s.order_date >= m.join_date
)

SELECT 
	s.customer_id, 
	s.order_date, 
	m2.product_name 
FROM sales_member s
JOIN menu m2
	USING (product_id)
WHERE rank_order_date = 1;
````

#### Steps: 
- Create a common table expression ```sales_member```.
- Use DENSE_RANK to rank the orders partitioning by ```customer_id``` with ascending ```order_date```.
- Filter ```order_date``` to be on or after ```join_date``` using WHERE clause.
- Filter table by rank = 1 to show 1st item purchased by each customer.

#### Output:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |

- Customer A's first order after becoming a member is curry.
- Customer B's first order after becoming a member is sushi.

### Question 7: Which item was purchased just before the customer became a member?

````sql
WITH sales_prior_member AS
(
	SELECT 
		s.customer_id, 
		m.join_date,
		s.order_date,
		s.product_id,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank_order_date
	FROM sales s
	JOIN members m
		USING (customer_id)
	WHERE s.order_date < m.join_date
)

SELECT 
	s.customer_id, 
	s.order_date, 
	m2.product_name 
FROM sales_prior_member s
JOIN menu m2
	USING (product_id)
WHERE rank_order_date = 1;
````

#### Steps:
- Create a common table expression ```sales_prior_member```.
- Use DENSE_RANK to rank the orders partitioning by ```customer_id``` with descending ```order_date```.
- Filter ```order_date``` to be before ```join_date``` using WHERE clause.
- Filter table by rank = 1 to show last item purchased by each customer just before they became a member.

#### Output:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |

- Customer A’s last orders before becoming a member are sushi and curry.
- Customer B’s last order before becoming a member is sushi.

### Question 8: What is the total items and amount spent for each member before they became a member?

````sql
SELECT 
	s.customer_id,
    COUNT(DISTINCT (s.product_id)) AS unique_menu,
    SUM(m.price) AS total_spent
FROM sales s
JOIN menu m
	USING (product_id)
JOIN members m2
	USING (customer_id)
WHERE s.order_date < m2.join_date
GROUP BY s.customer_id;
````

#### Steps: 
- Use COUNT, SUM and GROUP BY to find the total unique items and total amount spent by each customer.
- JOIN ```sales```, ```menu``` and ```members``` tables because the required columns are in different tables.
- Filter ```order_date``` to be before ```join_date``` using WHERE clause.

#### Output:
| customer_id | unique_menu | total_spent |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 2 |  40       |

- Customer A purchased 2 items for $25.
- Customer B purchased 2 items for $40.

### Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
WITH reward_points AS 
(
	SELECT 
		*, 
        CASE WHEN product_name = 'sushi' THEN price * 20
        ELSE price * 10 END AS points
	FROM menu
)

SELECT 
	s.customer_id,
    SUM(r.points) AS total_points
FROM reward_points r
JOIN sales s
	USING (product_id)
GROUP BY s.customer_id;
````

#### Steps: 
- Each $1 spent = 10 points, but sushi gets 2x points, meaning each $1 spent = 20 points.
- Create a common table expression ```reward_points```.
- Use CASE WHEN to create conditional statements with ```product_name``` as the condition. 
- Sum all points for each customer. 

#### Output:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is 860.
- Total points for Customer B is 940.
- Total points for Customer C is 360.

### Question 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
#### 1. Find member validity date of each customer and get last date of January
#### 2. Use CASE WHEN to allocate points by date and product id
#### 3. SUM price and points

````sql
WITH date_validity AS
(
	SELECT
		*,
        DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date,
        LAST_DAY('2021-01-31') AS last_date
	FROM members
)

SELECT 
	d.customer_id,
    d.join_date,
    d.valid_date,
    d.last_date,
    SUM(
		CASE WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
        WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
        ELSE 10 * m.price END
	) AS points
FROM date_validity d
JOIN sales s
	USING (customer_id)
JOIN menu m
	USING (product_id)
WHERE s.order_date < d.last_date
GROUP BY s.customer_id;
````

#### Steps:
- In ```date_validity```, find out customer’s valid_date (which is 6 days after join_date and inclusive of join_date) and last_day of Jan 2021 (which is ‘2021–01–31’).
- On Day -X to Day 1 (customer becomes member on Day 1 join_date), each $1 spent is 10 points and for sushi, each $1 spent is 20 points.
- On Day 1 join_date to Day 7 valid_date, each $1 spent for all items is 20 points.
- On Day 8 to last_day of Jan 2021, each $1 spent is 10 points and sushi is 2x points.
- Use CASE WHEN to create conditional statements with ```product_name``` as the condition.
- Use the WHERE clause to only get the points customers have at the end of January.

#### Output:
| customer_id | join_date  | valid_date  | last_date  | points |
| ----------- | ---------- |------------ |----------- |--------|
| A           | 2021-01-07 | 2021-01-13  | 2021-01-31 | 1370   |
| B           | 2021-01-09 | 2021-01-15  | 2021-01-31 | 820    |

- Total points for Customer A is 1,370.
- Total points for Customer B is 820.

### BONUS QUESTION
#### Join all the things (create one table with: customer_id, order_date, product_name, price, member (Y/N))

````sql
SELECT 
	s.customer_id,
    s.order_date, 
    m.product_name,
    m.price,
    CASE WHEN s.order_date < m2.join_date THEN 'N'
    WHEN s.order_date >= m2.join_date THEN 'Y'
    ELSE 'N' END AS is_member
FROM sales s
JOIN menu m
	USING (product_id)
LEFT JOIN members m2
	USING (customer_id)
ORDER BY s.customer_id, s.order_date;
````

#### Output:
| customer_id | order_date | product_name | price | is_member |
| ----------- | ---------- | -------------| ----- | --------- |
| A           | 2021-01-01 | sushi        | 10    | N         |
| A           | 2021-01-01 | curry        | 15    | N         |
| A           | 2021-01-07 | curry        | 15    | Y         |
| A           | 2021-01-10 | ramen        | 12    | Y         |
| A           | 2021-01-11 | ramen        | 12    | Y         |
| A           | 2021-01-11 | ramen        | 12    | Y         |
| B           | 2021-01-01 | curry        | 15    | N         |
| B           | 2021-01-02 | curry        | 15    | N         |
| B           | 2021-01-04 | sushi        | 10    | N         |
| B           | 2021-01-11 | sushi        | 10    | Y         |
| B           | 2021-01-16 | ramen        | 12    | Y         |
| B           | 2021-02-01 | ramen        | 12    | Y         |
| C           | 2021-01-01 | ramen        | 12    | N         |
| C           | 2021-01-01 | ramen        | 12    | N         |
| C           | 2021-01-07 | ramen        | 12    | N         |

### BONUS QUESTION
#### Rank all the things (create one table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123))
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

````sql
WITH joined_all AS 
(
	SELECT 
		s.customer_id, 
		s.order_date, 
		m.product_name, 
		m.price,
		CASE WHEN s.order_date < m2.join_date THEN 'N'
	    WHEN s.order_date >= m2.join_date THEN 'Y'
	    ELSE 'N'END AS is_member
FROM sales s
JOIN menu m
	USING (product_id)
LEFT JOIN members AS m2
	USING (customer_id)
)

SELECT 
	*,
	CASE WHEN is_member = 'N' THEN NULL
    ELSE RANK() OVER (PARTITION BY customer_id, is_member ORDER BY order_date) 
		END AS ranking
FROM joined_all;
````

#### Output:
| customer_id | order_date | product_name | price | is_member | ranking | 
| ----------- | ---------- | -------------| ----- | --------- |-------- |
| A           | 2021-01-01 | sushi        | 10    | N         | NULL    |
| A           | 2021-01-01 | curry        | 15    | N         | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y         | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y         | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y         | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y         | 3       |
| B           | 2021-01-01 | curry        | 15    | N         | NULL    |
| B           | 2021-01-02 | curry        | 15    | N         | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N         | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y         | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y         | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y         | 3       |
| C           | 2021-01-01 | ramen        | 12    | N         | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N         | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N         | NULL    |
  
  
