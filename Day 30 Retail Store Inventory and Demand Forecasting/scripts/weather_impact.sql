/*
======================================= Seasonal and Weather Impact====================
	- Sales by Seasonality
	- Sales by Weather Condition
	

	SQL Functions Used:
    - Aggregate Functions: MIN(), MAX(), AVG(), SUM()
	- Window Ranking Function: RANK()
    - GROUP BY, ORDER BY, Subquery, CTE
*/

SELECT 
	-- Seasonality,
	 Weather,
	SUM(Units_Sold) as total_units_sold,
	ROUND(MIN(Revenue),2) as min_revenue,
	ROUND(MAX(Revenue),2) as max_revenue,
	ROUND(AVG(Revenue),2) as avg_revenue,
	ROUND(SUM(Revenue),2) as total_revenue,
	ROUND((SUM(Revenue) / 
			(SELECT SUM(Revenue) FROM Sales_Database..sales_data))*100,2) AS sales_contribution
FROM Sales_Database..sales_data
where Revenue !=0
GROUP BY Weather
ORDER BY total_revenue DESC;


-- Find the most sold category from each region according to weather condition
WITH top_weather_category AS(
SELECT *,
	RANK() OVER(PARTITION BY Weather, Region ORDER BY total_revenue DESC) as region_rank
FROM(
	SELECT Weather, 
			Region,
			Category,
			ROUND(SUM(Revenue),2) AS total_revenue
	FROM Sales_Database..sales_data
	GROUP BY Weather, Region, Category
	-- ORDER BY Weather,Region, total_revenue DESC
	) SC
)
SELECT Weather,
		Region,
		Category,
		total_revenue
FROM top_weather_category
WHERE region_rank = 1;

/*
============================================= Summary Report =======================================================

1. Regional Differences
	- The North region tends to generate higher revenues for groceries, especially in sunny and cloudy weather.
	- The West region is the only region where furniture revenue is relatively notable (cloudy: 13,661,043.61; sunny: 15,911,682.1).

2. Groceries Generate High Revenue Across All Regions and Weather
	- Groceries consistently have the highest total revenue in every region and weather condition.
	- The highest revenue for groceries appears in the North region during sunny weather (24,620,785.81), 
	  followed by the South region during cloudy weather (14,211,648.26).

3. Weather Impacts Revenue
	- Sunny weather is associated with the highest total revenues, especially for groceries (North: 24,620,785.81; 
	  East: 13,309,009.89; South: 13,086,747.64).
	- Rainy and snowy conditions generally see lower revenues compared to sunny and cloudy conditions.


Recommendations & Solutions
1. Leverage Sunny Weather for Promotions: 
			- Since revenue peaks during sunny weather, plan major sales campaigns, outdoor events, or special offers during 
			 forecasted sunny periods to maximize sales, especially for groceries.

2. Boost Sales in Low-Performing Weather: 
			-Develop targeted promotions or bundled offers for rainy and snowy days to encourage purchases when revenue typically dips.
			-Consider delivery promotions or "bad weather" discounts to attract customers who might avoid shopping in poor weather.

3. Regional Strategy Customization
			- For the West, investigate why furniture performs relatively better and replicate successful strategies in other regions.


In summary:
	- Sunny weather and the North region drive the most revenue, especially for groceries.
	- Furniture needs more attention, especially outside the West.
	- Leverage weather and regional trends for targeted promotions, inventory, and marketing strategies.

*/