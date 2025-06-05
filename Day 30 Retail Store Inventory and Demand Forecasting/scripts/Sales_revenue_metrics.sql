/*
======================================= Sales and Revenue Metrics ====================================
	1. Total Units Sold per Product, Category, or Store
	2. Total Revenue
	3. Average Price per Category or Product
	4. Total Discounts Given

	Purpose:
		1. Measuring Sales Effectiveness
		2. Identifying Strengths and Weaknesses
		3. Forecasting and Planning

	SQL Function used:
	- Aggregate Functions: SUM(), AVG(), COUNT()
    - GROUP BY, ORDER BY

Sales and revenue metrics are vital for understanding how well a company generates income, 
managing sales operations effectively, and driving sustainable business growth.
==========================================================================================================
*/



-- Find the sales distribition among products
SELECT 
	Product_ID,
	ROUND(SUM(Units_Sold),2) as total_unit_sold,
	ROUND(AVG(Price),2) AS avg_price,
	ROUND(SUM(Revenue),2) as total_revenue
FROM Sales_Database..sales_data
GROUP BY Product_ID
ORDER BY avg_price DESC;

/* === Output
	- Product 007 is the most sold product, followed by P004, P009, & P0013, with total unit sold of around 378K
	- None of the most sold product lies on top 5 of highest revenue generating product.
	- P0014 has generated INR 37M (avg_price: 118.6), where maximum product belong to Furniture category (we'll discussed it later)
	- P0014, P0011, P0012, P0020, P009 are top 5 highest revenue generating product.
*/



-- Find the total product,total units sold and total revenue per category
SELECT 
	Category,
	COUNT(DISTINCT Product_ID) as total_product,
	ROUND(SUM(Units_Sold),2) as total_unit_sold,
	ROUND(SUM(Revenue),2) as total_revenue
FROM Sales_Database..sales_data
GROUP BY Category
ORDER BY total_revenue DESC;

/* ==== Output
	- Groceries and Clothing leads in total unit sold with 3,127,335 & 1,150,873 units sold generating total revenue
	  of INR 168,864,492 and INR 85,200,607 respectively.
	- While Groceries has highest revenue, followed by Furniture with 880,654 unit sold generating INR 111,283,574
	- Electornic saw lowest sell in units and Toys generated lowest revenue from category sector.
*/



-- Total units sold per store
SELECT 
	Store_ID,
	ROUND(SUM(Units_Sold),2) as total_unit_sold,
	ROUND(SUM(Revenue),2) as total_revenue
FROM Sales_Database..sales_data
GROUP BY Store_ID
ORDER BY total_revenue;

/* ==== Output
	- Unit sold range between 138K - 131K between stores. Meanwhile S003 generated highest revenue of INR 98M,
	  followed by S004 generating INR 94M in revenue
*/



-- Find the total revenue, unit sold and discount given
SELECT 
		ROUND(SUM(Revenue),2) as total_revenue,
		SUM(Units_Sold) as total_unit_sold,
		SUM(Discount) as total_discount_given
FROM Sales_Database..sales_data;

/* === Output
	- Store has generated INR 455M in revenue, selling 6M+ product providing only INR 690K in discount.
*/


-- What is the average price per category
SELECT 
		Category,
		ROUND(AVG(Price),2) as avg_price,
		ROUND(SUM(Revenue),2) as total_revenue
FROM Sales_Database..sales_data
GROUP BY Category
ORDER BY avg_price DESC;
/* === Output
As expected Furniture has highest avg price of 121.51, which leads to answer of although with least product sold, Furniture is
second highest revenue generator.
*/

/*
===================================================Summary Report======================================================================

Electronics show the most potential for growth due to their low product count and sales. Focused efforts on assortment expansion, marketing,
and customer engagement can help unlock this category’s potential and increase overall revenue contribution.

Recommendations for Improvement: Electronics (Least-Explored Category)
1. Expand Product Range: Consider adding more SKUs to attract a wider audience and meet diverse customer needs.
2. Improve Visibility: Increase the visibility of electronics through website banners, featured listings, or special events (e.g., electronics week).
3. Cross-Selling: Bundle electronics with complementary categories (e.g., electronics with toys or furniture) to increase average order value.
*/

