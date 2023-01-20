---- CASE STUDY 7: Balanced Tree Clothing Co ----
------------------ Questions --------------------
------------ HIGH LEVEL SALES ANALYSIS ----------
-------------------------------------------------

-- Question 1: What was the total quantity sold for all products?
SELECT
	SUM(qty) AS total_quantity
FROM sales;

-- Question 2: What is the total generated revenue for all products before discounts?
SELECT
	SUM(qty * price) AS total_revenue
FROM sales;

-- Question 3: What was the total discount amount for all products?
SELECT 	
	SUM(price * (discount / 100) * qty) AS total_discount
FROM sales;

