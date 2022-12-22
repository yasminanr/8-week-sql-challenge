-- CASE STUDY 1: Danny's Diner --
----------- Questions -----------
---------------------------------

-- Question 1: What is the total amount each customer spent at the restaurant?
SELECT 
    s.customer_id, 
    SUM(m.price) AS total_spent
FROM sales s
JOIN menu m 
	USING (product_id)
GROUP BY customer_id;

-- Question 2: How many days has each customer visited the restaurant?
SELECT 
    customer_id, 
    COUNT(DISTINCT (order_date)) AS visit_count
FROM sales
GROUP BY customer_id;
        
-- Question 3: What was the first item from the menu purchased by each customer?
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

-- Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
	m.product_name,
	COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m
	USING (product_id)
GROUP BY s.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

-- Question 5: Which item was the most popular for each customer?
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

-- Question 6: Which item was purchased first by the customer after they became a member?
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

-- Question 7: Which item was purchased just before the customer became a member?
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

-- Question 8: What is the total items and amount spent for each member before they became a member?
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

-- Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
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

-- Question 10: In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- 1. Find member validity date of each customer and get last date of January
-- 2. Use CASE WHEN to allocate points by date and product id
-- 3. SUM price and points

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

-- BONUS QUESTION
-- Join all the things (create one table with: customer_id, order_date, product_name, price, member (Y/N))

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

-- BONUS QUESTION
-- Rank all the things (create one table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123))

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












