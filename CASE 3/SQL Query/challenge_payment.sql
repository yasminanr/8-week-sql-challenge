------- CASE STUDY 3: Foodie-Fi ------
------------- Questions --------------
---------- CHALLENGE PAYMENT ---------
--------------------------------------

-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer 
-- in the subscriptions table with the following requirements:
-- 1. monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
-- 2. upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- 3. upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- 4. once a customer churns they will no longer make payments

WITH RECURSIVE base_table AS
( 
	SELECT 
		s.customer_id,
		s.plan_id,
		p.plan_name,
		s.start_date,
		s.start_date AS payment_date,
        LEAD(s.start_date, 1) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) next_date,
		p.price AS amount
	FROM subscriptions s
	JOIN plans p 
		USING (plan_id)
	WHERE YEAR(s.start_date) = 2020
		AND plan_id != 0
        
	UNION ALL
    
    SELECT 
		customer_id,
		plan_id,
		plan_name,
		start_date,
		DATE_ADD(payment_date, INTERVAL 1 MONTH) payment_date,
        next_date,
		amount
	FROM base_table
	WHERE ((YEAR(payment_date) = 2020 AND next_date IS NULl) OR DATE_ADD(payment_date, INTERVAL 1 MONTH) < next_date) AND plan_id != 3
)

SELECT 
	customer_id,
    plan_id,
    plan_name,
    payment_date,
    amount,
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM base_table
WHERE payment_date <= '2020-12-31' AND plan_id != 4
ORDER BY customer_id
;

