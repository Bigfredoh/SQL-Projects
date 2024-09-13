                           /* Business Objectives*/

/* Question 1: What is the total revenue generated for each pizza type across all orders?*/

SELECT py.pizza_name,
	ROUND(SUM(od.quantity * ps.pizza_price)::numeric,2) AS Revenue
FROM pizzas ps
JOIN order_details od ON ps.pizza_id = od.pizza_id
JOIN pizza_types py ON ps.pizza_type_id = py.pizza_type_id
GROUP BY py.pizza_name
ORDER BY Revenue DESC

/* Question 2: Which pizza size is ordered the most across all orders?*/
	
SELECT ps.pizza_size, 
	SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas ps ON od.pizza_id = ps.pizza_id
GROUP BY  ps.pizza_size
ORDER BY total_quantity DESC

/* Question 3: What is the average total value of orders placed on each date?*/
	
SELECT round(avg(order_value)::numeric,2) AS AOV, order_totals.date
FROM(
	SELECT od.order_id,o.date,
	SUM(od.quantity * ps.pizza_price) AS order_value
	FROM orders o
	JOIN order_details od ON od.order_id = o.order_id
	JOIN pizzas ps ON od.pizza_id = ps.pizza_id
	GROUP BY o.date, od.order_id) AS order_totals
GROUP BY order_totals.date
ORDER BY AOV DESC

/* Question 4: How many pizzas have been sold for each category 
	(Classic, Chicken, Supreme, Veggie) and their corresponding revenue?*/

SELECT py.category, 
	SUM(od.quantity) AS total_pizza_sold,
	ROUND(SUM(od.quantity * ps.pizza_price)::numeric,2) AS Revenue
FROM order_details od
JOIN pizzas ps ON od.pizza_id = ps.pizza_id
JOIN pizza_types py ON ps.pizza_type_id = py.pizza_type_id
GROUP BY py.category
ORDER BY total_pizza_sold DESC

/* Question 5: Which ingredients are used most frequently in the pizzas ordered?*/

SELECT ingredient, 
	COUNT(*) AS total_pizza_type
FROM(
	SELECT UNNEST(STRING_TO_ARRAY(py.ingredients, ', ')) AS ingredient
	FROM order_details od
	JOIN pizzas ps ON od.pizza_id = ps.pizza_id
	JOIN pizza_types py ON ps.pizza_type_id = py.pizza_type_id) AS ingredients_list 
GROUP BY ingredient
ORDER BY total_pizza_type DESC


/* Question 6: What are the top 5 pizzas sold in the highest quantities across all orders?*/
	
SELECT RankedPizza.pizza_name,  RankedPizza.total_quantity
FROM (
	SELECT py.pizza_name, 
	SUM(od.quantity) AS total_quantity,
	RANK() OVER(ORDER BY SUM(od.quantity) DESC) AS RankedQuantity
	FROM order_details od
	JOIN pizzas ps ON od.pizza_id = ps.pizza_id
	JOIN pizza_types py ON ps.pizza_type_id = py.pizza_type_id
	GROUP BY py.pizza_name) RankedPizza
WHERE RankedPizza.RankedQuantity <=5

/* Question 7:Which orders had the highest total value?*/

SELECT od.order_id,o.date,
	round((SUM(od.quantity * ps.pizza_price)::numeric),2) AS total_order_value
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
JOIN pizzas ps ON od.pizza_id = ps.pizza_id
GROUP BY o.date, od.order_id
ORDER BY total_order_value DESC;

/*Question 8:What is the average quantity of pizzas ordered per order for each pizza type?*/

SELECT 
	py.pizza_name, 
	ROUND(AVG(od.quantity),2) AS avg_pizza_quantity
FROM order_details od
JOIN pizzas ps ON od.pizza_id = ps.pizza_id
JOIN pizza_types py  ON py.pizza_type_id = ps.pizza_type_id
GROUP BY py.pizza_name
ORDER BY avg_pizza_quantity DESC


/* Question 9: Which pizza category is ordered the most in each month?*/

SELECT 
	PizzaOrdered.category, 
	PizzaOrdered.month, 
	PizzaOrdered.total_pizza_ordered
FROM (
	SELECT 
	py.category, 
	EXTRACT(MONTH FROM o.date) AS Month,
	SUM(od.quantity)  AS total_pizza_ordered,
	RANK( ) OVER(PARTITION BY py.category ORDER BY SUM(od.quantity) DESC) AS RankedPizza
	FROM order_details od
	JOIN pizzas ps ON od.pizza_id = ps.pizza_id
	JOIN pizza_types py  ON py.pizza_type_id = ps.pizza_type_id
	JOIN orders o ON od.order_id = o.order_id
	GROUP BY py.category, EXTRACT(month from o.date)) AS PizzaOrdered
WHERE PizzaOrdered.RankedPizza = 1
ORDER BY PizzaOrdered.total_pizza_ordered DESC;

/* Question 10: Which day generated the highest total revenue?*/

SELECT TotalRevenue.date, TotalRevenue.Total_Revenue
FROM(
	SELECT  o.date,
	round(SUM(od.quantity * ps.pizza_price)::numeric,2) AS Total_Revenue,
	rank() over (ORDER BY round(SUM(od.quantity * ps.pizza_price)::numeric,2) desc) AS RankedRevenue
	FROM 
	pizzas ps
	JOIN order_details od ON ps.pizza_id = od.pizza_id
	JOIN pizza_types py ON ps.pizza_type_id = py.pizza_type_id
	JOIN orders o ON od.order_id = o.order_id
	GROUP BY o.date) AS TotalRevenue
WHERE TotalRevenue.RankedRevenue = 1

/* Question 11: Which orders contain the most expensive pizza?*/

SELECT 
	od.order_id, 
	o.date
FROM pizzas ps
JOIN order_details od ON ps.pizza_id = od.pizza_id
JOIN orders o ON od.order_id = o.order_id
WHERE 
	ps.pizza_price = (SELECT MAX(pizza_price)
	FROM pizzas)


