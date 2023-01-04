# <p align="center" style="margin-top: 0px;">🥑 Customer Journey 🥑

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.


Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

## Solution and Explanation

````sql
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
````


From the results above, all the customers signed up for an initial 7 day free trial, and then choose different plans, except for one customer who churned after the trial period (Customer 11).

Furthermore, I'll look into 4 different customers with unique onboarding journey.

#### Customer 1

Customer 1 started the free trial on August 1 2020 and subsequently subscribed to the basic monthly plan on August 8 2020 after the 7-days trial has ended.

#### Customer 11

Customer 11 started subscribing on November 19 2020, but churned after the free trial period ended.

#### Customer 13

Customer 13 started trial period on December 15 2020, then subscribed to the basic monthly plan on December 22 2020. 3 months later on March 29 2021, customer upgraded to the pro monthly plan.

#### Customer 15

Customer 15 started free trial on March 17 2020, then upgraded to pro monthly plan on March 24 2020 . In the following month on April 29 2020, the customer churned and no longer subscribed to Foodie-Fi.
