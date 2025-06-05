/*
======================================= Effect of Epidemic on Demand or Sales====================
		- Compare average units sold
		- Difference in total sales revenue
	
	SQL Function Used: 
		- Aggregate Functions: SUM(), AVG(), COUNT()
	    - Clauses: GROUP BY
*/


--  Compare average units sold:
SELECT
  Epidemic,
  AVG(Units_Sold) AS avg_units_sold,
  SUM(Units_Sold) AS total_units_sold,
  COUNT(*) AS number_of_sales
FROM Sales_Database..sales_data
GROUP BY Epidemic;

-- Difference in total sales revenue
SELECT
  Epidemic,
  ROUND(SUM(Units_Sold * Price),2) AS total_revenue,
  ROUND(AVG(Revenue),2) AS avg_revenue_per_sale
FROM Sales_Database..sales_data
GROUP BY Epidemic;