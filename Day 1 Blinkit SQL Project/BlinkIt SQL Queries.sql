Create Database BlinkIt;

# 1.Find the top 5 product that genrated high revenue? 
SELECT 
    ProductName,
    SUM(Quantity * PricePerUnit) AS Total_Generated_Revenue
FROM
    orderdetails
GROUP BY ProductName
ORDER BY Total_Generated_Revenue DESC
LIMIT 5;


# 2.Which city has placed the highest number of orders?
SELECT 
    C.City, COUNT(O.OrderID) AS Number_Of_Orders
FROM
    customers C
        JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.City
ORDER BY Number_Of_Orders DESC;


# 3.What is the total number of delivered and canceled orders?
SELECT 
    O.DeliveryStatus, COUNT(OD.OrderID) as order_count
FROM
    orders O
        JOIN
    orderdetails OD ON O.OrderID = OD.OrderID
GROUP BY O.DeliveryStatus;

# 4. Calculate the percentage of orders that were Delivered.
Select ((sum(case
			when DeliveryStatus = 'Delivered' Then 1
            else 0
            end))/count(*)) * 100 as DeliveredPercentage
From orders;

# 5.what is the total revenue generated
SELECT 
    SUM(TotalAmount) AS Total_Revenue
FROM
    orders;


# 6.Find the Top 5 city with the highest total revenue
  SELECT 
    C.City, SUM(O.TotalAmount) AS Highest_Total_Revenue
FROM
    Customers C
        JOIN
    orders O ON C.CustomerID = O.CustomerID
GROUP BY C.City
ORDER BY Highest_Total_Revenue DESC
LIMIT 5;
   
   
# 7.Identify customers who haven't placed any orders.
SELECT 
    C.CustomerID, C.Name
FROM
    customers C
        LEFT JOIN
    orders O ON C.CustomerID = O.CustomerID
        LEFT JOIN
    orderdetails OD ON O.OrderID = OD.OrderID
WHERE
    OD.OrderID IS NULL;



# 8.List all customers with their rank based on total spending
SELECT 
    C.CustomerID, C.Name, SUM(O.TotalAmount) Total_Spending,
    Rank() over(Order by sum(O.TotalAmount) DESC) as Customer_Spending_Rank
FROM
    customers C
        JOIN
    orders O ON C.CustomerID = O.CustomerID
GROUP BY 1,2;


# 9.List all customers with their rank based on total purchase 
SELECT 
    C.CustomerID,
    C.Name,
    SUM(OD.Quantity * OD.PricePerUnit) AS Total_Purchase,
    Rank() over(order by sum(OD.Quantity) DESC) As 'Rank'
FROM
    customers C
        JOIN
    orders O ON C.CustomerID = O.CustomerID
        JOIN
    orderdetails OD ON O.OrderID = OD.OrderID
GROUP BY 1 , 2;




# 10.Find customers who placed multiple orders on the same day.
SELECT 
    CustomerID, 
    DATE(OrderDateTime) as 'Date', 
    COUNT(orderID) as 'Orders'
FROM
    orders
GROUP BY 1 , 2
HAVING 3 > 1;


# 11.List the top 5 customers based on their totalPurchase 
With top_customers As(
SELECT 
    C.CustomerID,
    C.Name,
    SUM(OD.Quantity * OD.PricePerUnit) AS Total_Purchase
FROM
    customers C
        JOIN
    orders O ON C.CustomerID = O.CustomerID
        JOIN
    orderdetails OD ON O.OrderID = OD.OrderID
GROUP BY 1 , 2
ORDER BY 3 DESC
)
SELECT 
    Name, total_Purchase
FROM
    top_customers
LIMIT 5;




# 12. Find the average number of products per order, grouped by customer city.
With Avg_Count_Order As(
SELECT 
    O.OrderID, O.CustomerID, COUNT(OD.OrderID) as Order_Count
FROM
    orders O
        JOIN
    orderdetails OD ON O.OrderID = OD.OrderID
GROUP BY 1 , 2
) 
SELECT 
     C.City, 
     Round(avg(A.Order_Count),2) as avg_order
FROM
    Avg_Count_Order A
        JOIN
    customers C ON A.CustomerID = C.CustomerID
GROUP BY 1
ORDER BY avg_order DESC;


# 13.Calculate the percentage of total revenue contributed by each product category.
SELECT 
    ProductName,
    Round((SUM(Quantity * PricePerUnit) / (SELECT 
            SUM(Quantity * PricePerUnit)
        FROM
            orderdetails))*100,2) AS Total_Revenue
FROM
    orderdetails
GROUP BY ProductName
ORDER BY total_Revenue DESC;

