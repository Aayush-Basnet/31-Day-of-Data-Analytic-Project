/*
=============================== Inventory and Demand Metrics =================================
		- Total Inventory Level Per Store or Category
		- Inventory Turnover Ratio
		- Total Demand per Product, Category or Store


	SQL Functions Used:
		- Aggregate Functions: SUM()
		- GROUP BY, ORDER BY
*/

	SELECT 
		Store_ID,
		Category, 
		SUM(Inventory_Level) as total_inventory_level,
		SUM(Units_Sold) as total_unit_sold,
		ROUND(CAST(SUM(Units_Sold) as FLOAT) /
			SUM(Inventory_Level) * 100,2) AS inventory_turnover,
		SUM(Demand) as total_demand
	FROM Sales_Database..sales_data
	GROUP BY Store_ID, Category
	ORDER BY Store_ID, inventory_turnover DESC;


SELECT AVG(inventory_turnover) as avg_inventory_turnover
FROM (
SELECT
	Category,
	SUM(Demand) as total_demand,
	SUM(Units_Sold) as total_unit_sold,
	SUM(Inventory_Level) as total_inventory_level,
	ROUND(CAST(SUM(Units_Sold) as FLOAT) /
			SUM(Inventory_Level) * 100,2) AS inventory_turnover
FROM Sales_Database..sales_data
GROUP BY Category
-- ORDER BY inventory_turnover DESC
) AI
/*
======================================Summary Report============================================
Summary Table
Category	|| Typical Inventory Turnover	|| Sales Volume	||  Demand	||			Notes/Actions
Groceries	||           24–33		    	||     High		||  High    || Maintain supply, optimize forecasting
Clothing	||           25–68			    ||    Medium	|| Medium 	|| Replicate S005 strategies elsewhere
Electronics	||			 17–67				||	Low-Med		||  Low		|| Reduce excess, boost demand
Toys	    ||			 24–45				||	  Low		||  Low		|| Review assortment, promo needed
Furniture	||			 20–31			    ||	  Low		||  Low		|| Accept lower turnover, monitor trends

In summary:
	- Groceries are the main driver of volume and demand.
	- Clothing can be very efficient in the right location.
	- Electronics and Toys need focused improvement in certain stores.
	- Furniture typically has slower movement, which is expected.

Action: 
	Focus on optimizing inventory and boosting demand for underperforming categories, especially where 
	turnover is low and inventory is high.


*/