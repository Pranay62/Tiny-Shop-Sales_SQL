select * from customers;
select * from products;
select * from orders;
select * from order_items;

-- Case Study Questions

--1) Which product has the highest price? Only return a single row.

select Top 1 * from products  order by price desc



--2) Which customer has made the most orders?

with cte as (
select customer_id ,count(order_id) as number_of_order, dense_rank() over(order by count(order_id) desc) as rn from orders group by customer_id
)
select customer_id from cte where rn =1



--3) What’s the total revenue per product?

select p.product_id,p.product_name, p.price*o.quantity_of_product as total_revenue from products p inner join
(select product_id,sum(quantity) as quantity_of_product from order_items 
group by product_id ) o
on o.product_id = p.product_id




--4) Find the day with the highest revenue.

with cte as
(select oi.order_id,o.order_date,p.price*oi.quantity as revenue ,
dense_rank() over(order by p.price*oi.quantity desc) as rn
from order_items oi inner join orders o on o.order_id = oi.order_id
inner join products p on p.product_id = oi.product_id
)
select order_id,order_date,revenue from cte where rn =1




--5) Find the first order (by date) for each customer.

select customer_id , min(order_date) as first_order_date from orders group by customer_id order by customer_id




--6) Find the top 3 customers who have ordered the most distinct products


with cte as
(select  o.customer_id,count(distinct oi.product_id) as count ,
row_number() over(order by count(distinct oi.product_id) desc) as rn
from order_items oi left join orders o 
on o.order_id =oi.order_id 
group by o.customer_id
)
select customer_id from cte where rn in (1,2,3)





--7) Which product has been bought the least in terms of quantity?


with cte as
(select product_id , sum(quantity) as count , dense_rank() over(order by sum(quantity)) as rn 
from order_items 
group by product_id)
select product_id,count from cte where rn =1




--8) What is the median order total?

WITH revenue AS (
    SELECT p.price * o.quantity_of_product AS total_revenue
    FROM products p
    INNER JOIN (
        SELECT product_id, SUM(quantity) AS quantity_of_product
        FROM order_items
        GROUP BY product_id
    ) o ON o.product_id = p.product_id
)
SELECT
    AVG(total_revenue) AS median_revenue
FROM (
    SELECT total_revenue,
           ROW_NUMBER() OVER (ORDER BY total_revenue) AS row_number,
           COUNT(*) OVER () AS total_rows
    FROM revenue
) subquery
WHERE row_number IN ((total_rows + 1) / 2, (total_rows + 2) / 2);




--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

select oi.order_id , sum(oi.quantity*p.price) as revenue ,
case when sum(oi.quantity*p.price) > 300 then 'Expensive'
when sum(oi.quantity*p.price) < 100 then 'Cheap' else 'Affordable' end as Type
from order_items oi left join products p 
on p.product_id = oi.product_id 
group by oi.order_id 
order by  oi.order_id




--10) Find customers who have ordered the product with the highest price.


with cte as
(select c.customer_id,c.first_name,c.last_name,p.price*oi.quantity as total_price,
dense_rank() over(order by p.price*oi.quantity desc) as rn
from order_items oi inner join orders o on o.order_id = oi.order_id
inner join products p on p.product_id = oi.product_id
inner join customers c on c.customer_id =  o.customer_id)
select * from cte where rn = 1