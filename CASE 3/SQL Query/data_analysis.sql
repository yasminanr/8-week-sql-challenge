----- CASE STUDY 3: Foodie-Fi ----
----------- Questions ------------
---------- DATA ANALYSIS ---------
----------------------------------

-- Question 1: How many customers has Foodie-Fi ever had?
SELECT
	COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;

-- Question 2: What is the monthly distribution of trial plan start_date values for our dataset - 
-- use the start of the month as the group by value
SELECT
	MONTH(start_date) AS month_date, 
	MONTHNAME(start_date) AS month_name, 
	COUNT(*) AS trial_subscriptions
FROM subscriptions s
JOIN plans p
	USING (plan_id)
WHERE s.plan_id = 0
GROUP BY month_date
ORDER BY month_date;

-- Question 3: What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name.
SELECT 
	p.plan_id,
	p.plan_name,
	COUNT(*) AS count_of_events
FROM subscriptions s
JOIN plans p
	USING (plan_id)
WHERE s.start_date >= '2021-01-01'
GROUP BY p.plan_id, p.plan_name
ORDER BY p.plan_id;

WITH plans_2021 AS
(
	SELECT 
		s.plan_id, 
		p.plan_name,
		COUNT(s.start_date) AS events_2021
	FROM subscriptions s
	JOIN plans p 
		USING (plan_id)
	WHERE YEAR(s.start_date) > 2020
	GROUP BY s.plan_id, p.plan_name
	),
plans_2020 AS
(
	SELECT 
		s.plan_id, 
		p.plan_name,
		COUNT(s.start_date) events_2020
	FROM subscriptions s
	JOIN plans p 
		USING (plan_id)
	WHERE YEAR(s.start_date) = 2020
	GROUP BY s.plan_id, p.plan_name
)

SELECT 
	a.plan_name,
	a.events_2020,
	b.events_2021
FROM plans_2020 a
LEFT JOIN plans_2021 b 
	USING (plan_id)
ORDER BY a.plan_id;

-- Question 4: What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
	COUNT(DISTINCT s.customer_id) AS churned_count,
    ROUND((COUNT( * ) / ( SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) * 100 , 1) AS churn_percentage
FROM subscriptions s
JOIN plans p
	USING (plan_id)
WHERE s.plan_id = 4;

-- Question 5: How many customers have churned straight after their initial free trial - 
-- what percentage is this rounded to the nearest whole number?
WITH ranking AS
(
	SELECT 
		*, 
		RANK() OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) as plan_rank
	FROM subscriptions
)

SELECT 
	COUNT(DISTINCT r.customer_id) AS total_churn,
	ROUND((COUNT( * ) / ( SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) * 100) AS churn_percentage
FROM ranking r
JOIN plans p 
	USING (plan_id)	
WHERE p.plan_id = 4 and r.plan_rank = 2;

-- Question 6: What is the number and percentage of customer plans after their initial free trial?
WITH next_plan AS
(
	SELECT 
		*, 
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) AS plans_next
		FROM subscriptions
)
	
SELECT 
	p.plan_name,
	n.plans_next,
	COUNT(DISTINCT n.customer_id) AS total,
	ROUND(100 * (COUNT(DISTINCT n.customer_id)) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS percentage
FROM next_plan n
JOIN plans p 
	ON p.plan_id = n.plans_next
WHERE n.plan_id = 0 
	AND n.plans_next IS NOT NULL
GROUP BY n.plans_next;

-- Question 7: What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH next_plan AS
(
	SELECT 
		*, 
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) AS plans_next
	FROM subscriptions
	WHERE start_date <= '2020-12-31'
)

SELECT 
    p.plan_name,
	COUNT(DISTINCT n.customer_id) AS total,
	ROUND(100 * (COUNT(DISTINCT n.customer_id)) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS percentage
FROM next_plan n
JOIN plans p 
	USING (plan_id)
WHERE n.plans_next IS NULL
GROUP BY p.plan_name
ORDER BY p.plan_id;

-- Question 8: How many customers have upgraded to an annual plan in 2020?
SELECT 
	COUNT(DISTINCT customer_id) AS cust_with_annual_plan
FROM subscriptions
WHERE plan_id = 3
	AND YEAR(start_date) = 2020;
    
-- Question 9: How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_plan AS 
(
	SELECT 
		customer_id, 
		start_date AS trial_date
	FROM subscriptions
	WHERE plan_id = 0
),

annual_plan AS
(
	SELECT 
		customer_id, 
		start_date AS annual_date
	FROM subscriptions
	WHERE plan_id = 3
)

SELECT 
	ROUND(AVG(TIMESTAMPDIFF(DAY, t.trial_date, a.annual_date))) AS avg_days_to_annual
FROM trial_plan t
JOIN annual_plan a
	USING (customer_id);
    
-- Question 10: Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial_plan AS 
(
	SELECT 
		customer_id, 
		start_date AS trial_date
	FROM subscriptions
	WHERE plan_id = 0
),

annual_plan AS
(
	SELECT 
		customer_id, 
		start_date AS annual_date
	FROM subscriptions
	WHERE plan_id = 3
),

difference AS
(
	SELECT 
		TIMESTAMPDIFF(DAY, t.trial_date, a.annual_date) AS days
	FROM trial_plan t
	JOIN annual_plan a 
		USING (customer_id) 
		WHERE a.annual_date IS NOT NULL
),
	
bins AS
(
	SELECT 
		*, 
		FLOOR(days/30) AS bins
	FROM difference
)

SELECT
	CONCAT((bins * 30) + 1, ' - ', (bins + 1) * 30, ' days ') AS days,
	COUNT(days) AS total
FROM bins
GROUP BY bins
ORDER BY bins;

-- Question 11: How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH next_plan AS
(
	SELECT 
		*, 
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) AS plans_next
	FROM subscriptions
)

SELECT 
	COUNT(DISTINCT customer_id) AS downgraded
FROM next_plan 
WHERE start_date <= '2020-12-31'
	AND plan_id = 2 
	AND plans_next = 1;

