
#Basic Queries

	-- 1. List all unique cities where customers are located.
		Select distinct customer_city
        From customers;
        
        Select count(distinct customer_city)
        From customers;
        
	-- Customers are from 4119 different cities.


## 2. Count the number of orders placed in 2017.
		select count(order_id)
        from orders
        Where  year(order_purchase_timestamp) = 2017;
        
	-- There are 135303 orders in 2017.
    
    
## 3. Find the total sales per category.
	Select *
    from products;
    
    Select * 
    From order_items;
    
    Select * 
    From payments;
    
  SELECT 
    P.product_category,
    ROUND(SUM(Q.payment_value), 2) AS total_sales
FROM
    products P
        JOIN
    order_items O ON P.product_id = O.product_id
        JOIN
    payments Q ON Q.order_id = O.order_id
GROUP BY p.product_category
ORDER BY total_sales DESC;
    
    -- Top 3 product Categoroy are: bed table bath, Health beauty & computer accessories
    
-- 4. Calculate the percentage of orders that were paid in installments.
	Select 
		((Sum(Case
				When payment_installments >= 1 Then 1
                Else 0
                End)) / count(*)) * 100 as order_percentage
    From payments;

-- 99.9% of orders were paid in installments.



# Intermediate Queries

	# 1. Find the average number of products per order, grouped by customer city.
		With count_order as(
       SELECT 
    orders.order_id,
    orders.customer_id,
    COUNT(orders.order_id) AS ordered_count
FROM
    orders
        JOIN
    order_items ON orders.order_id = order_items.order_id
GROUP BY 1 , 2
        )
   SELECT 
    customers.customer_city,
    AVG(count_order.ordered_count) AS avg_order
FROM
    count_order
        JOIN
    customers ON count_order.customer_id = customers.customer_id
GROUP BY customers.customer_city
ORDER BY avg_order DESC;


	# 2. Calculate the percentage of total revenue contributed by each product category.
			SELECT 
    products.product_category,
    ROUND((SUM(payments.payment_value) / (SELECT 
                    SUM(payment_value)
                FROM
                    payments)) * 100,
            2) AS revenue_percentage
FROM
    products
        JOIN
    order_items ON products.product_id = order_items.product_id
        JOIN
    payments ON order_items.order_id = payments.order_id
GROUP BY products.product_category
ORDER BY revenue_percentage DESC;


# 3. Identify the correlation between product price and the number of times a product has been purchased.
		SELECT 
    products.product_category,
    COUNT(order_items.product_id) AS order_count,
    ROUND(AVG(order_items.price), 2) price
FROM
    products
        JOIN
    order_items ON products.product_id = order_items.product_id
GROUP BY products.product_category;


-- 4. Calculate the total revenue generated by each seller, and rank them by revenue.
	
    With top_seller As(
    SELECT 
    order_items.seller_id,
    ROUND(SUM(payments.payment_value), 2) total_revenue
FROM
    order_items
        JOIN
    payments ON order_items.order_id = payments.order_id
GROUP BY order_items.seller_id
    )
    Select *, 
		Rank()over(order by total_revenue DESC) as top_seller_rank
        From top_seller;
        
        
-- Identify the top 5 best-selling products on both revenue and quantity sold
SELECT 
    products.product_id,
    products.product_category,
    ROUND(SUM(order_items.price * order_items.order_item_id),
            2) AS total_revenue
FROM
    order_items
        JOIN
    products ON order_items.product_id = products.product_id
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 5;
    
    
  -- Most Loyal Customers
SELECT 
    customers.customer_id,
   -- customers.customer_unique_id,
    COUNT(orders.order_id) AS frequent_purchase,
    SUM(order_items.price * order_items.order_item_id) AS total_purchase
FROM
    customers
        JOIN
    orders ON customers.customer_id = orders.customer_id
        JOIN
    order_items ON orders.order_id = order_items.order_id
GROUP BY 1 
ORDER BY 2 DESC , 3 DESC;
    
    
-- Write a query to find the monthly sales trend for last two years
SELECT 
    DATE_FORMAT(O.order_purchase_timestamp, '%Y-%m') AS Month_Date,
    ROUND(SUM(P.payment_value), 2) AS montly_sales
FROM
    orders O
        JOIN
    payments P ON O.order_id = P.order_id
GROUP BY 1
ORDER BY 1 ASC;
    
    
  -- Analyze the seasonality of sales to identify peak month
 SELECT 
    YEAR(O.order_purchase_timestamp) AS Year,
    MONTH(O.order_purchase_timestamp) AS Month,
    ROUND(SUM(P.payment_value), 2) AS total_sales
FROM
    orders O
        JOIN
    payments P ON O.order_id = P.order_id
Where O.order_status = 'delivered'
GROUP BY 1 , 2
ORDER BY 1 , 2;
   
    # Advane Queries
    
    -- 1. Calculate the moving average of order values for each customer over their order history.
    Select customer_id,
		order_purchase_timestamp, payment,
        avg(payment) over (partition by customer_id order by order_purchase_timestamp rows between 2 preceding and current row) as moving_avg
    From(
    SELECT 
    orders.customer_id,
    orders.order_purchase_timestamp,
    payments.payment_value AS payment
FROM
    orders
        JOIN
    payments ON orders.order_id = payments.order_id) as A;
    
    
    
    
 -- 2. Calculate the cumulative sales per month for each month
 Select year, Month, total_sales,
		sum(total_sales) over(order by year, month) as cumulative_sales
 From(
SELECT 
    YEAR(orders.order_purchase_timestamp) AS year,
    MONTH(orders.order_purchase_timestamp) AS Month,
    ROUND(SUM(payments.payment_value), 2) AS total_sales
FROM
    orders
        JOIN
    payments ON orders.order_id = payments.order_id
GROUP BY 1 , 2
ORDER BY 1 , 2) As a;


-- 3. Calculate the year-over-year growth rate of total sales
With growth_rate As(
SELECT 
    YEAR(orders.order_purchase_timestamp) AS year,
    ROUND(SUM(payments.payment_value), 2) AS sales
FROM
    orders
        JOIN
    payments ON orders.order_id = payments.order_id
GROUP BY 1
) 
Select year, sales,
((sales - lag(sales,1) over(order by year)) / lag(sales,1) over(order by year)) * 100 as year_growth
From growth_rate;


-- 4. Identify the top 3 customers who spent the most money in each year.
With top_customers As(
Select *, 
	Rank() over(partition by year order by year, sales DESC) as cust_rank
From(
Select year(orders.order_purchase_timestamp) as year,
	orders.customer_id,
   sum(payments.payment_value) as sales
From orders
join payments
on orders.order_id = payments.order_id
group by 1,2) As a
)
SELECT 
    *
FROM
    top_customers
WHERE
    cust_rank <= 3;

-- Write a query to calculate the total revenue per-category, sub-category and region
	SELECT 
    products.product_category,
    customers.customer_state AS region,
    ROUND(SUM(payments.payment_value), 2) AS Total_Revenue
FROM
    order_items
        JOIN
    products ON order_items.product_id = products.product_id
        JOIN
    orders ON order_items.order_id = orders.order_id
        JOIN
    customers ON orders.customer_id = customers.customer_id
        JOIN
    payments ON orders.order_id = payments.order_id
GROUP BY 1 , 2;


-- Analyze delivery performancy by calculating the average delivery time by region
select *
From orders;

with delivery_status AS(
SELECT 
    customer_id,
    DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp) AS delivery_time
FROM
    orders
WHERE
    order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
)
SELECT 
    customers.customer_state,
    AVG(delivery_status.delivery_time) AS avg_del_time
FROM
    delivery_status
        JOIN
    customers ON delivery_status.customer_id = customers.customer_id
GROUP BY customers.customer_state
ORDER BY avg_del_time ASC;


-- Regions with the highest canceled rate
select order_status,count(*)
From orders
group by 1;

SELECT 
    C.customer_state,
    COUNT(CASE
        WHEN O.order_status = 'canceled' THEN 1
    END) * 100 / COUNT(*) AS canceled_rate
FROM
    customers C
        JOIN
    orders O ON C.customer_id = O.customer_id
Group by C.customer_state
Order by canceled_rate DESC
