SET SQL_SAFE_UPDATES = 0;


-- Module: Database Design and Introduction to SQL
-- Session: Database Creation in MySQL Workbench
-- DDL Statements

-- 1. Create a table shipping_mode_dimen having columns with their respective data types as the following:
--    (i) Ship_Mode VARCHAR(25)
--    (ii) Vehicle_Company VARCHAR(25)
--    (iii) Toll_Required BOOLEAN

-- 2. Make 'Ship_Mode' as the primary key in the above table.


-- -----------------------------------------------------------------------------------------------------------------
-- DML Statements

-- 1. Insert two rows in the table created above having the row-wise values:
--    (i)'DELIVERY TRUCK', 'Ashok Leyland', false
--    (ii)'REGULAR AIR', 'Air India', false

-- 2. The above entry has an error as land vehicles do require tolls to be paid. Update the ‘Toll_Required’ attribute
-- to ‘Yes’.

-- 3. Delete the entry for Air India.


-- -----------------------------------------------------------------------------------------------------------------
-- Adding and Deleting Columns

-- 1. Add another column named 'Vehicle_Number' and its data type to the created table. 

-- 2. Update its value to 'MH-05-R1234'.

-- 3. Delete the created column.


-- -----------------------------------------------------------------------------------------------------------------
-- Changing Column Names and Data Types

-- 1. Change the column name ‘Toll_Required’ to ‘Toll_Amount’. Also, change its data type to integer.

-- 2. The company decides that this additional table won’t be useful for data analysis. Remove it from the database.


-- -----------------------------------------------------------------------------------------------------------------
-- Session: Querying in SQL
use market_star_schema;
-- Basic SQL Queries

-- 1. Print the entire data of all the customers.
select * from cust_dimen;
-- 2. List the names of all the customers.

select customer_name from cust_dimen;

-- 3. Print the name of all customers along with their city and state.

select customer_name, city, state from cust_dimen;
-- 4. Print the total number of customers.
select count(cust_id) as Total_Customers
from cust_dimen;

-- 5. How many customers are from West Bengal?

select count(cust_id) as No_Bengal_Customer from cust_dimen
where state = 'West Bengal';

-- 6. Print the names of all customers who belong to West Bengal.

select customer_name from cust_dimen
where state = 'West Bengal';


-- -----------------------------------------------------------------------------------------------------------------
-- Operators

-- 1. Print the names of all customers who are either corporate or belong to Mumbai.

select customer_name, city, customer_segment from cust_dimen
where city = "Mumbai" or customer_segment = "Corporate";

-- 2. Print the names of all corporate customers from Mumbai.

select customer_name, city, customer_segment from cust_dimen
where city = "Mumbai" and customer_segment = "Corporate";

-- 3. List the details of all the customers from southern India: namely Tamil Nadu, Karnataka, Telangana and Kerala.

select * from cust_dimen
where state in ('Tamil Nadu', 'Karnataka', 'Telangana', 'Kerala');

-- 4. Print the details of all non-small-business customers.

select distinct Customer_Segment from cust_dimen;

select * from cust_dimen
where customer_segment != 'SMALL BUSINESS';
-- 5. List the order ids of all those orders which caused losses.

select ord_id from market_fact_full
where profit <= 0;


-- 6. List the orders with '_5' in their order ids and shipping costs between 10 and 15.

select ord_id, shipping_cost from market_fact_full
where ord_id like '%\_5%' and shipping_cost between 10 and 15;

-- -----------------------------------------------------------------------------------------------------------------
-- Aggregate Functions

-- 1. Find the total number of sales made.
use market_star_schema;
select count(sales) from market_fact_full;


-- 2. What are the total numbers of customers from each city?

select city, count(customer_name) from cust_dimen
group by city;


-- 3. Find the number of orders which have been sold at a loss.

select count(ord_id) from market_fact_full
where profit <0;

-- 4. Find the total number of customers from Bihar in each segment.

select customer_name, state, customer_segment from cust_dimen
where state = 'Bihar'
group by customer_segment;

-- 5. Find the customers who incurred a shipping cost of more than 50.


-- -----------------------------------------------------------------------------------------------------------------
-- Ordering

-- 1. List the customer names in alphabetical order.

use market_star_schema;

select distinct customer_name from cust_dimen
order by customer_name;

-- 2. Print the three most ordered products.

select prod_id, sum(order_quantity) from market_fact_full
group by prod_id
order by sum(order_quantity) desc
limit 3;

-- 3. Print the three least ordered products.

select prod_id, sum(order_quantity) from market_fact_full
group by prod_id
order by sum(order_quantity)
limit 3;


-- 4. Find the sales made by the five most profitable products.

select prod_id, round(sum(sales)), profit from market_fact_full
group by profit
order by profit desc
limit 5;

-- 5. Arrange the order ids in the order of their recency.



-- 6. Arrange all consumers from Coimbatore in alphabetical order.


-- -----------------------------------------------------------------------------------------------------------------
-- String and date-time functions

-- 1. Print the customer names in proper case.

select customer_name, concat(   
  upper(substring(substring_index(customer_name,' ',1),1,1)),   
  lower(substring(substring_index(customer_name,' ',1),2)) , ' ',
  upper(substring(substring_index(customer_name,' ',-1),1,1)),
  lower(substring(substring_index(customer_name,' ',-1),2)) 
) as Customer_Full_Name from cust_dimen;

-- 2. Print the product names in the following format: Category_Subcategory.

select concat(Product_Category, '_', Product_Sub_Category) as Product_Names from prod_dimen;

-- 3. In which month were the most orders shipped?

select count(ship_id) as Ship_Count, month(ship_date) as  Ship_Month from shipping_dimen
group by Ship_Month
order by Ship_Count desc
limit 1;

-- 4. Which month and year combination saw the most number of critical orders?

select count(ord_id) as Order_Count, month(Order_Date) as Order_Month, year(Order_Date) as Order_Year
from orders_dimen
where Order_Priority = "Critical"
group by Order_Year, Order_Month
order by Order_Count desc;

-- 5. Find the most commonly used mode of shipment in 2011.

select distinct ship_mode from shipping_dimen;

select ship_mode, count(ship_mode) from shipping_dimen
where year(ship_date) = 2011
group by ship_mode
order by count(ship_mode) desc;
-- -----------------------------------------------------------------------------------------------------------------
-- Regular Expressions

-- 1. Find the names of all customers having the substring 'car'.

select customer_name from cust_dimen
where customer_name regexp 'car';

-- 2. Print customer names starting with A, B, C or D and ending with 'er'.

select customer_name from cust_dimen
where customer_name regexp '^[abcd].*er$';
-- -----------------------------------------------------------------------------------------------------------------
-- Nested Queries

-- 1. Print the order number of the most valuable order by sales.

select ord_id, round(sales) as Rounded_Sales from market_fact_full
where Sales = (
select max(Sales) from market_fact_full
);

-- 2. Return the product categories and subcategories of all the products which don’t have details about the product
-- base margin.

select * from prod_dimen
where Prod_id in (
select Prod_id from market_fact_full
where Product_Base_Margin is null
);

-- 3. Print the name of the most frequent customer.

select customer_name, cust_id from cust_dimen
where Cust_id = (
select cust_id from market_fact_full
group by cust_id
order by count(cust_id) desc
limit 1
);



-- 4. Print the three most common products.

select Product_Category, Product_Sub_Category from prod_dimen
where Prod_id in (
select Prod_id from market_fact_full
group by Prod_id
order by count(Prod_id) desc
) limit 3;

-- -----------------------------------------------------------------------------------------------------------------
-- CTEs

-- 1. Find the 5 products which resulted in the least losses. Which product had the highest product base
-- margin among these?

select prod_id, profit, product_base_margin from market_fact_full
where profit <0
order by profit desc
limit 3;

with least_losses as (
select prod_id, profit, product_base_margin from market_fact_full
where profit <0
order by profit desc
) select * from least_losses
where Product_Base_Margin = (
select max(product_base_margin) from least_losses
);

-- 2. Find all low-priority orders made in the month of April. Out of them, how many were made in the first half of
-- the month?

select ord_id, order_date, order_priority from orders_dimen
where order_priority = 'Low' and month(order_date) =4;

with low_priority_orders as (
select ord_id, order_date, order_priority from orders_dimen
where order_priority = 'Low' and month(order_date) =4
) select count(ord_id) as Order_Count, order_date from low_priority_orders
where day(order_date) between 1 and 15;
-- -----------------------------------------------------------------------------------------------------------------
-- Views

-- 1. Create a view to display the sales amounts, the number of orders, profits made and the shipping costs of all
-- orders. Query it to return all orders which have a profit of greater than 1000.

create view order_info
as select ord_id, order_quantity, profit, shipping_cost from market_fact_full;

select ord_id, profit from order_info
where profit > 1000;

-- 2. Which year generated the highest profit?

create view market_fact_order
as select * from market_fact_full
inner join orders_dimen
using (ord_id);

select * from market_fact_order;

select sum(profit) as Year_wise_profit, year(order_date) as Order_Year
from market_fact_order
group by Order_Year
order by Year_wise_profit desc
limit 1;

-- -----------------------------------------------------------------------------------------------------------------
-- Session: Joins and Set Operations
-- Inner Join

-- 1. Print the product categories and subcategories along with the profits made for each order.

select Ord_id, Product_Category, Product_Sub_Category, Profit
from prod_dimen p inner join market_fact_full m
on p.prod_id = m.prod_id;

-- 2. Find the shipment date, mode and profit made for every single order.

select ord_id, profit, ship_date, ship_mode
from market_fact_full m inner join shipping_dimen s
on m.Ship_id = s.Ship_id;

-- 3. Print the shipment mode, profit made and product category for each product.

select m.prod_id, s.ship_mode, m.profit, p.product_category
from market_fact_full m inner join prod_dimen p on m.prod_id = p.prod_id
inner join shipping_dimen s on m.ship_id = s.ship_id;

-- 4. Which customer ordered the most number of products?

select customer_name, sum(order_quantity) as Total_Orders
from cust_dimen c inner join market_fact_full m
on c.cust_id = m.cust_id
group by customer_name
order by Total_Orders desc;

-- 5. Selling office supplies was more profitable in Delhi as compared to Patna. True or false?
use market_star_schema;
select Product_Category, sum(Profit) as Citywise_Profit, City
from prod_dimen p 
inner join market_fact_full m
on p.prod_id = m.prod_id 
inner join cust_dimen c
on m.cust_id = c.cust_id
where Product_Category = "Office Supplies" and (City = "Delhi" or City = "Patna")
group by City; 

-- 6. Print the name of the customer with the maximum number of orders.

select Customer_Name, sum(Customer_Name) as No_of_Orders
from cust_dimen c
inner join market_fact_full m
on c.cust_id = m.cust_id
group by Customer_Name
order by No_of_Orders desc
limit 1;


-- 7. Print the three most common products.

select Product_Category, Product_Sub_Category, Order_Quantity
from prod_dimen p
inner join market_fact_full m
on p.Prod_id = m.Prod_id
group by Product_Sub_Category
order by Order_Quantity
limit 3;
-- -----------------------------------------------------------------------------------------------------------------
-- Outer Join

-- 1. Return the order ids which are present in the market facts table.



-- Execute the below queries before solving the next question.
create table manu (
	Manu_Id int primary key,
	Manu_Name varchar(30),
	Manu_City varchar(30)
);

insert into manu values
(1, 'Navneet', 'Ahemdabad'),
(2, 'Wipro', 'Hyderabad'),
(3, 'Furlanco', 'Mumbai');

alter table Prod_Dimen
add column Manu_Id int;

update Prod_Dimen
set Manu_Id = 2
where Product_Category = 'technology';

-- 2. Display the products sold by all the manufacturers using both inner and outer joins.

select m.Manu_Name, p.Prod_id
from manu m 
inner join prod_dimen p 
on m.manu_id = p.manu_id;

select m.Manu_Name, p.Prod_id
from manu m 
left join prod_dimen p 
on m.manu_id = p.manu_id;

-- 3. Display the number of products sold by each manufacturer.

select m.Manu_Name, count(Prod_id)
from manu m 
inner join prod_dimen p 
on m.manu_id = p.manu_id
group by m.manu_name;

select m.Manu_Name, count(Prod_id)
from manu m 
left join prod_dimen p 
on m.manu_id = p.manu_id
group by m.manu_name;

-- 4. Create a view to display the customer names, segments, sales, product categories and
-- subcategories of all orders. Use it to print the names and segments of those customers who ordered more than 20
-- pens and art supplies products.

create view order_details
as select customer_name, customer_segment, round(sales), order_quantity, product_category, product_sub_category
from cust_dimen c 
inner join market_fact_full m 
on c.cust_id = m.cust_id
inner join prod_dimen p 
on m.prod_id = p.prod_id;

select * from order_details;

select customer_name, customer_segment, order_quantity, product_sub_category
from order_details
where order_quantity > 20 and product_sub_category = 'Pens & Art Supplies'
order by customer_name;



-- -----------------------------------------------------------------------------------------------------------------
-- Union, Union all, Intersect and Minus

-- 1. Combine the order numbers for orders and order ids for all shipments in a single column.


 

-- 2. Return non-duplicate order numbers from the orders and shipping tables in a single column.

-- 3. Find the shipment details of products with no information on the product base margin.

-- 4. What are the two most and the two least profitable products?

(select prod_id, sum(profit)
from market_fact_full
group by prod_id
order by sum(profit) desc
limit 2)
union
(select prod_id, sum(profit)
from market_fact_full
group by prod_id
order by sum(profit)
limit 2);


-- -----------------------------------------------------------------------------------------------------------------
-- Module: Advanced SQL
-- Session: Window Functions	
-- Window Functions in Detail

-- 1. Rank the orders made by Aaron Smayling in the decreasing order of the resulting sales.

-- 2. For the above customer, rank the orders in the increasing order of the discounts provided. Also display the
-- dense ranks.

-- 3. Rank the customers in the decreasing order of the number of orders placed.

-- 4. Create a ranking of the number of orders for each mode of shipment based on the months in which they were
-- shipped. 


-- -----------------------------------------------------------------------------------------------------------------
-- Named Windows

-- 1. Rank the orders in the increasing order of the shipping costs for all orders placed by Aaron Smayling. Also
-- display the row number for each order.


-- -----------------------------------------------------------------------------------------------------------------
-- Frames

-- 1. Calculate the month-wise moving average shipping costs of all orders shipped in the year 2011.


-- -----------------------------------------------------------------------------------------------------------------
-- Session: Programming Constructs in Stored Functions and Procedures
-- IF Statements

-- 1. Classify an order as 'Profitable' or 'Not Profitable'.


-- -----------------------------------------------------------------------------------------------------------------
-- CASE Statements

-- 1. Classify each market fact in the following ways:
--    Profits less than -500: Huge loss
--    Profits between -500 and 0: Bearable loss 
--    Profits between 0 and 500: Decent profit
--    Profits greater than 500: Great profit

-- 2. Classify the customers on the following criteria (TODO)
--    Top 20% of customers: Gold
--    Next 35% of customers: Silver
--    Next 45% of customers: Bronze


-- -----------------------------------------------------------------------------------------------------------------
-- Stored Functions

-- 1. Create and use a stored function to classify each market fact in the following ways:
--    Profits less than -500: Huge loss
--    Profits between -500 and 0: Bearable loss 
--    Profits between 0 and 500: Decent profit
--    Profits greater than 500: Great profit


-- -----------------------------------------------------------------------------------------------------------------
-- Stored Procedures

-- 1. Classify each market fact in the following ways:
--    Profits less than -500: Huge loss
--    Profits between -500 and 0: Bearable loss 
--    Profits between 0 and 500: Decent profit
--    Profits greater than 500: Great profit

-- The market facts with ids '1234', '5678' and '90' belong to which categories of profits?