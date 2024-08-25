--create table df_orders(
--	[order_id] int primary key,
--	[order_date] date,
--	[ship_mode] varchar(20),
--	[segment] varchar(20),
--	[country] varchar(20),
--	[city] varchar(20),
--	[state] varchar(20),
--	[postal_code] varchar(20),
--	[region] varchar(20),
--	[category] varchar(20),
--	[sub_category] varchar(20),
--	[product_id] varchar(20),
--	[quantity] int,
--	[discount] decimal(7,2),
--	[sale_price] decimal (7,2),
--	[profit] decimal (7,2))

select * from df_orders

--Find top 10 highest revenue generating products
select top 10 product_id,sum(sale_price*quantity) as sales
from df_orders
group by product_id
order by sales desc

--Find top 5 highest selling products in each region
with cte as(
select region, product_id,sum(sale_price*quantity) as sales
from df_orders
group by region,product_id)
select * from(
select *,ROW_NUMBER() over(partition by region order by sales desc) as rnk
from cte) A
where rnk<=5

--Find month over month growth comparision for 2022 and 2023 sales, eg: jan 2022 vs jan 2023
with cte as (
select year(order_date)as order_year,month(order_date)as order_month,
sum(sale_price*quantity) as sales
from df_orders
group by 
year(order_date),month(order_date)
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

--For each category which month had the highest sales
with cte as(
select category,format(order_date,'yyyy-MM') as order_year_month,
sum(sale_price*quantity) as sales
from df_orders
group by category,format(order_date,'yyyy-MM')
)
select * from (
select *, ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte) a
where rn=1

--Which sub-category had highest growth by profit in 2023 compared to 2022
with cte as (
select sub_category,year(order_date)as order_year,
sum(profit*quantity) as Total_profit
from df_orders
group by sub_category,year(order_date)
), 
cte2 as(
select sub_category,
sum(case when order_year=2022 then Total_profit else 0 end) as profit_2022,
sum(case when order_year=2023 then Total_profit else 0 end) as profit_2023
from cte
group by sub_category)
select top 1 *
,(profit_2023-profit_2022)*100/profit_2022 as growth_percentage
from cte2
order by (profit_2023-profit_2022)*100/profit_2022 desc