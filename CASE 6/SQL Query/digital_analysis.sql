---- CASE STUDY 6: Clique Bait ----
----------- Questions -------------
--------- DIGITAL ANALYSIS --------
-----------------------------------

-- Question 1: How many users are there?
SELECT 
	COUNT(DISTINCT user_id) AS user_count
FROM users;

-- Question 2: How many cookies does each user have on average?
WITH user_cookies AS
(
	SELECT 
		user_id,
        COUNT(cookie_id) AS cookie_count
	FROM users
    GROUP BY user_id
)

SELECT 
	ROUND(AVG(cookie_count)) AS avg_cookie
FROM user_cookies;

-- Question 3: What is the unique number of visits by all users per month?
SELECT
	MONTH(event_time) AS month_visit,
	COUNT(DISTINCT visit_id) AS visit_count
FROM events
GROUP BY month_visit
ORDER BY month_visit;

-- Question 4: What is the number of events for each event type?
SELECT
	e.event_type,
    i.event_name,
	COUNT(DISTINCT e.visit_id) AS event_count
FROM events e
JOIN event_identifier i
	USING (event_type)
GROUP BY e.event_type;

-- Question 5: What is the percentage of visits which have a purchase event?
SELECT
    ROUND(100 * COUNT(DISTINCT visit_id) /
		(SELECT COUNT(DISTINCT visit_id) FROM events), 2) AS purchase_percentage
FROM events
WHERE event_type = 3;

-- Question 6: What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH visits_cte AS
(
	SELECT
		visit_id,
        SUM(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS view_checkout,
        SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
	FROM events
    GROUP BY visit_id
)

SELECT
	ROUND(100 * (1 - (SUM(purchase) / SUM(view_checkout))), 2) AS checkout_view_percentage
FROM visits_cte;

-- Question 7: What are the top 3 pages by number of views?
SELECT
	e.page_id,
    p.page_name,
    COUNT(e.visit_id) AS views_count
FROM events e
JOIN page_hierarchy p
	USING (page_id)
WHERE e.event_type = 1
GROUP BY e.page_id
ORDER BY views_count DESC
LIMIT 3;

-- Question 8: What is the number of views and cart adds for each product category?
SELECT 
	p.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS views,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS add_cart
FROM events e
JOIN page_hierarchy p
	USING (page_id)
WHERE p.product_category IS NOT NULL
GROUP BY p.product_category
ORDER BY views DESC;

-- Question 9: What are the top 3 products by purchases?
WITH purchase_cte AS 
(
	SELECT 
		DISTINCT visit_id 
	FROM events 
	WHERE page_id = 13
	GROUP BY visit_id
)

SELECT 
	p.page_name,
    p.product_category,
	COUNT(pc.visit_id) AS purchase
FROM purchase_cte pc
JOIN events e
	USING (visit_id)
JOIN page_hierarchy p
	USING (page_id)
WHERE p.product_category IS NOT NULL
GROUP BY p.page_name
ORDER BY purchase DESC
LIMIT 3;
	


    