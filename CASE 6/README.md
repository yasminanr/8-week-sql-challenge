# <p align="center" style="margin-top: 0px;">🐟 Case Study #6 - Clique Bait 🐟
<img src="https://user-images.githubusercontent.com/70214561/212825419-983f3906-242d-44a8-8ee3-cb0f35f787c4.png" alt="Image" width="500" height="520">

View the case study [here](https://8weeksqlchallenge.com/case-study-6/).

Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

## Problem Statement
In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Entity Relationship Diagram
<img width="825" alt="case6erd" src="https://user-images.githubusercontent.com/70214561/212825560-139d055b-baf1-44fc-8937-0ca1a3621605.png">

## Case Study Questions
## Data Cleansing Steps
Using the available datasets - answer the following questions using a single query for each one:
1. How many users are there?
2. How many cookies does each user have on average?
3. What is the unique number of visits by all users per month?
4. What is the number of events for each event type?
5. What is the percentage of visits which have a purchase event?
6. What is the percentage of visits which view the checkout page but do not have a purchase event?
7. What are the top 3 pages by number of views?
8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchases?

## Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:
- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:
1. Which product had the most views, cart adds and purchases?
2. Which product was most likely to be abandoned?
3. Which product had the highest view to purchase percentage?
4. What is the average conversion rate from view to cart add?
5. What is the average conversion rate from cart add to purchase?
