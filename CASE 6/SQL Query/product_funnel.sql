-------- CASE STUDY 6: Clique Bait -------
--------------- Questions ----------------
--------- PRODUCT FUNNEL ANALYSIS --------
------------------------------------------

-- Using a single SQL query - create a new output table which has the following details:
-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?

CREATE TABLE product_info AS
WITH product_events AS
( 
	SELECT 
		e.visit_id,
        ph.product_id, 
        ph.page_name AS product,
        ph.product_category,
        SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
        SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS add_to_cart
	FROM events e
    JOIN page_hierarchy ph
		USING (page_id)
	WHERE ph.product_id IS NOT NULL
    GROUP BY e.visit_id, ph.product_id
),
purchase_events AS
(
	SELECT
		DISTINCT visit_id
	FROM events
    WHERE event_type = 3
),
combined_events AS
(
	SELECT
		prod.visit_id,
        prod.product_id,
        prod.product,
        prod.product_category,
        prod.page_view,
        prod.add_to_cart,
        CASE WHEN pur.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
	FROM product_events prod
    LEFT JOIN purchase_events pur
		USING (visit_id)
),
combined_all AS
(
	SELECT
		product_id,
		product,
        product_category,
        SUM(page_view) AS views,
        SUM(add_to_cart) AS added_cart,
        SUM(CASE WHEN add_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
        SUM(CASE WHEN add_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchased
	FROM combined_events
    GROUP BY product_id
)

SELECT
	*
FROM combined_all
ORDER BY product_id;
        
-- Additionally, create another table which further aggregates the data for the above points 
-- but this time for each product category instead of individual products.
CREATE TABLE category_info AS
WITH product_events AS
( 
	SELECT 
		e.visit_id,
        ph.product_id, 
        ph.page_name AS product,
        ph.product_category,
        SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
        SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS add_to_cart
	FROM events e
    JOIN page_hierarchy ph
		USING (page_id)
	WHERE ph.product_id IS NOT NULL
    GROUP BY e.visit_id, ph.product_id
),
purchase_events AS
(
	SELECT
		DISTINCT visit_id
	FROM events
    WHERE event_type = 3
),
combined_events AS
(
	SELECT
		prod.visit_id,
        prod.product_id,
        prod.product,
        prod.product_category,
        prod.page_view,
        prod.add_to_cart,
        CASE WHEN pur.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
	FROM product_events prod
    LEFT JOIN purchase_events pur
		USING (visit_id)
),
category AS
( 	
	SELECT
		product_category,
        SUM(page_view) AS views,
        SUM(add_to_cart) AS added_cart,
        SUM(CASE WHEN add_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
        SUM(CASE WHEN add_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchased
	FROM combined_events
    GROUP BY product_category
)

SELECT 
	*
FROM category;

-- Use your 2 new output tables - answer the following questions:
-- Question 1: Which product had the most views, cart adds and purchases?
SELECT 
	product
FROM product_info
ORDER BY views DESC
LIMIT 1;

SELECT 
	product
FROM product_info
ORDER BY added_cart DESC
LIMIT 1;

SELECT 
	product
FROM product_info
ORDER BY purchased DESC
LIMIT 1;

-- Question 2: Which product was most likely to be abandoned?
SELECT 
    product, 
	product_category, 
	ROUND(100 * abandoned/added_cart, 2) AS added_to_abandoned_percentage
FROM product_info
ORDER BY added_to_abandoned_percentage DESC
LIMIT 1;

-- Question 3: Which product had the highest view to purchase percentage?
SELECT 
    product, 
	product_category, 
	ROUND(100 * purchased/views, 2) AS view_to_purchase_percentage
FROM product_info
ORDER BY view_to_purchase_percentage DESC
LIMIT 1;

-- Question 4: What is the average conversion rate from view to cart add?
SELECT 
  ROUND(100 * AVG(added_cart/views), 2) AS avg_view_to_cart_add
FROM product_info;

-- Question 5: What is the average conversion rate from cart add to purchase?
SELECT 
  ROUND(100 * AVG(purchased/added_cart), 2) AS avg_view_to_cart_add
FROM product_info;
