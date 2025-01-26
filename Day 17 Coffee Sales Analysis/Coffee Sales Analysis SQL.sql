/*
Coffee Sales Analysis 
The goal of analyzing transaction data is to get important insights regarding customer behavior,
product popularity, sales patterns, and operational efficiencies. The purpose is to optimize 
inventory management, improve decision-making processes, and find possible cross-selling opportunities.

Project Task:
	- Data collection, cleaning, and preparation
	- Analyse monthly, daily, and hourly sales patterns with Power PivotTables.
	- Determine high-performing days and times.
	- Develop compelling reports and visualization
	- Create an Interactive dashboard

Tools used:
	- Excel
	- Power BI
	- MS SQL
*/
Select * 
From project..Coffee_Sales;

Alter Table project..Coffee_Sales
Drop Column Product_detail;



Select sum(Total_Bill) as Total_Sale,
	sum(Transaction_qty) as Quantity_sold,
	COUNT(Transaction_qty) as No_of_Transaction
From project..Coffee_Sales;
/*
Total Sales: $698,812.22
Total Quantity Sold: 214,470 units
Total Transactions: 149,116
*/

-- Find the total Sales per Product Category, Product Type, & product
	Select Product_Category,
			SUM(Total_Bill) as Total_Sales_Category
	from project..Coffee_Sales
	Group By Product_Category
	order by Total_Sales_Category DESC;


		Select Product_type,
			SUM(Total_Bill) as Total_Sales_type
	from project..Coffee_Sales
	Group By Product_type
	order by Total_Sales_type DESC;


		Select Product_details,
			SUM(Total_Bill) as Total_Sales_details
	from project..Coffee_Sales
	Group By Product_details
	order by Total_Sales_details DESC;



-- Sales by Store and Product Size

	Select Store_Location,
			SUM(Total_Bill) as Total_Sale_Store,
  (SUM(Total_Bill) / (Select sum(Total_Bill) From project..Coffee_Sales)) * 100 As Sales_Contribution
			From project..Coffee_Sales
			Group By Store_Location
			Order By Total_Sale_Store DESC;
		-- Output: Lower Manhattan shows fewer sales than other stores.

	Select Size,
			SUM(Total_Bill) as Total_Sale_Size,
			Round((SUM(Total_Bill) / (Select SUM(Total_Bill) from project..Coffee_Sales)) * 100,2) as Sales_Size_Contribution
	From project..Coffee_Sales
	Group by Size
	Order by Total_Sale_Size DESC;
	-- Output: Small size product is the least sold product with 6.64% contribution in sales.



-- Monthly Sales
	
	Select Month,
		Case
			When Month = 'Jan' Then 1
			When Month = 'Feb' Then 2
			When Month = 'Mar' Then 3
			When Month = 'Apr' Then 4
			When Month = 'May' Then 5
			When Month = 'Jun' Then 6
		Else Month
		End As Month_Number
	From project..Coffee_Sales;


	Alter Table project..Coffee_Sales
	Add Month_Number int;

	Update project..Coffee_Sales
	Set Month_Number = Case
			When Month = 'Jan' Then 1
			When Month = 'Feb' Then 2
			When Month = 'Mar' Then 3
			When Month = 'Apr' Then 4
			When Month = 'May' Then 5
			When Month = 'Jun' Then 6
		Else Month
		End;


	Select Month, Month_Number,
		SUM(Total_Bill) as Monthly_Sale
	From project..Coffee_Sales
	Group by Month, Month_Number
	Order by Month_Number;


	-- Calculate the cumulative sales per month for each month

	Select Month,Month_Number,Monthly_Sales,
	sum(Monthly_Sales) over(Order by Month_Number) as cumulative_sales
	from (
	Select Month, Month_Number,
		SUM(Total_Bill) as Monthly_Sales
	From project..Coffee_Sales
	Group by Month, Month_Number
	-- Order by Month_Number
	) A;


-- Day Performance over 6 months
	Select Day, Day_Number,
		Sum(Total_Bill) as Day_Sales
	From project..Coffee_Sales
	Group by Day, Day_Number
	Order by Day_Number 

		-- Output: Monday, Thursday, and Friday have been noted as high transaction days, reflecting greater customer engagement on these days.


		-- I want to see each day performance for all months. Rank Day based on sales performance
	Alter Table project..Coffee_Sales
	Add Day_Number int;

	Update project..Coffee_Sales
	Set Day_Number = Case
			When Day = 'Sun' Then 1
			When Day = 'Mon' Then 2
			When Day = 'Tue' Then 3
			When Day = 'Wed' Then 4
			When Day = 'Thu' Then 5
			When Day = 'Fri' Then 6
			When Day = 'Sat' Then 7
		Else Day
		End;

		
	With top_day_montly As(
	Select Month, Month_Number,
	Day, Day_Number,
	SUM(Total_Bill) as Sales_recorded
	From project..Coffee_Sales
	Group by Month, Month_Number,Day, Day_Number
	--Order by Month_Number, Day_Number ASC
	)
	Select *,
	Rank() over(Partition by Month,Month_Number order By Sales_recorded DESC) as rank_in_sales
	From top_day_montly
	Order by Month_Number, Day_Number
	

-- Hourly Performance

Select DATEPART(HOUR, Transaction_time) AS Hour_Time,
	sum(Total_Bill) as total_sale,
	sum(Transaction_qty) as qty_sale
	From project..Coffee_Sales
	Group by DATEPART(HOUR, Transaction_time)
	Order by DATEPART(HOUR, Transaction_time);

  -- Output: Most transactions occur between 8:00 a.m. and 10:00 a.m., showing a morning sales peak.



 /*
Key Takeaways:
	Top Sellers: Coffee leads with 25% of total sales, followed by Bakery and Tea.
	Store Performance: Our Astoria and Hell’s Kitchen locations are top performers, each contributing 
						over 34% of total sales.
	Monthly Trends: We find the steady growth in each monthly continuously increasing their sales.
	Customer Habits: Peak sales times are between 8 AM and 11 AM on weekdays, aligning with the morning coffee rush.
	Product Trends: Coffee beans and branded products saw the highest month-on-month growth, while sustainably grown coffee remains our top-seller.
 

Conclusion:
  Peak transaction times, high-performing days, and areas for improvement are identified. By leveraging these findings,
  you can enhance customer experiences, refine inventory management, and boost overall sales efficiency for a 
  thriving coffee shop venture.
 */