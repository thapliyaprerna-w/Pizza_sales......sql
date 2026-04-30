CREATE DATABASE pizzahut;

DROP TABLE pizzas;
CREATE TABLE pizzas (
pizza_id VARCHAR(20) PRIMARY KEY NOT NULL,
pizza_type_id VARCHAR(20) NOT NULL,
size VARCHAR(20) NOT NULL,
price INT NOT NULL)

SELECT COUNT(*) FROM pizzas;  

DROP TABLE pizza_types;
CREATE TABLE pizza_types(
pizza_type_id VARCHAR(20) PRIMARY KEY NOT NULL,
name VARCHAR(20)  NOT NULL,
category VARCHAR(20) NOT NULL,
ingredient VARCHAR(20) NOT NULL )
  
SELECT COUNT(*) FROM pizza_types;

DROP TABLE orders;
CREATE TABLE orders(
order_id INT PRIMARY KEY NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL );

SELECT COUNT(*) FROM orders;

DROP TABLE order_details;
CREATE TABLE order_details(
order_details_id INT PRIMARY KEY NOT NULL,
order_id INT NOT NULL,
pizza_id VARCHAR(20) NOT NULL,
quantity INT NOT NULL );

SELECT COUNT(*) FROM order_details;


--1 Retrieve the total number of orders placed
SELECT 
  COUNT(order_id)
  FROM orders;

-- 2 Calculate the total revenue generated from pizza sales.
SELECT 
ROUND(SUM(quantity * price),2) AS total_revenue
FROM order_details o
LEFT JOIN pizzas p
ON o.pizza_id = p.pizza_id;

--3 Identify the highest-priced pizza.
SELECT 
  MAX(price)
  FROM pizzas;

-- 4Identify the most common pizza size ordered.
SELECT p.size ,
  COUNT( o.quantity) as orders_count
FROM pizzas as p
INNER JOIN order_details as o
ON p.pizza_id=o.pizza_id
GROUP BY p.size
ORDER BY  orders_count DESC;

--5 List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name  , 
  SUM(o.quantity) as Most_ordered_SUM
        FROM pizza_types as pt
JOIN pizzas as p
ON p.pizza_type_id =pt.pizza_type_id
  JOIN order_details as o
ON p.pizza_id = o.pizza_id
  GROUP BY pt.name 
  ORDER BY Most_ordered_SUM DESC
  LIMIT 5
;


-- Intermediate:
--1 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT  category , 
  SUM(o.quantity) AS total_qantity
      FROM order_details AS o
LEFT JOIN  pizzas AS P
ON p.pizza_id = o.pizza_id
LEFT JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
  GROUP BY category ;

--2 Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS hours,
  COUNT(order_id) AS number_of_order
        FROM orders
GROUP BY HOUR(order_time) ;

--3 Join relevant tables to find the category-wise distribution of pizzas.\
SELECT category , 
  COUNT(name)
FROM pizza_types 
GROUP BY category;


--4 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG( order_quantity),0) AS AVG_pizza_order_per_day FROM
(
SELECT o.order_date, SUM(od.quantity) AS order_quantity
FROM orders AS o
LEFT JOIN order_details AS od
ON o.order_id = od.order_id
GROUP BY o.order_date )AS order_quantity;

-- 5 Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name ,
ROUND(SUM(od.quantity * p.price),0) AS revenue
FROM pizza_types AS pt
JOIN pizzas AS p
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od
ON p.pizza_id = od.pizza_id
GROUP BY pt.name 
ORDER BY revenue DESC
LIMIT 3;





-- Advanced:
--1 Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category,
CONCAT(ROUND(SUM(o.quantity * p.price) / (SELECT 
ROUND(SUM(quantity * price),2) AS total_revenue
FROM order_details o
LEFT JOIN pizzas p
ON o.pizza_id = p.pizza_id )* 100,2) ,"%") AS REVENUE
FROM pizzas AS p
JOIN pizza_types AS pt
ON pt.pizza_type_id= p.pizza_type_id
JOIN order_details AS o
ON p.pizza_id = o.pizza_id
GROUP BY pt.category ORDER BY  revenue DESC;


--2 Analyze the cumulative revenue generated over time.
SELECT order_date, REVENUE,
ROUND(SUM(REVENUE) OVER(ORDER BY order_date),0) AS CUM_REVENUE
FROM 
(SELECT o.order_date,
ROUND(SUM(od.quantity * p.price),0) AS REVENUE
FROM pizzas AS p
JOIN order_details AS od
ON od.pizza_id = p.pizza_id
JOIN orders AS o
ON o.order_id = od.order_id
GROUP BY o.order_date) AS SALES;

--3 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, Revenue 
FROM 
(SELECT category , name , Revenue ,
RANK() OVER(PARTITION BY  category ORDER BY Revenue DESC ) AS RNK
FROM
(SELECT pt.category, pt.name ,
SUM(o.quantity * p.price) AS Revenue
FROM pizza_types pt
JOIN pizzas AS p
ON p.pizza_type_id = pt.pizza_type_id 
JOIN order_details AS o
ON o.pizza_id = p.pizza_id
GROUP BY pt.category, pt.name) AS A ) AS B
WHERE RNK >= 3;









