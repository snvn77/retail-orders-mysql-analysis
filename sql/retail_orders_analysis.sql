Create DATABASE data_analysis; -- Creating a new database for this project
Use data_analysis; -- This ensures that all further queries are from this db
 
Create TABLE DAproject (
	order_id int primary key,
	order_date date,
	ship_mode varchar(20),
	segment varchar(20),
	country varchar(20),
	city varchar(20),
	state varchar(20),
	postal_code varchar(20),
	region varchar(20),
	category varchar(20),
	sub_category varchar(20),
	product_id varchar(50),
	quantity int,
	discount decimal(7,2),
	sale_price decimal(7,2),
	profit decimal(7,2)
); -- Created empty table as creating directly from python shall create a table with datatypes that take max storage


Select * From daproject1; -- Directly created from python

Select * From daproject1; -- Replaced from python

Select * From daproject; -- Created empty table here and then appended from python


-- Query 1: Find top 10 highest revenue generating products
Select product_id, Sum(sale_price*quantity) as revenue
From daproject
Group by product_id
Order by revenue desc
Limit 10; -- revenue = sale_price*quantity

-- Query 2: Find top 5 highest selling products in each region
Select t2.*
From (Select t1.*, row_number() over(partition by t1.region order by t1.total_sales desc) as rn
	  From (Select region, product_id, Sum(sale_price*quantity) as total_sales
			From daproject
			Group by region, product_id) t1) t2
Where rn<=5; -- Assuming highest selling is highest sales/revenue

-- Query 3: Find month over month growth comparison for 2022 and 2023 sales (eg: jan 2022 vs jan 2023)
Select month(order_date) as month, 
	   Sum(Case when year(order_date)=2022 then (sale_price*quantity) else 0 end) as 2022_sales,
       Sum(Case when year(order_date)=2023 then (sale_price*quantity) else 0 end) as 2023_sales
From daproject
Group by month
Order by month; -- Assuming it is for overall sales of all products

-- Query 4: For each category, which month had highest sales
Select t2.*
From(Select t1.*, row_number() Over(Partition by t1.category, t1.yearmonth order by t1.total_sales desc) as rn 
	 From(Select category, date_format(order_date,'%Y%m') as yearmonth, Sum(sale_price*quantity) as total_sales
		  From daproject
		  Group by category, yearmonth) t1) t2
Where rn=1; -- Assuming sales here as revenue

-- Query 5: which sub category had highest growth by profit in 2023 compared to 2022
Select t1.*, (t1.profit_2023 - t1.profit_2022)*100/t1.profit_2022 as growth
From (Select sub_category, 
			 Sum(Case when year(order_date)=2022 then (profit*quantity) else 0 end) as profit_2022,
			 Sum(Case when year(order_date)=2023 then (profit*quantity) else 0 end) as profit_2023
	  From daproject
	  Group by sub_category) t1
Order by growth desc
limit 1; -- Assuming it is profit growth percent