select *
from salesdb

/*Question 1:  Which customers have generated total sales above $10,000?*/

SELECT
	customer_id,
	customer_name,
	SUM(sales) AS Total_sales
FROM 
	salesdb
GROUP BY
	customer_id,
	customer_name
HAVING
	SUM(sales) IN(
	SELECT
	Total_sales
	FROM  (
		SELECT 
		SUM(sales) AS Total_sales
		FROM  
		salesdb
		GROUP BY
		customer_name)
		WHERE 
		Total_sales > 10000)
ORDER BY
	Total_sales DESC;

/*Question 2: What are the top three most profitable sub_category products overall?*/

SELECT 
	sub_category,
	SUM(profit) AS Total_profit
FROM 
	salesdb
GROUP BY 
	sub_category
HAVING 
	SUM(profit) IN (
	select 
	Total_profit
	FROM (
		SELECT 
		SUM(profit) AS Total_profit
		FROM 
		salesdb
		GROUP BY 
		sub_category)
	WHERE 
	Total_profit > 40000)
ORDER BY 
	Total_profit DESC;


-- OR

SELECT 
	sub_category,
	Total_profit
FROM (
	SELECT 
	sub_category,
	SUM(profit) AS Total_profit,
	RANK() OVER (ORDER BY SUM(profit) DESC) AS RankedProfit
	FROM 
	salesdb
	GROUP BY 
	sub_category)
WHERE 
	RankedProfit <=3;

/*Question 3: What is the average lead time for orders that were shipped 
	using "Second Class" or "Standard Class" modes?*/

SELECT 
	ship_mode,
	ROUND(AVG(lead_time),2) AS avg_LeadTime
FROM (
	SELECT 
	ship_mode, 
	lead_time 
	FROM 
	salesdb
	WHERE 
	ship_mode IN ('Second Class', 'Standard Class'))
GROUP BY ship_mode;


/*Question 4: Which sub_category products have a negative average profit?*/

SELECT sub_category,
	ROUND(AVG(profit),2) AS Avg_Profit
FROM 
	salesdb
GROUP BY 
	sub_category
HAVING AVG(profit) IN (
	SELECT Avg_Profit
	FROM (
		SELECT 
		AVG(profit) AS Avg_Profit
		FROM 
		salesdb
		GROUP BY 
		sub_category)
	WHERE 
	Avg_Profit> 0)
ORDER BY
	Avg_Profit DESC;


/*Question 5: How does the profit margin differ between customer segments?*/

SELECT segment, 
	ROUND(Total_Profit/Revenue * 100,2) AS Profit_Margin
FROM (
	SELECT 
	segment, 
	SUM(profit) AS Total_Profit,
	SUM (sales * quantity * (1-discount)) as Revenue
	FROM 
	salesdb
	GROUP BY 
	segment) AS SegmentMargin
ORDER BY Profit_Margin DESC;

/*Question 6: Which products have been sold with the highest average discount?*/

SELECT 
	product_name,
	product_id,
	ROUND(AVG(discount*sales*quantity),2) AS Avg_Discount
FROM 
	salesdb
GROUP BY 
	product_name,
	product_id
HAVING AVG(discount*sales*quantity) IN  (
	SELECT 
	Avg_Discount
	FROM(
		SELECT 
		AVG(discount*sales*quantity) AS Avg_Discount
		FROM 
		salesdb
		GROUP BY 
		product_name,
		product_id)
	WHERE Avg_Discount >=6000)
ORDER BY 
	Avg_Discount DESC;

	--OR

SELECT 
	product_name,
	product_id,	
	Avg_Discount
FROM(
	SELECT 
	product_name,
	product_id,
	ROUND(AVG(discount*sales*quantity),2) AS Avg_Discount,
	RANK() OVER(ORDER BY AVG(discount*sales*quantity) DESC) AS RankedDiscount
	FROM 
	salesdb
	GROUP BY 
	product_name,
	product_id)
WHERE 
	RankedDiscount <=5

/*Question 7:  Which customers generated the highest profit?*/

SELECT 
	customer_name,
	SUM(profit) AS Total_Profit
	FROM salesdb
	GROUP BY 
	customer_name
	HAVING SUM(profit) IN (SELECT Total_Profit
FROM (SELECT SUM(profit) AS Total_Profit
FROM salesdb
GROUP BY customer_name)
WHERE Total_Profit > 5000
)
ORDER BY Total_Profit DESC;


--OR


SELECT 
	customer_name,
	customer_id,
	Total_Profit
FROM (
	SELECT 
	customer_name,
	customer_id,
	SUM(profit) AS Total_Profit,
	RANK() OVER (ORDER BY SUM(profit) DESC) AS RankedProfit
	FROM 
	salesdb
	GROUP BY 
	customer_name,
	customer_id)
WHERE RankedProfit <=5;
	

/*Question 8: What are the top-performing products by sales in each city?*/

SELECT 
	sub_category,
	city,
	Total_Sales
FROM (
	SELECT 
	sub_category,
	city,
	SUM(sales) AS Total_Sales,
	RANK() OVER (Partition by city ORDER BY SUM(sales) DESC) AS RankedSales
	FROM 
	salesdb
	GROUP BY 
	sub_category,
	city)
WHERE 
	RankedSales =1
ORDER BY 
	Total_Sales DESC
;

/*Question 9: What is the month-over-month growth in sales?*/

SELECT 
    Month, 
    Monthly_sales, 
    ROUND((Monthly_sales - LAG(Monthly_sales) OVER (ORDER BY Month)) / LAG(Monthly_sales) OVER (ORDER BY Month) * 100, 2) AS GrowthRate
FROM(
	SELECT 
	SUM(sales) AS  Monthly_sales,
	EXTRACT(MONTH FROM order_date) AS  Month
	FROM 
	salesdb
	GROUP BY 
	Month);
	







