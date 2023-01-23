---- CASE STUDY 7: Balanced Tree Clothing Co ----
------------------ Questions --------------------
---------------- PRODUCT ANALYSIS ---------------
-------------------------------------------------

-- Question 1: What are the top 3 products by total revenue before discount?
SELECT
	s.prod_id,
    p.product_name,
	SUM(s.qty * s.price) AS total_revenue
FROM sales s
JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY s.prod_id
ORDER BY total_revenue DESC
LIMIT 3;

-- Question 2: What is the total quantity, revenue and discount for each segment?
SELECT
	p.segment_name,
    SUM(s.qty) AS total_quantity,
	SUM(s.qty * s.price) AS total_revenue,
    SUM(s.price * (s.discount / 100) * s.qty) AS total_discount
FROM sales s
JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.segment_id;

-- Question 3: What is the top selling product for each segment?
SELECT
	p.product_name,
	p.segment_name,
    SUM(s.qty) AS total_quantity
FROM sales s
JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.product_id
ORDER BY p.segment_name, total_quantity DESC;

-- Question 4: What is the total quantity, revenue and discount for each category?
SELECT
	p.category_name,
    SUM(s.qty) AS total_quantity,
	SUM(s.qty * s.price) AS total_revenue,
    SUM(s.price * (s.discount / 100) * s.qty) AS total_discount
FROM sales s
JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.category_name;

-- Question 5: What is the top selling product for each category?
SELECT
	p.product_name,
	p.category_name,
    SUM(s.qty) AS total_quantity
FROM sales s
JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.product_id
ORDER BY p.category_name, total_quantity DESC;

-- Question 6: What is the percentage split of revenue by product for each segment?
WITH revenue_segment AS
(
	SELECT
		s.prod_id,
        p.style_id,
		p.product_name,
		p.segment_id,
		p.segment_name,
		SUM(s.qty * s.price) AS total_revenue
	FROM sales s
	JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY s.prod_id, p.segment_id
    ORDER BY p.segment_id
)

SELECT 
	segment_name,
    product_name, 
    ROUND(100 * (total_revenue / SUM(total_revenue) OVER (PARTITION BY segment_id)), 2) AS prod_segment_percentage
FROM revenue_segment
ORDER BY segment_id;

-- Question 7: What is the percentage split of revenue by segment for each category?
WITH revenue_category AS
(
	SELECT
		p.segment_id,
		p.segment_name,
        p.category_id,
        p.category_name,
		SUM(s.qty * s.price) AS total_revenue
	FROM sales s
	JOIN product_details p
		ON s.prod_id = p.product_id
	GROUP BY p.segment_id, p.category_id
    ORDER BY p.category_id
)
-- SELECT * FROM revenue_category;

SELECT 
	category_name,
    segment_name, 
    ROUND(100 * (total_revenue / SUM(total_revenue) OVER (PARTITION BY category_id)), 2) AS segment_cat_percentage
FROM revenue_category
ORDER BY category_id;

-- Question 8: What is the percentage split of total revenue by category?
WITH revenue_category AS
(
	SELECT
        p.category_id,
        p.category_name,
		SUM(s.qty * s.price) AS total_revenue
	FROM sales s
	JOIN product_details p
		ON s.prod_id = p.product_id
    GROUP BY p.category_id
    ORDER BY p.category_id
)

SELECT
	ROUND(100 * SUM(
		CASE WHEN category_id = 1 THEN total_revenue ELSE NULL END) /
        SUM(total_revenue), 2) AS women_percentage,
	ROUND(100 * SUM(
		CASE WHEN category_id = 2 THEN total_revenue ELSE NULL END) /
        SUM(total_revenue), 2) AS men_percentage
FROM revenue_category;

-- Question 9: What is the total transaction “penetration” for each product? 
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
WITH product_transactions AS 
(
	SELECT 
		DISTINCT prod_id,
		COUNT(DISTINCT txn_id) AS product_transactions
	FROM sales
	GROUP BY prod_id
),

total_transactions AS 
(
	SELECT
		COUNT(DISTINCT txn_id) AS total_transaction_count
	FROM sales
)

SELECT
	pd.product_id,
	pd.product_name,
	ROUND(100 * pt.product_transactions / tt.total_transaction_count, 2) AS penetration_percentage
FROM product_transactions pt
CROSS JOIN total_transactions tt
INNER JOIN product_details pd
	ON pt.prod_id = pd.product_id
ORDER BY penetration_percentage DESC;

-- Question 10: What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
