---- CASE STUDY 4: Data Bank ----
---------- Questions ------------
----- CUSTOMER TRANSACTIONS -----
---------------------------------

-- Question 1: What is the unique count and total amount for each transaction type?
SELECT
	txn_type,
	COUNT(txn_type) AS unique_count,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

-- Question 2: What is the average total historical deposit counts and amounts for all customers?
WITH transactions AS
( 
	SELECT
		customer_id,
        txn_type,
        COUNT(*) AS txn_count,
        AVG(txn_amount) AS avg_amount
	FROM customer_transactions
    GROUP BY customer_id, txn_type
)

SELECT 
	ROUND(AVG(txn_count)) AS avg_deposit_count,
    ROUND(AVG(avg_amount)) AS avg_deposit_amount
FROM transactions
WHERE txn_type = 'deposit';

-- Question 3: For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
    