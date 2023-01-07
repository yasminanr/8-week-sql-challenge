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
WITH transactions_aggregate AS (
	SELECT
		MONTH(txn_date) AS txn_month,
		customer_id,
		SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
		SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
		SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
	FROM data_bank.customer_transactions
	GROUP BY
		MONTH(txn_date),
		customer_id
)

SELECT 
	txn_month,
	COUNT(customer_id) AS customer_count
FROM transactions_aggregate
WHERE deposit_count > 1 AND (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY txn_month
ORDER BY txn_month;
    