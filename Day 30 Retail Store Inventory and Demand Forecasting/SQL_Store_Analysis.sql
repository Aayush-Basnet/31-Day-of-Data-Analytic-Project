
SELECT *
FROM Sales_Database..sales_data

-------------------------------------------------------------------------------------------
/*
======================================= Sales and Revenue Metrics ====================================
	1. Total Units Sold per Product, Category, or Store
	2. Total Revenue
	3. Average Price per Category or Product
	4. Total Discounts Given:
*/

-- Total Units sold per product, category, or store

SELECT 
	Product_ID,
	ROUND(SUM(Units_Sold),2) as total_unit_sold
FROM Sales_Database..sales_data
GROUP BY Product_ID
ORDER BY Product_ID;

--------------------- Category------------
SELECT 
	Category,
	ROUND(SUM(Units_Sold),2) as total_unit_sold
FROM Sales_Database..sales_data
GROUP BY Category
ORDER BY total_unit_sold DESC;

---------------------------
SELECT 
	Store_ID,
	ROUND(SUM(Units_Sold),2) as total_unit_sold
FROM Sales_Database..sales_data
GROUP BY Store_ID
ORDER BY Store_ID;

-- Total Revenue, unit sold, Discount
SELECT 
		ROUND(SUM(Revenue),2) as total_revenue,
		SUM(Units_Sold) as total_unit_sold,
		SUM(Discount) as total_discount_given
FROM Sales_Database..sales_data


-- Average Price per Category

SELECT 
		Category,
		ROUND(AVG(Price),2) as avg_price,
		ROUND(SUM(Revenue),2) as total_sales 
FROM Sales_Database..sales_data
GROUP BY Category
ORDER BY total_sales DESC

-----------------------------------------------------------------------------------------

/*
=================================== Inventory and Demand Metrics================
	- Total Inventory Level Per Store or Category
	- Inventory Turnover Ratio
	- Total Demand per Product, Category or Store
*/
	SELECT 
	Store_ID,
	Category, 
	SUM(Inventory_Level) as total_inventory_level,
	SUM(Units_Sold) as total_unit_sold,
	ROUND(CAST(SUM(Units_Sold) as FLOAT) / SUM(Inventory_Level) * 100,2) AS inventory_turnover,
	SUM(Demand) as total_demand
	FROM Sales_Database..sales_data
	GROUP BY Store_ID, Category
	ORDER BY Store_ID, inventory_turnover DESC;


	------------------------------------------------------------------------
	/*
	======================== Order and Fulfillment Metrics ======================
		- Total Units Orders vs Units Sold
		- Fulfillment Rate: Units Sold / Units Ordered
	
	*/


	SELECT Region,
		Category,
		SUM(Units_Sold) as total_units_sold,
		SUM(Units_Ordered) AS total_units_ordered,	
		ROUND((CAST(SUM(Units_Sold) AS FLOAT) / SUM(Units_Ordered) * 100),2) AS Fulfillment_Rate
	FROM Sales_Database..sales_data
	GROUP BY Region, Category
	ORDER BY Region, Category, Fulfillment_Rate DESC

-------------------------------------------------------------
/*
======================================= Seasonal and Weather Impact====================
	- Sales by Seasonality
	- Sales by Weather Condition
Note: We have four season and four weather
*/

SELECT Seasonality,Weather,
	SUM(Units_Sold) as total_units_sold,
	ROUND(SUM(Revenue),2) as total_revenue,
	ROUND((SUM(Revenue) / 
	(SELECT SUM(Revenue) FROM Sales_Database..sales_data))*100,2) AS sales_contribution
FROM Sales_Database..sales_data
GROUP BY Seasonality, Weather
ORDER BY Seasonality, total_revenue DESC;

---------------------------------------Effect of Epidemic on Demand or Sales--------------

--  compare average units sold:
SELECT
  Epidemic,
  AVG(Units_Sold) AS avg_units_sold,
  SUM(Units_Sold) AS total_units_sold,
  COUNT(*) AS number_of_sales
FROM Sales_Database..sales_data
GROUP BY Epidemic;

-- difference in total sales revenue
SELECT
  Epidemic,
  ROUND(SUM(Units_Sold * Price),2) AS total_revenue,
  ROUND(AVG(Revenue),2) AS avg_revenue_per_sale
FROM Sales_Database..sales_data
GROUP BY Epidemic;


--------------------------------- Sales-Over-Time -------------------------------------------------------------------------


SELECT  YEAR(Date) as sale_year, 
		MONTH(Date) as sales_month,
		SUM(Units_Sold) as total_unit_sold,
		ROUND(SUM(Revenue),2) as total_sales
FROM sales_Database..sales_data
Group BY YEAR(Date), MONTH(Date)
ORDER BY YEAR(Date), MONTH(Date);


SELECT DATETRUNC(MONTH, Date) as sales_month,
		SUM(Units_Sold) as total_unit_sold,
		ROUND(SUM(Revenue),2) as total_sales
FROM Sales_Database..sales_data
GROUP BY DATETRUNC(MONTH, Date)
ORDER BY DATETRUNC(MONTH, Date)

---------------------- Cumulative Analysis---------------------------------------------------------

SELECT
	sales_month,
	total_unit_sold,
	ROUND(SUM(total_unit_sold) over(ORDER BY sales_month),2) as running_total_unit_sales,
	total_sales,
	ROUND(SUM(total_sales) over(ORDER BY sales_month),2) as total_running_sales,
	avg_price,
	ROUND(AVG(avg_price) over(ORDER BY sales_month),2) as moving_avg
FROM (
SELECT DATETRUNC(MONTH, Date) as sales_month,
		SUM(Units_Sold) as total_unit_sold,
		ROUND(SUM(Revenue),2) as total_sales,
		ROUND(AVG(Price),2) as avg_price
FROM Sales_Database..sales_data
GROUP BY DATETRUNC(MONTH, Date)
) MS

------------------------------------
SELECT
	sales_year,
	total_unit_sold,
	ROUND(SUM(total_unit_sold) over(ORDER BY sales_year),2) as running_total_unit_sales,
	total_sales,
	ROUND(SUM(total_sales) over(ORDER BY sales_year),2) as total_running_sales,
	avg_price,
	ROUND(AVG(avg_price) over(ORDER BY sales_year),2) as moving_avg
FROM (
SELECT DATETRUNC(YEAR, Date) as sales_year,
		SUM(Units_Sold) as total_unit_sold,
		ROUND(SUM(Revenue),2) as total_sales,
		ROUND(AVG(Price),2) as avg_price
FROM Sales_Database..sales_data
GROUP BY DATETRUNC(YEAR, Date)
) YS


--------------------------------------------------------------------------------------------------------
-- Analyze the yearly performance of category by comparing each category's sales to both its average sales performance
WITH yearly_performance As(
SELECT 
	YEAR(Date) as sales_year,
	Category,
	ROUND(SUM(Revenue),2) as total_revenue
FROM Sales_Database..sales_data
GROUP BY YEAR(Date),Category
)
SELECT sales_year,
		Category,
		total_revenue,
		ROUND(AVG(total_revenue) over(PARTITION BY Category),2) avg_sales,
		total_revenue - ROUND(AVG(total_revenue) over(PARTITION BY Category),2) as avg_diff,
		CASE
			WHEN total_revenue - ROUND(AVG(total_revenue) over(PARTITION BY Category),2) > 0 THEN 'Above Avg'
			WHEN total_revenue - ROUND(AVG(total_revenue) over(PARTITION BY Category),2) < 0 THEN 'Below Avg'
			ELSE 'Avg'
		END avg_change
FROM yearly_performance
ORDER BY  Category, sales_year;

-----------------------------------------------------Part-to-Whole Analysis--------------------------------------


-- Which categories contribute the most to overall sales?
SELECT Category,
	ROUND(SUM(Revenue),2) as total_sales,
	SUM(Units_sold) as total_unit_sold,
	ROUND((SUM(Revenue) / 
	(SELECT SUM(Revenue) FROM Sales_Database..sales_data))*100,2) AS sales_contribution,
	ROUND((CAST(SUM(Units_sold) as FLOAT) /
	(SELECT SUM(Units_sold) FROM Sales_Database..sales_data))*100,2) AS unit_contribution
FROM Sales_Database..sales_data
GROUP BY Category
ORDER BY sales_contribution DESC;


---------------------------------------------Geographic Performance--------------------------------------------------------------------------
	-- Geographic Distribution
SELECT Region,
	ROUND(SUM(Revenue),2) as total_sales,
	SUM(Units_sold) as total_unit_sold,
	ROUND((SUM(Revenue) / 
	(SELECT SUM(Revenue) FROM Sales_Database..sales_data))*100,2) AS sales_contribution,
	ROUND((CAST(SUM(Units_sold) as FLOAT) /
	(SELECT SUM(Units_sold) FROM Sales_Database..sales_data))*100,2) AS unit_contribution
FROM Sales_Database..sales_data
GROUP BY Region
ORDER BY sales_contribution DESC

-- Find top 3 category from each region 

WITH top_3 As(
SELECT Region,
		Category,
		total_sales,
		RANK() over(Partition by Region order by total_sales DESC) AS category_rank
FROM( 
SELECT Region, Category,
		ROUND(SUM(Revenue),2) as total_sales
FROM Sales_Database..sales_data
GROUP BY Region, Category
-- ORDER BY Region, total_sales DESC
) a
)
Select *
From top_3
Where category_rank <=3;


-------------------------------------------Product Segmentation--------------------------------------------------
-- Segment products into unit sold and count how many products fall into each segment

SELECT 
        DATETRUNC(MONTH, Date) AS sales_month,
        Product_ID,
        AVG(Units_Sold) AS monthly_unit_sold
    FROM Sales_Database..sales_data
    GROUP BY DATETRUNC(MONTH, Date), Product_ID;


--------------------------




WITH monthly_sales AS (
    SELECT 
        DATETRUNC(MONTH, Date) AS sales_month,
        Product_ID,
        SUM(Units_Sold) AS monthly_unit_sold
    FROM Sales_Database..sales_data
    GROUP BY DATETRUNC(MONTH, Date), Product_ID
),
avg_monthly_sales AS (
    SELECT AVG(monthly_unit_sold) AS avg_sold
    FROM monthly_sales
)
SELECT 
    ms.sales_month,
    ms.Product_ID,
    ms.monthly_unit_sold,
	ams.avg_sold,
    CASE
        WHEN ms.monthly_unit_sold > ams.avg_sold THEN 'Above Avg'
        WHEN ms.monthly_unit_sold < ams.avg_sold THEN 'Below Avg'
        ELSE 'Avg'
    END AS Product_Segmentation
FROM monthly_sales ms
CROSS JOIN avg_monthly_sales ams
ORDER BY ms.sales_month, ms.Product_ID;

----------------------------------------------
