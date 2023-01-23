---- CASE STUDY 7: Balanced Tree Clothing Co ----
------------------ Questions --------------------
-------------- TRANSACTION ANALYSIS -------------
-------------------------------------------------

-- Question 1: How many unique transactions were there?
SELECT
	COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales;

-- Question 2: What is the average unique products purchased in each transaction?
WITH products_cte AS
(
	SELECT
		txn_id,
		COUNT(DISTINCT prod_id) AS product_count
	FROM sales
	GROUP BY txn_id
)

SELECT
	ROUND(AVG(product_count)) AS avg_unique_product
FROM products_cte;

-- Question 3: What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH revenue AS
(
	SELECT
		txn_id,
		SUM(qty * price) AS total_revenue,
		NTILE(100) OVER rev AS percentile
	FROM sales
    GROUP BY txn_id
    WINDOW rev AS (
		ORDER BY SUM(qty * price)
	)
)

SELECT 
	percentile,
	AVG(total_revenue) AS avg_revenue
FROM revenue
WHERE percentile IN (25, 50, 75)
GROUP BY percentile;

-- Question 4: What is the average discount value per transaction?
WITH discount_cte AS
(
	SELECT
		txn_id,
		AVG(discount) AS discount_txn
	FROM sales
	GROUP BY txn_id
)

SELECT 
	ROUND(AVG(discount_txn)) AS avg_discount
FROM discount_cte;

SELECT
		ROUND(AVG(DISTINCT discount)) AS avg_discount
	FROM sales;
    
-- Question 5: What is the percentage split of all transactions for members vs non-members?
WITH transactions AS
(
	SELECT
        DISTINCT txn_id,
        is_member
	FROM sales
    GROUP BY txn_id
)

SELECT
	ROUND(100 * COUNT(
		CASE WHEN is_member = 1 THEN txn_id ELSE NULL END) /
        COUNT(txn_id), 2) AS member_percentage,
	ROUND(100 * COUNT(
		CASE WHEN is_member = 0 THEN txn_id ELSE NULL END) /
        COUNT(txn_id), 2) AS non_member_percentage
FROM transactions;

-- Question 6: What is the average revenue for member transactions and non-member transactions?
WITH revenue AS
(
	SELECT
		DISTINCT txn_id,
		is_member,
		SUM(qty * price) AS total_revenue,
		SUM((price * ((100 - discount) / 100)) * qty) AS rev_after_discount
	FROM sales
	GROUP BY txn_id
)

SELECT
	AVG(CASE WHEN is_member = 1 THEN total_revenue ELSE NULL END) AS avg_member_no_discount,
	AVG(CASE WHEN is_member = 1 THEN rev_after_discount ELSE NULL END) AS avg_member_with_discount,
    AVG(CASE WHEN is_member = 0 THEN total_revenue ELSE NULL END) AS avg_non_member_no_discount,
    AVG(CASE WHEN is_member = 0 THEN rev_after_discount ELSE NULL END) AS avg_non_member_with_discount
FROM revenue;
  
