
CREATE DATABASE DataWarehouseAnalytic;


SELECT * 
FROM DataWarehouseAnalytic..[gold.dim_customers];

SELECT * 
FROM DataWarehouseAnalytic..[gold.fact_sales];

SELECT * 
FROM DataWarehouseAnalytic..[gold.dim_products];

------------------------------------ Change over Time (Year) -----------------------------------------
SELECT 
		YEAR(order_date) as order_year, 
		MONTH(order_date) as order_month,
		SUM(sales_amount) as total_sales,
		COUNT(Distinct customer_key) as total_customer,
		SUM(quantity) as total_quantity
FROM DataWarehouseAnalytic..[gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


------------------ DATETRUNC() -------------------------
SELECT	
		DATETRUNC(MONTH,order_date) as order_month,
		SUM(sales_amount) as total_sales,
		COUNT(Distinct customer_key) as total_customer,
		SUM(quantity) as total_quantity
FROM DataWarehouseAnalytic..[gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY  DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date);

------------------ FORMAT() -------------------------
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM DataWarehouseAnalytic..[gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');


------------------------------ Cumulative Analysis -----------------------------------------------
-- Calculate the total sales per month and the running total of sales over time

SELECT 
	order_month, 
	total_sales,
	SUM(total_sales) over(ORDER BY  order_month) as cumulative_sales
FROM (
	SELECT 
		DATETRUNC(MONTH, order_date) as order_month,
		SUM(sales_amount) as total_sales
	FROM DataWarehouseAnalytic..[gold.fact_sales]
	WHERE order_date is NOT NULL
	GROUP BY  DATETRUNC(MONTH, order_date)
-- Order by DATETRUNC(MONTH, order_date)
) As M;

-------------------
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM DataWarehouseAnalytic..[gold.fact_sales]
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) Y;



------------------ Performance Analysis-------------------------------------------

-- Analyze the yearly performance of products by comparing each product's sales to both its average sales performance and the previous year's sales.


WITH yearly_product_sales AS(
	SELECT 
		YEAR(f.order_date) AS order_year, 
		p.product_name, 
		SUM(f.sales_amount) AS current_sales
	FROM DataWarehouseAnalytic..[gold.fact_sales] f
	LEFT JOIN DataWarehouseAnalytic..[gold.dim_products] p
	 ON f.product_key = p.product_key
	WHERE f.order_date is NOT NULL
	GROUP BY YEAR(f.order_date), p.product_name
-- Order by Year(f.order_date), current_sales DESC
)
Select 
	order_year, 
	product_name, 
	current_sales,
	AVG(current_sales) over(PARTITION BY product_name) avg_sales,
	current_sales - AVG(current_sales) over(partition by product_name) as diff_avg,
	CASE 
		WHEN current_sales - AVG(current_sales) over(PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN current_sales - AVG(current_sales) over(PARTITION BY product_name) < 0 THEN 'Below Avg'
		Else 'Avg'
		End  avg_change,
	--- Year-over-Year Performance Analysis ---
	LAG(current_sales) over(PARTITION BY product_name ORDER BY order_year) as previous_year_sales,
	current_sales - LAG(current_sales) over(PARTITION BY product_name ORDER BY order_year) as diff_previous,
	CASE 
		WHEN current_sales - LAG(current_sales) over(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) over(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
		END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;



-- Yearly performance of products by comparing each product's sales to its average sales performance 
WITH yearly_sales As (
Select YEAR(f.order_date) as order_date, 
		p.product_name, 
		suM(f.sales_amount) as current_sales
From DataWarehouseAnalytic..[gold.fact_sales] f 
Left Join DataWarehouseAnalytic..[gold.dim_products] p
On f.product_key = p.product_key
Where f.order_date	 IS NOT NULL
Group by Year(f.order_date), p.product_name
) 
Select * , 
	AVG(current_sales) over(partition by product_name) as avg_sale,
	current_sales - AVG(current_sales) over(partition by product_name) as diff_avg,
	CASE when AVG(current_sales) over(partition by product_name) > 0 Then 'Above Avg'
		 When AVG(current_sales) over(partition by product_name) < 0 Then 'Below Avg'
		 Else 'Avg'
		 End avg_changes
from yearly_sales
order by product_name, order_date;


-- Yearly performance of products by comparing each product's sales to its previous year's sales.
WITH yearly_sales As (
Select YEAR(f.order_date) as order_date, 
		p.product_name, 
		suM(f.sales_amount) as current_sales
From DataWarehouseAnalytic..[gold.fact_sales] f 
Left Join DataWarehouseAnalytic..[gold.dim_products] p
On f.product_key = p.product_key
Where f.order_date	 IS NOT NULL
Group by Year(f.order_date), p.product_name
) 
Select *, 
	LAG(current_sales) over(partition by product_name order by order_date) as previous_sales,
	current_sales - LAG(current_sales) over(partition by product_name order by order_date) as sales_diff,
	Case When current_sales - LAG(current_sales) over(partition by product_name order by order_date) > 0 Then 'Increase'
		When current_sales - LAG(current_sales) over(partition by product_name order by order_date) < 0 Then 'Decrease'
		Else 'No Change'
		End py_change
from yearly_sales
order by product_name, order_date;




--------------------------------------- Part-to-Whole Analysis --------------------------------------------------------
/*
Analyze how an invidual part is performing compared to the overall, allowing 
us to understand which category has the greatest impact on the business.
*/
-- Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales,
		SUM(f.quantity) AS total_quantity
    FROM DataWarehouseAnalytic..[gold.fact_sales] f
    LEFT JOIN DataWarehouseAnalytic..[gold.dim_products] p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
	total_quantity,
    SUM(total_sales) OVER () AS overall_sales,
	SUM(total_quantity) OVER() AS overall_quantity,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2),'%') AS percentage_of_total,
	CONCAT(ROUND((CAST(total_quantity AS FLOAT) / SUM(total_quantity) OVER ()) * 100, 2),'%') AS percentage_of_total_quantity
FROM category_sales
ORDER BY total_sales DESC;

-------- OR -------------------
Select p.category, 
sum(f.sales_amount) as total_sales,
Round((cast(sum(f.sales_amount)as float) / 
(Select SUM(sales_amount) from DataWarehouseAnalytic..[gold.fact_sales])) *100,2) as percentage_total
from DataWarehouseAnalytic..[gold.fact_sales] f
Left Join DataWarehouseAnalytic..[gold.dim_products] p
on f.product_key = p.product_key
Group by p.category
Order by percentage_total;


---- Quantity -------
Select p.category, 
sum(f.quantity) as total_quantity,
Concat(Round((cast(sum(f.quantity)as float) / 
(Select SUM(quantity) from DataWarehouseAnalytic..[gold.fact_sales])) *100,2),'%') as percentage_total
from DataWarehouseAnalytic..[gold.fact_sales] f
Left Join DataWarehouseAnalytic..[gold.dim_products] p
on f.product_key = p.product_key
Group by p.category
order by total_quantity DESC;


-----------------------------Data Segmentation----------------------------------------------

-- Segment products into cost ranges and count how many products fall into each segment
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM DataWarehouseAnalytic..[gold.dim_products]
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


----------------------------
/*
Group customers into three segments based on their spending:
- VIP: Customers with atleast 12 months of history and spending more than $5000
- Regular: Customers with atleast 12 months of history but spending $5000 or less
- New: lifespan less than 12 months
And find the total number of customers by each group
*/

WITH customer_segment AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM DataWarehouseAnalytic..[gold.fact_sales] f
    LEFT JOIN DataWarehouseAnalytic..[gold.dim_customers] c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
	customer_key,
	customer_status,
	COUNT(customer_key) total_customers
FROM(
	SELECT
		customer_key, 
		total_spending, 
		lifespan,
		CASE 
			WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP Customer'
			WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular Customer'
			ELSE 'New Customer'
		END customer_status
	FROM customer_segment 
) segmented_customer
GROUP BY customer_status
ORDER BY total_customers DESC;

----------------- OR ------------------------

WITH customer_segment AS(
	Select 
		customer_key, 
		total_spending, 
		lifespan,
		CASE 
			WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP Customer'
			WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular Customer'
			ELSE 'New Customer'
		END customer_status
	From(
		SELECT 
			c.customer_key, 
			SUM(f.sales_amount) as total_spending,
			MIN(f.order_date) as first_order,
			MAX(f.order_date) as last_order,
			DATEDIFF(MONTH, min(f.order_date), MAX(f.order_date)) as lifespan
		FROM DataWarehouseAnalytic..[gold.fact_sales] f
		LEFT JOIN DataWarehouseAnalytic..[gold.dim_customers] c
		ON f.customer_key = c.customer_key
		GROUP BY c.customer_key) as a
)
SELECT
	customer_status,
	COUNT(customer_key) as total_customers
FROM customer_segment
GROUP BY customer_status
ORDER BY total_customers DESC;

/*
----------------------------- Customer Report -----------------------------
Purpose: 
		This report consoliderate key customer metrics and behaviors

Highlights:
	1. Gather essential fields such as names, ages and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total quantity purchased
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- avarage monthly spend
*/

--------------------------------------------------------------------------


CREATE VIEW [gold.report_customers] As
WITH base_query as(
-- 1. Basic Query: Retrives core columns from tables
SELECT 
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name,' ',c.last_name) as customer_name,
		c.gender,
		DATEDIFF(year, c.birthdate, GETDATE()) age
FROM DataWarehouseAnalytic..[gold.fact_sales] f
JOIN DataWarehouseAnalytic..[gold.dim_customers] c
ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL
), 
customer_aggregation as(
-- Customer Aggreagations: Summarize key metrics at the customer level
SELECT customer_key, customer_number, customer_name,age,
	COUNT(Distinct order_number) as total_orders,
	SUM(sales_amount) as total_sales,
	SUM(quantity) as total_quantity,
	COUNT(Distinct product_key) as total_products,
	MAX(order_date) as last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age 
)
SELECT 
		customer_key,
		customer_number,
		customer_name, 
		age,
	CASE 
		 WHEN age < 20 THEN 'Under 20'
		 WHEN age between 21 and 30 THEN '20 - 30'
		 WHEN age between 31 and 40 THEN '31-40'
		 WHEN age between 41 and 50 THEN '41-50'
		 ELSE 'Above 50'
	END age_group ,
	total_quantity,
	total_orders,
	total_sales,
	lifespan,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP Customer'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular Customer'
		ELSE 'New Customer'
	END customer_segment,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) as recency,
-- computer average order value (AOV)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders 
	 END as avg_order_value,

-- Average ,monthly spend
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/lifespan
	END as avg_monthly_spend 
FROM customer_aggregation;




Select * From [gold.report_customers];



---------------------------------------------------------------------------
/*
========================= Product Report ===========================

Purpose: 
	This report consolidates key product metrics and behaviors.

Highlights: 
	1. Gather essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-performing, mid-range or low-performers
	3. Aggergates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue
		- average monthly revenue
*/

Create View [gold.product_report] As
With base_query as(
	Select
		p.product_key, 
		p.product_name, 
		p.category, 
		p.subcategory,
		p.cost,
		f.customer_key,
		f.order_number,
		f.order_date, 
		f.sales_amount, 
		f.quantity
	From DataWarehouseAnalytic..[gold.dim_products] p
	Join DataWarehouseAnalytic..[gold.fact_sales] f
	On p.product_key = f.product_key
	Where order_date IS NOT NULL
	), 
	product_segment as(
		Select
			product_key,
			product_name,
			category, 
			subcategory,
			COUNT(distinct order_number) as total_order,
			SUM(quantity) as total_quantity,
			SUM(cost) as total_cost,
			SUM(sales_amount) as total_sales,
			COUNT(Distinct customer_key) as total_customer,
			ROUND(AVG( CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) AS avg_selling_price,
			MAX(order_date) as last_sales_date,
			DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
	From base_query
	Group by product_key,product_name, category, subcategory
	)
  select 
	product_key,
	product_name, 
	category, 
	subcategory,
	total_customer,
	total_quantity,
	total_order,
	total_cost,
	total_sales,
	CASE
		when total_sales < 150000 Then 'Low Performing'
		When total_sales Between 150000 AND 500000 THEN 'Mid-Range'
		ELSE 'High Performing'
	END product_category,
	last_sales_date,
	DATEDIFF(MONTH, last_sales_date, GETDATE()) as recency,
------ Average order revenue
	CASE 
		when total_order = 0 Then 0
		Else total_sales / total_order 
	End as avg_order_rev,

	lifespan,
-- Average monthly revenue
	CASE
		when lifespan = 0 Then total_sales
		Else total_sales/lifespan
	End as avg_monthly_revenue
From product_segment;


Select * From [gold.product_report];


