# <p align="center" style="margin-top: 0px;">🐟 Digital Analysis 🐟

## Solution and Explanation

### Question 1: How many users are there?

````sql
SELECT 
	COUNT(DISTINCT user_id) AS user_count
FROM users;
````

#### Output:
<img width="70" alt="digital1" src="https://user-images.githubusercontent.com/70214561/219731110-477ba695-7ed0-48c3-813d-375f4b1cb75e.png">
	
### Question 2: How many cookies does each user have on average?

````sql
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
````

#### Output:
<img width="71" alt="digital2" src="https://user-images.githubusercontent.com/70214561/219731277-35c9ece8-0d76-4d04-970c-1de86604876b.png">
	
### Question 3: What is the unique number of visits by all users per month?

````sql
SELECT
	MONTH(event_time) AS month_visit,
	COUNT(DISTINCT visit_id) AS visit_count
FROM events
GROUP BY month_visit
ORDER BY month_visit;
````

#### Output:
<img width="131" alt="digital3" src="https://user-images.githubusercontent.com/70214561/219731404-d3c92cee-102a-444d-a8eb-3be21eba445f.png">
	
### Question 4: What is the number of events for each event type?

````sql
SELECT
	e.event_type,
    i.event_name,
	COUNT(DISTINCT e.visit_id) AS event_count
FROM events e
JOIN event_identifier i
	USING (event_type)
GROUP BY e.event_type;
````

#### Output:
<img width="218" alt="digital4" src="https://user-images.githubusercontent.com/70214561/219731532-a4df1abb-4625-41f9-8593-a551c2468c40.png">
	
### Question 5: What is the percentage of visits which have a purchase event?

````sql
SELECT
    ROUND(100 * COUNT(DISTINCT visit_id) /
		(SELECT COUNT(DISTINCT visit_id) FROM events), 2) AS purchase_percentage
FROM events
WHERE event_type = 3;
````

#### Output:
<img width="136" alt="digital5" src="https://user-images.githubusercontent.com/70214561/219731754-a2aa24c5-9817-4cbd-a3bd-19a476c2f27a.png">
	
### Question 6: What is the percentage of visits which view the checkout page but do not have a purchase event?

````sql
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
````

#### Output:
<img width="149" alt="digital6" src="https://user-images.githubusercontent.com/70214561/219731904-d7602ceb-f6ad-4e4a-b7de-8d003fd56003.png">
	
### Question 7: What are the top 3 pages by number of views?

````sql
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
````

#### Output:
<img width="192" alt="digital7" src="https://user-images.githubusercontent.com/70214561/219732045-0e30984a-749d-4d8b-a363-71bb23c4efe4.png">
	
### Question 8: What is the number of views and cart adds for each product category?

````sql
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
````

#### Output:
<img width="192" alt="digital8" src="https://user-images.githubusercontent.com/70214561/219732161-d9ae7b18-0e93-485f-929f-ae1bb1dd61fe.png">
	
### Question 9: What are the top 3 products by purchases?

````sql
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
````

#### Output:
<img width="230" alt="digital9" src="https://user-images.githubusercontent.com/70214561/219732300-a6ed5b66-bdd3-42c9-bc45-5232f6cc330c.png">
