# <p align="center" style="margin-top: 0px;">🥑 Customer Journey 🥑

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

<img width="271" alt="subscriptions table" src="https://user-images.githubusercontent.com/70214561/210473806-6e426939-14dc-4504-b278-3d0c6e366a6f.png">

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

<img width="264" alt="customer jouney" src="https://user-images.githubusercontent.com/70214561/210473871-8c9f4d61-83fc-4cd6-bd47-2acc7e7b79d9.png">

From the results above, all the customers signed up for an initial 7 day free trial, and then choose different plans, except for one customer who churned after the trial period (Customer 11).

Furthermore, I'll look into 4 different customers with unique onboarding journey.

#### Customer 1
<img width="263" alt="cust journey1" src="https://user-images.githubusercontent.com/70214561/210473916-3f36a3d6-3edf-4e28-82a0-7d0725091aa6.png">
Customer 1 started the free trial on August 1 2020 and subsequently subscribed to the basic monthly plan on August 8 2020 after the 7-days trial has ended.

#### Customer 11
<img width="251" alt="cust journey 11" src="https://user-images.githubusercontent.com/70214561/210473954-13cd0ca9-f093-43a0-83ac-4046df6304ba.png">
Customer 11 started subscribing on November 19 2020, but churned after the free trial period ended.

#### Customer 13
<img width="263" alt="cust journey 13" src="https://user-images.githubusercontent.com/70214561/210473970-c19503a1-725e-4394-9311-e50cf407dbff.png">
Customer 13 started trial period on December 15 2020, then subscribed to the basic monthly plan on December 22 2020. 3 months later on March 29 2021, customer upgraded to the pro monthly plan.

#### Customer 15
<img width="255" alt="cust journey 15" src="https://user-images.githubusercontent.com/70214561/210474001-ab2acd04-c240-4443-b42e-1ba7060cf6a1.png">
Customer 15 started free trial on March 17 2020, then upgraded to pro monthly plan on March 24 2020 . In the following month on April 29 2020, the customer churned and no longer subscribed to Foodie-Fi.
