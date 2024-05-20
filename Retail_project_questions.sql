
-- these sql queries are written for the adhic request file which is attached in the pdf file
-- please refer to questions in the adhoc file 
-- I have also shared here top 10, bottom 10 analysis using sql --
-- Q1 --
SELECT p.product_name, f.base_price
FROM 
fact_events f
INNER JOIN 
dim_products p ON f.product_code = p.product_code
WHERE f.base_price > 500 AND f.promo_type = "BOGOF"
ORDER BY f.base_price DESC;

-- Q2 --
SELECT city, COUNT(store_id) AS no_of_stores
FROM
dim_stores
GROUP BY city
ORDER BY no_of_stores DESC;
-- Q3 --
SELECT c.campaign_name, FORMAT(SUM(f.base_price * f.quantity_sold_before_promo)/1000000,2) AS total_revenue_before_p, 
FORMAT(SUM(f.base_price * f.quantity_sold_after_promo)/1000000,2) AS total_revenue_after_p
FROM 
fact_events f
INNER JOIN
dim_campaigns c ON f.campaign_id = c.campaign_id
GROUP BY campaign_name;

-- Q4 --
SELECT p.category, (SUM(f.quantity_sold_after_promo) - SUM(f.quantity_sold_before_promo))/SUM(f.quantity_sold_before_promo)*100 AS ISU,
RANK() OVER w AS rankorder
FROM 
fact_events f
INNER JOIN
dim_campaigns c ON f.campaign_id = c.campaign_id
INNER JOIN
dim_products p ON f.product_code = p.product_code
GROUP BY p.category
WINDOW w AS (ORDER BY (SUM(f.quantity_sold_after_promo) - SUM(f.quantity_sold_before_promo))/SUM(f.quantity_sold_before_promo)*100 DESC);

-- q5 --
SELECT p.product_name, p.category,  (SUM(f.base_price * f.quantity_sold_after_promo) -  SUM(f.base_price * f.quantity_sold_before_promo))
/SUM(f.base_price * f.quantity_sold_before_promo)*100  AS IR
FROM 
fact_events f
INNER JOIN 
dim_products p ON f.product_code = p.product_code
GROUP BY p.product_name
ORDER BY IR DESC
LIMIT 5;



 -- TOP 10 stores by IR --
SELECT f.store_id, SUM(f.base_price * f.quantity_sold_after_promo) - SUM(f.base_price * f.quantity_sold_before_promo) AS IR
FROM
fact_events f
GROUP BY f.store_id
ORDER BY IR DESC
LIMIT 10;

-- bottom 10 stores by 	ISU --

 SELECT  f.store_id, ROUND(SUM(f.quantity_sold_after_promo- f.quantity_sold_before_promo)/ SUM(f.quantity_sold_before_promo)*100,2) AS ISU
 FROM
 fact_events f
 GROUP BY f.store_id
 ORDER BY ISU ASC
 LIMIT 10;
 -- top 2 promotions by IR --
 SELECT f.promo_type, SUM(f.base_price * f.quantity_sold_after_promo) - SUM(f.base_price * f.quantity_sold_before_promo) AS IR
FROM
fact_events f
GROUP BY f.promo_type
ORDER BY IR DESC
LIMIT 2;


-- bottom 2 by IR --
 SELECT f.promo_type, SUM(f.base_price * f.quantity_sold_after_promo) - SUM(f.base_price * f.quantity_sold_before_promo) AS IR
FROM
fact_events f
GROUP BY f.promo_type
ORDER BY IR ASC
LIMIT 2;

-- top 10 cities based ON IR --
SELECT s.city, 
 SUM(f.base_price * f.quantity_sold_after_promo) - SUM(f.base_price * f.quantity_sold_before_promo)AS IR
FROM 
dim_stores s
INNER JOIN
fact_events f ON s.store_id = f.store_id
GROUP BY s.city
ORDER BY IR DESC
LIMIT 10;

-- performance of stores by city by IR --
SELECT s.city, s.store_id,
 SUM(f.base_price * f.quantity_sold_after_promo) - SUM(f.base_price * f.quantity_sold_before_promo)AS IR
FROM 
dim_stores s
INNER JOIN
fact_events f ON s.store_id = f.store_id
GROUP BY s.store_id
ORDER BY IR DESC;
