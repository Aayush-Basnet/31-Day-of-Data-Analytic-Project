
Select * From project..pizza_sales;

-- 1. Total Revenue
		SELECT Round(SUM(total_price),2) as total_sales
		From project..pizza_sales;


-- 2. Average Order Value
		Select Round((sum(total_price) / COUNT(Distinct order_id)),2) As Avg_ordered_value
		From project..pizza_sales


-- 3. Total Pizzas Sold
		SELECT SUM(quantity) as total_pizza_sold 
		FROM project..pizza_sales;


-- 4. Total Orders
		SELECT COUNT(Distinct order_id) AS total_orders
		FROM project..pizza_sales;

	

-- 5. Average Pizzas Per Order
		SELECT 
		CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
							CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS avg_pizzas_per_order
		FROM project..pizza_sales;


-- 6 Daily Trend for Total Orders

		Select DATENAME(DW, order_date) as order_day,
			COUNT(Distinct order_id) As total_orders
		From project..pizza_sales
		Group By DATENAME(DW, order_date);


-- 7. Monthly Trend for Orders
		Select DATENAME(MONTH, order_date) as order_month,
			COUNT(Distinct order_id) As total_orders
		From project..pizza_sales
		Group By DATENAME(MONTH, order_date);


-- 8. % of Sales by Pizza Category
		SELECT pizza_category,
			Round(sum(total_price),2) as total_revenue,
			Round((SUM(total_price) / 
						(select sum(total_price) from project..pizza_sales))*100,2) as percent_slaes_pizza_category
		FROM project..pizza_sales
		Group by pizza_category;
		

-- 9. % of Sales by Pizza Size
		SELECT pizza_size,
			Round(sum(total_price),2) as total_revenue,
			Round((SUM(total_price) / 
						(select sum(total_price) from project..pizza_sales))*100,2) as percent_slaes_pizza_size
		FROM project..pizza_sales
		Group by pizza_size
		ORDER BY total_revenue DESC;


-- 10. Total Pizzas Sold by Pizza Category
		SELECT pizza_category,
			SUM(quantity) as total_pizza_sold
		From project..pizza_sales
		Group By pizza_category
		ORDER BY total_pizza_sold DESC;


-- 11. Top 5 Pizzas by Revenue
		SELECT Top 5 pizza_name,
				SUM(total_price) as total_sales,
				Round((SUM(total_price) / (Select SUM(total_price) from project..pizza_sales))*100,2) as percent_sales_pizza
		FROM project..pizza_sales
		Group By pizza_name
		Order by total_sales DESC;

		select distinct pizza_name
		From project..pizza_sales;


-- 12.  Bottom 5 Pizzas by Revenue
			SELECT Top 5 pizza_name,
				SUM(total_price) as total_sales,
				Round((SUM(total_price) / (Select SUM(total_price) from project..pizza_sales))*100,2) as percent_sales_pizza
		FROM project..pizza_sales
		Group By pizza_name
		Order by total_sales ASC;


-- 13. Top 5 Pizzas by Quantity
				SELECT Top 5 pizza_name,
				SUM(quantity) as top_pizza_sold
		FROM project..pizza_sales
		Group By pizza_name
		Order by top_pizza_sold DESC;


-- 14. Bottom 5 Pizzas by Quantity
		SELECT Top 5 pizza_name,
				SUM(quantity) as bottom_pizza_sold
		FROM project..pizza_sales
		Group By pizza_name
		Order by bottom_pizza_sold ASC;


-- 15. Top 5 Pizzas by Total Orders
		SELECT Top 5 pizza_name,
				COUNT(DISTINCT order_id) as top_ordered_pizza
		FROM project..pizza_sales
		Group By pizza_name
		Order by top_ordered_pizza DESC;


-- 16.  Bottom 5 Pizzas by Total Orders
		SELECT Top 5 pizza_name,
				COUNT(DISTINCT order_id) as bottom_ordered_pizza
		FROM project..pizza_sales
		Group By pizza_name
		Order by bottom_ordered_pizza ASC;

-- 17. Distribution of orders by hour of the day
		Select DatePart(Hour,order_time) as [Hours], 
			count(order_id) as total_order
		From project..pizza_sales
		Group By DATEPART(Hour, order_time)
		Order By [Hours];
	


-- 18. Group the orders by date and calculate the average number of pizzas ordered per day.

			With avg_pizza_ordered As(
				Select order_date ,
							sum(quantity) as pizza_ordered
				From project..pizza_sales
				Group by order_date
			)
			Select AVG(pizza_ordered)
			From avg_pizza_ordered;

-- 19. -- Analyze the cumulative revenue generated over time.
	
		Select order_date, revenue,
					sum(revenue)over(order by order_date) as cumulative_revenue
		From(
		Select order_date, Round(SUM(total_price),2) as revenue
		From project..pizza_sales
		Group By order_date
			) as revenue_table;

-- 20. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

		With top_sold_pizza As(
		Select *,
			Rank() over(Partition by pizza_category order by total_revenue DESC) as pizza_rank
				From(
			Select pizza_category, 
					pizza_name, 
					Round(SUM(total_price),2) as total_revenue
			From project..pizza_sales
			Group By pizza_category, pizza_name
		--Order by pizza_category, total_revenue DESC
			) As pizza
		)
		Select pizza_category, pizza_name, total_revenue
		From top_sold_pizza
		Where pizza_rank <=3;