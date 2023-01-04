----- CASE STUDY 3: Foodie-Fi ----
----------- Questions ------------
-------- CUSTOMER JOURNEY --------
----------------------------------

-- Based off the 8 sample customers provided in the sample from the subscriptions table, 
-- write a brief description about each customer’s onboarding journey.

SELECT
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
FROM subscriptions s
JOIN plans p 
	USING (plan_id)
WHERE s.customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY s.customer_id, s.start_date;

SELECT
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
FROM subscriptions s
JOIN plans p 
	USING (plan_id)
WHERE s.customer_id = 1;

SELECT
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
FROM subscriptions s
JOIN plans p 
	USING (plan_id)
WHERE s.customer_id = 11;

SELECT
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
FROM subscriptions s
JOIN plans p 
	USING (plan_id)
WHERE s.customer_id = 13;

SELECT
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
FROM subscriptions s
JOIN plans p 
	USING (plan_id)
WHERE s.customer_id = 15;

