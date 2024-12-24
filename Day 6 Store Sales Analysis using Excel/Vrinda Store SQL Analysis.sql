
/*
Vrindra Store Report 2022

Objective													
Vrindra store wants to create an annual sales report for 2022. So that, Vrindra can understand their customers and grow more sales in 2023.													
*/

SELECT * 
	FROM project..Vrinda_Store;



SELECT COUNT(*) As total_dataset
FROM project..Vrinda_Store;
-- Dataset contain 31,407 number of rows



--------------------------------------------------------------------------------------------------------------
-- Checking Duplicate Values

SELECT *,
ROW_NUMBER() Over(Partition By [Index],[Order ID],[Cust ID],Gender,	Age,[Age Group],[Date],[Month],Status,Channel,
SKU,Category,Size,Qty,Currency,Amount,Ship_City,Ship_State,Ship_Postal_Code,Ship_Country,B2B
order by [Index]
) As row_num
FROM project..Vrinda_Store;


With CTE As 
(
SELECT *,
ROW_NUMBER() Over(Partition By [Index],[Order ID],[Cust ID],Gender,	Age,[Age Group],[Date],[Month],Status,Channel,
SKU,Category,Size,Qty,Currency,Amount,Ship_City,Ship_State,Ship_Postal_Code,Ship_Country,B2B
order by [Index]
) As row_num
FROM project..Vrinda_Store
)
Select * 
FROM CTE
Where row_num > 1;

-- There is no duplicate value. 

----------------------------------------------------------------------------------------------------------------------


				
-- 1. Which month got the highest sales and orders?	
		SELECT [Month], 
				sum(Amount) as total_sales, 
				count([Order ID]) as total_order
		From project..Vrinda_Store
		GROUP BY [Month]
		ORDER BY total_sales DESC, total_order DESC;
	-- Result:  March Month got the highest sales(1,928,066M) and orders(2819) followed by Feb, April, & Jan



-- 2. Who purchased more- men or women in 2022?		
		SELECT Gender,
			SUM(Amount) as total_Sales,
			 ROUND(
					(SUM([Amount]) /
						(SELECT SUM([Amount]) FROM project..Vrinda_Store) * 100), 2) AS Percentage_of_TotalSales_Gender
		FROM project..Vrinda_Store
		GROUP BY Gender;
	-- Result: Women dominated total sales (64.05%) compared to Men(35.95%)



-- 3 What are different order status in 2022?	

	SELECT Status,
    count([Order ID]) as total_orders,
    Round(
        (cast	
				(count([Order ID]) as float) / 
									 (SELECT cast(count([Order ID]) as float) FROM project..Vrinda_Store) * 100), 
			 2) As Percentage_of_OrderStatus
	FROM  project..Vrinda_Store
	GROUP BY Status
	ORDER BY Percentage_of_OrderStatus DESC;
	-- Result: Around 93% of orders are delivered which is positive sign for store.



-- 4. List top 10 states contributing to the sales?		
			SELECT Top 10 Ship_State,
					sum(Amount) as total_sales,
					Round(
					sum(Amount) /
							(SELECT sum(Amount) FROM project..Vrinda_Store)*100,2) as states_per_sales
			FROM project..Vrinda_Store
			GROUP BY Ship_State
			ORDER BY total_sales DESC;
	-- Result: Round 50% sales comes from 5 states: Maharashtra, Karnataka, Uttar Pradesh, Telangana & Tamil Nadu
	


-- 5. Relation between age and gender based on number of orders.	
	SELECT [Age Group],
			Gender,
			count([Order ID]) as total_orders,
			Round((cast(
						count([Order ID]) as float) / 
								(SELECT cast(count([Order ID]) as float) FROM project..Vrinda_Store) * 100), 
        2) As Percentage_of_OrderStatus
	FROM project..Vrinda_Store
	GROUP BY [Age Group], Gender;
	/* Result: Adult Women age between 30-50 contributed most in sales (~35%), followed by Young Women age between 18-29 by ~22%.
	 Top Buyer in term of Age_Group & Gender: Adult  Women, Young Women & Adult Men(~16%)			*/


-- 6. Which channel is contirbuting to maximum sales?		
	SELECT Channel,
			SUM(Amount) as total_Sales_Channel,
			Round((sum(Amount) /
						(SELECT sum(Amount) FROM project..Vrinda_Store) *100),2) as total_per_channel
	FROM project..Vrinda_Store
	GROUP BY Channel
	ORDER BY total_per_Channel DESC;
	-- Result: Around 80% sales comes from Amazon, Myntra & Flipkart.



-- 7. Highest selling category?					
		SELECT Category,
			sum(Amount) as total_Sales_Category,
			Round((sum(Amount) /
					(SELECT sum(Amount) FROM project..Vrinda_Store) *100),2) as total_per_Category,
			Count([Order ID]) as total_Order_Category
		FROM Project..Vrinda_Store
		GROUP BY Category
		ORDER BY total_Sales_Category DESC;
	-- Result: 50% sales comes from Set, followed by kurta ~24%.



-- 8. Filters the Top 2 Ranked category for each channel and sorts them by total sales.
	With top_channel_category As(
	SELECT *,
		Rank() over(Partition By Channel Order by total_Sales DESC) as channel_rank
		FROM (
			SELECT Channel, Category,
					SUM(Amount) as total_Sales,
					Round((sum(Amount) /
						(SELECT sum(Amount) FROM project..Vrinda_Store) *100),2) as total_per_Category
			FROM Project..Vrinda_Store
			GROUP BY Channel, Category) as a
	--Order by Channel, total_sales DESC;
	)
	SELECT Channel, Category, total_sales
	FROM top_channel_category
	WHERE channel_rank <3;
	-- Result: Set and Kurta are top ranked category for each channel.




