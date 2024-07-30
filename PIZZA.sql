CREATE DATABASE PIZZAHUT;


SELECT * FROM orders;
SELECT * FROM pizza_types;
SELECT * FROM pizzas;
SELECT * FROM order_details;

--:Basic:
--Retrieve the total number of orders placed.
SELECT COUNT(ORDER_ID) AS TOTAL_ORDERS FROM ORDERS;

--Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity *pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id;

--Identify the highest-priced pizza.
select pizza_types.name,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc;


--Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(order_details.order_details_id) AS ORDER_COUNT
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY ORDER_COUNT DESC;


--List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,
SUM(order_details.quantity) AS QUANTITY
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.NAME
ORDER BY QUANTITY DESC ;

--:Intermediate:

--Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category,
SUM(order_details.quantity) AS QUANTITY
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY QUANTITY DESC;

--Determine the distribution of orders by hour of the day.
SELECT HOUR(ORDER_TIME) , COUNT(ORDER_ID) AS ORDER_COUNT
FROM ORDERS
GROUP BY HOUR (ODER_TIME);

--Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(NAME) FROM pizza_types
GROUP BY category;

--Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(QUANTITY),0) AS AVG_PIZZAS_ORDERED_QUANTITY
FROM

(SELECT orders.date, SUM(order_details.quantity) AS QUANTITY
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS AVG_PIZZAS_ORDERED_QUANTITY;


--Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name,
SUM(order_details.quantity*pizzas.price) AS REVENUE
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY REVENUE DESC;


--:Advanced:

--Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
ROUND(SUM(order_details.quantity*pizzas.price)/ (select round(sum(order_details.quantity *pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id)* 100,2) AS REVENUE
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category 
ORDER BY REVENUE DESC;

--Analyze the cumulative revenue generated over time.
SELECT date,
SUM(REVENUE) OVER (ORDER BY DATE) AS CUM_REVENUE
FROM
(SELECT orders.date,
SUM(order_details.quantity * pizzas.price) AS REVENUE
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN ORDERS
ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
GROUP BY ORDERS.date) AS SALES;


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT NAME, REVENUE FROM 
(SELECT CATEGORY, NAME, REVENUE,
RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RN
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity) * pizzas.price) AS REVENUE
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS A) AS B
WHERE RN<=3;






