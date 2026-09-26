--==================================================================================================================================--
--PROJECT:D2C E-commerce Profitability & Logistics Analytics
--TOOL:MYSQL 8.0
--DATASET:E-Commerce orders & Supply chain Dataset
--AUTHOR:Shourya Pratap Singh
--==================================================================================================================================--

--------------------------------------------------------------------------------------------------------------------------------------
--1. DATABASE & SCHEMA SETUP
-- -----------------------------------------------------------------------------------------------------------------------------------
create database ecommerce_project;
use ecommerce_project;
use ecommerce_project;


CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_timestamp VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50),
    delivery_days varchar(50),
    delay_days varchar(50),
    delivery_status varchar(50)
);

CREATE TABLE orderitems (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    price DECIMAL(10,2),
    shipping_charges DECIMAL(10,2)
);

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


 LOAD DATA LOCAL INFILE "C:/Users/user/Documents/Ecommerce Order Dataset/Cleaned Data/df_Customers.csv"
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from customers;

LOAD DATA LOCAL INFILE "C:/Users/user/Documents/Ecommerce Order Dataset/Cleaned Data/df_OrderItems.csv"
INTO TABLE orderitems
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILe"c:/Users/user/Documents/Ecommerce Order dataset/Cleaned Data/df_Orders.csv"
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILe "c:/Users/user/Documents/Ecommerce Order dataset/Cleaned Data/df_payments.csv"
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILe  "c:/Users/user/Documents/Ecommerce Order dataset/Cleaned Data/df_products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--=======================================================================================================================================================--

--Q1.Total revenue
select
 sum(price) as total_revenue 
 from orderitems;     

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q2.Total Orders
select 
distinct count(order_id) as total_orders 
from orderitems;                                   

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q3.Total customers
select 
distinct count(customer_id) as Total_customer
 from customers;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q4.Total Shipping Costs
select 
sum(shipping_charges) as total_shipping_costs 
from orderitems;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q5.Average Order Value
SELECT 
    ROUND(
        SUM(price) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM orderitems;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q6.Revenue By Product Category
select product_category_name,sum(price) as revenue
from products as p
join orderitems as o
on p.product_id=o.product_id
group by product_category_name 
order by revenue desc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q7.Revenue by state
select c.customer_state,sum(oo.price) as revenue
from customers as c
join orders as o 
on (c.customer_id)=(o.customer_id)
join orderitems as oo
on (o.order_id)=(oo.order_id)
group by c.customer_state;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q8.Top 10 product by revenue 
select product_id,sum(price) as revenue
from orderitems
group by product_id
order by revenue desc
limit 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q9.Monthly revenue trends
SELECT
order_purchase_timestamp,
STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i') AS converted_date
FROM orders
LIMIT 5;

SELECT
YEAR(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS year,
MONTH(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS month,
ROUND(SUM(oi.price),2) AS revenue
FROM orders o
JOIN orderitems oi
ON o.order_id = oi.order_id
GROUP BY
YEAR(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')),
MONTH(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i'))
ORDER BY year, month;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q.10.Order by status
select order_status,count(*) as total_order
from orders as o 
group by order_status 
order by total_order desc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q11.Top five states by number of orders
select customer_state,count(distinct o.order_id) as total_orders
from customers as c
join orders as o
on c.customer_id=o.customer_id
group by customer_state
order by total_orders desc
limit 5;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q12. Average Delivery Days
select round(avg(delivery_days),2) 
from orders;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q13.State-wise Delivery Days
select customer_state,round(avg(delivery_days),2) as avg_day
from customers as c
join orders as o 
on o.customer_id=c.customer_id
group by customer_state
order by avg_day desc;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q14.Delayed Orders %
SELECT ROUND(100 *SUM(
	CASE
	WHEN STR_TO_DATE(order_delivered_timestamp,'%d-%m-%Y %H:%i')
		>
	STR_TO_DATE(order_estimated_delivery_date,'%d-%m-%Y %H:%i')
	THEN 1
    ELSE 0
	END) / COUNT(*),2
) AS delayed_order_percentage
FROM orders
WHERE order_delivered_timestamp IS NOT NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q15.Fastest States
SELECT c.customer_state,ROUND(
	AVG(
		DATEDIFF(
		STR_TO_DATE(o.order_delivered_timestamp,'%d-%m-%Y %H:%i'),
		STR_TO_DATE(o.order_purchase_timestamp,'%d-%m-%Y %H:%i'))),2
    ) AS avg_delivery_days
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_delivered_timestamp IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days ASC
LIMIT 5;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q16.Slowest States
SELECT c.customer_state,
ROUND(AVG(DATEDIFF(
STR_TO_DATE(o.order_delivered_timestamp,'%d-%m-%Y %H:%i'),
STR_TO_DATE(o.order_purchase_timestamp,'%d-%m-%Y %H:%i'))),2
) AS avg_delivery_days
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_delivered_timestamp IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC
LIMIT 5;
---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q17.Highest Revenue Category (CTE)
with cte as 
(select product_category_name, sum(price) as revenue
from products as p
join orderitems as oi 
on p.product_id=oi.product_id
group by product_category_name
),
max_rev as 
(select max(revenue) as highest_revenue
from cte
)
select product_category_name,highest_revenue from cte 
cross join max_rev 
where highest_revenue=revenue;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Q18.Top Product in Each Category
WITH product_revenue AS
(
SELECT
	p.product_category_name,
	oi.product_id,
	SUM(oi.price) AS revenue,
	RANK() OVER(
	PARTITION BY p.product_category_name
	ORDER BY SUM(oi.price) DESC
	) AS rnk
    FROM orderitems oi
    JOIN products p
    ON oi.product_id = p.product_id
    GROUP BY
        p.product_category_name,
        oi.product_id
)
SELECT *
FROM product_revenue
WHERE rnk = 1;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q19.Customers Spending Above Average
with cte as 
(
select customer_id,sum(price) as total_spend
from orders as o
join orderitems as oi 
on o.order_id=oi.order_id
group by customer_id
),
avg_cte as
(
select avg(total_spend) as avg_spend
from cte
)
select customer_id,total_spend,avg_spend 
from cte,avg_cte 
where total_spend>avg_spend;
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Q20.Monthly Revenue Growth
WITH monthly_revenue AS
(
SELECT
YEAR(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS yr,
MONTH(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS mn,
SUM(oi.price) AS revenue
FROM orders o
JOIN orderitems oi
ON o.order_id = oi.order_id
GROUP BY yr,mn
)
SELECT *
FROM monthly_revenue
ORDER BY yr,mn;
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Q21.State Contributing Most Revenue
    SELECT
        c.customer_state,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    JOIN orderitems oi
    ON o.order_id = oi.order_id
    GROUP BY c.customer_state
	ORDER BY revenue DESC
	LIMIT 1;
 --------------------------------------------------------------------------------------------------------------------------------------------------   
--Q22.Rank Products by Revenue
select 
product_id,sum(price) as revenue ,
rank() over(order by sum(price) desc) as rank_
from orderitems as oi 
group by product_id;
--------------------------------------------------------------------------------------------------------------------------------------------------------
--Q23.Running Revenue
WITH monthly_revenue AS
(
SELECT
	YEAR(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS yr,
	MONTH(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS mn,
	SUM(oi.price) AS revenue
    FROM orders o
    JOIN orderitems oi
    ON o.order_id = oi.order_id
    GROUP BY yr,mn
)
SELECT *,
SUM(revenue) OVER(
	ORDER BY yr,mn
	) AS running_revenue
FROM monthly_revenue;
-------------------------------------------------------------------------------------------------------------------------------------------------------
--Q24.Top 5 Customers per State
WITH customer_revenue AS
(
    SELECT
	c.customer_state,
	o.customer_id,
	SUM(oi.price) AS revenue,
	ROW_NUMBER() OVER(
		PARTITION BY c.customer_state
		ORDER BY SUM(oi.price) DESC
        ) AS rn
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    JOIN orderitems oi
    ON o.order_id = oi.order_id
    GROUP BY c.customer_state,o.customer_id
)
SELECT *
FROM customer_revenue
WHERE rn <= 5;
--------------------------------------------------------------------------------------------------------------------------------------------------------

--Q25.Monthly Growth %
WITH monthly_revenue AS
(
SELECT
YEAR(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS yr,
MONTH(STR_TO_DATE(order_purchase_timestamp,'%d-%m-%Y %H:%i')) AS mn,
SUM(oi.price) AS revenue
FROM orders o
JOIN orderitems oi
ON o.order_id = oi.order_id
GROUP BY yr,mn
)
SELECT*,ROUND(100 *(revenue - LAG(revenue) OVER(ORDER BY yr,mn))
     /
LAG(revenue) OVER(ORDER BY yr,mn),2
    ) AS growth_percent
FROM monthly_revenue;
==================================================================================================================================================================