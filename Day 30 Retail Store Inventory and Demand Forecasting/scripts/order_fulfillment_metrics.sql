/*
======================================== Order and Fulfillment Metrics ================================================
		- Total Units Orders vs Units Sold
		- Fulfillment Rate: Units Sold / Units Ordered
	
	Purpose:
		 - Tracking Operational Efficiency and ensuring Order Accuracy
		 - Managing Inventory Effectiveness
		 - Improving Delivery Performance

	SQL Functions Used:
		- Aggregate Functions: SUM()
		- WHERE, GROUP BY, ORDER BY
*/


SELECT Region,
		Category,
		SUM(Units_Sold) as total_units_sold,
		SUM(Units_Ordered) AS total_units_ordered,	
		ROUND((CAST(SUM(Units_Sold) AS FLOAT) / SUM(Units_Ordered) * 100),2) AS Fulfillment_Rate
FROM Sales_Database..sales_data
GROUP BY Region, Category
ORDER BY Region, Category, Fulfillment_Rate DESC;


-- Find the fullfillment Rate when both unit sold and unit orders are greater than 0
SELECT
	Category,
		SUM(Units_Sold) as total_units_sold,
		SUM(Units_Ordered) AS total_units_ordered,	
		ROUND((CAST(SUM(Units_Sold) AS FLOAT) / CAST(SUM(Units_Ordered) as float) * 100),2) AS Fulfillment_Rate
FROM Sales_Database..sales_data
WHERE Units_Sold != 0 
	AND Units_Ordered != 0
GROUP BY Category
ORDER BY Fulfillment_Rate DESC;


