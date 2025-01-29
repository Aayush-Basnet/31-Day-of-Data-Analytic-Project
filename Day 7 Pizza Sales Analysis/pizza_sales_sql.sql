
-- Retrieve the total number of orders placed.

SELECT 
    COUNT(*) AS total_orders
FROM
    pizzahut.orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(A.price * B.quantity), 2) AS total_revenue
FROM
    pizzas A
        JOIN
    order_details B ON A.pizza_id = B.pizza_id;


-- Identify the highest-priced pizza.

SELECT 
    B.name, A.price
FROM
    pizzas A
        JOIN
    pizza_types B ON A.pizza_type_id = B.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    A.size, COUNT(B.order_details_id) AS total_order
FROM
    pizzas A
        JOIN
    order_details B ON A.pizza_id = B.pizza_id
GROUP BY A.size
ORDER BY total_order DESC; 


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    B.name, SUM(C.quantity) AS total_ordered
FROM
    pizzas A
        JOIN
    pizza_types B ON A.pizza_type_id = B.pizza_type_id
        JOIN
    order_details C ON A.pizza_id = C.pizza_id
GROUP BY B.name
ORDER BY total_ordered DESC
LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    A.category, SUM(C.quantity) AS total_ordered
FROM
    pizza_types A 
        JOIN
    pizzas B ON A.pizza_type_id = B.pizza_type_id
        JOIN
    order_details C ON B.pizza_id = C.pizza_id
GROUP BY A.category
ORDER BY total_ordered DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS total_order
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
Select category, count(name)
from pizza_types
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
With avg_pizz_ordered as(
select A.order_date as Day, sum(B.quantity) as pizza_ordered
from orders A
join order_details B
on A.order_id = B.order_id
group by Day
)
Select Round(avg(pizza_ordered),0) as avg_ordered
From avg_pizz_ordered;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    C.name, ROUND(SUM(A.price * B.quantity), 2) AS total_revenue
FROM
    pizzas A
        JOIN
    order_details B ON A.pizza_id = B.pizza_id
        JOIN
    pizza_types C ON A.pizza_type_id = C.pizza_type_id
GROUP BY C.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
Select A.category, 
Round(sum(B.price * C.quantity) / (SELECT 
    ROUND(SUM(A.price * B.quantity), 2) AS total_revenue
FROM
    pizzas A
        JOIN
    order_details B ON A.pizza_id = B.pizza_id)*100,2) as revenue
From pizza_types A
Join pizzas B
On A.pizza_type_id = B.pizza_type_id
Join order_details C
on B.pizza_id = C.pizza_id
Group by A.category
order by revenue DESC;


-- Analyze the cumulative revenue generated over time.
select order_date, rev,
sum(rev) over(order by order_date) as cumulative_rev
From
(select orders.order_date,
Round(sum(pizzas.price * order_details.quantity),2) as rev
From orders 
Join order_details
on orders.order_id = order_details.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by orders.order_date) as rev_table;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

With most_ordered_pizza As(
Select category, name, total_rev,
Rank() over(partition by category order by total_rev DESC) as pizza_rank
From
(select pizza_types.category, pizza_types.name,
Round(sum(pizzas.price * order_details.quantity),2) as total_rev
from pizza_types
 join pizzas On pizza_types.pizza_type_id = pizzas.pizza_type_id
Join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name
order by pizza_types.category, total_rev DESC) as cat_table
)
Select category, name, total_rev
from most_ordered_pizza
where pizza_rank <= 3;

Select

