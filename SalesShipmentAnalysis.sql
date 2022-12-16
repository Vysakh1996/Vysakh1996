create database custsupplier
select * from Inventory_Stock_Data
select * from Sales_Shipment_Data

select * from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]

--a. Data Audit: Calculate Below metrics	
--1. Number of rows 
select count(*) [No of Rows] from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]
--   Number of columns
select count(*) [No of Column] from INFORMATION_SCHEMA.COLUMNS where TABLE_CATALOG = 'custsupplier' and TABLE_NAME = 'Sales_Shipment_Data'

--2. Number of numerical & categorical columns


--b. Data Preparation:
--1. Creat new flag variable Late Delivery Risk based on Days for shipping (real) & Days for shipment (scheduled) (Flag=Not Late if shipment is not delayed and Flag=Late if shipment is delayed)									
 
select cast([Days for shipment (scheduled)] as int) [Scheduled Day for shipment], cast([Days for shipping (real)] as int) [Real Day for shipment], 
case when (cast([Days for shipment (scheduled)] as int)-cast([Days for shipping (real)] as int )) = 0 then 'not late' else 'late' end [Flag] 
from Sales_Shipment_Data

--c. List of Analysis:

--1. Caclulate high level metrics like, total sale value, total sale units, inventory value, inventory quantity, profit value,
--number of distinct products, number of distinct categories, number of distinct products etc									
 				
select sum(cast(Sales as float)) [Total Sale Value] , COUNT(cast(Sales as float)) [total sale unit],sum(cast([current stock] as float)) [Inventory Value],
COunt(cast([max order qty] as float)) [Inventory Quantity], sum(cast([Order Profit Per Order] as float)) [Profit Value], 
COUNT(distinct [Category Name])[No of distinct prod Catefory] from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]

--2. Status of orders (number of orders by current status)

select count([order-now]) from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]
where [order-now] = 'orange'

--3. Status of Delivery of orders (number of orders by each type of delivery status)
select [Delivery Status], count([Order Id])[No of Orders] from Sales_Shipment_Data
where [Delivery Status] in ('On time','Late','Advance','Canceled')
group by [Delivery Status]

--4. Late Delivery Risk by time (by each week, month, year, quarter)
select year([order date (DateOrders)])[Year], datepart(quarter,[order date (DateOrders)]) [Quarter], month([order date (DateOrders)]) [Month], datepart(week,[order date (DateOrders)]) [Week], count([Delivery Status])[Late] from Sales_Shipment_Data
where [Delivery Status]='Late'
group by year([order date (DateOrders)]),month([order date (DateOrders)]),datepart(quarter,[order date (DateOrders)]),datepart(week,[order date (DateOrders)])
order by [Year],[Quarter],[Month],[Week] 

--5. Order Item qty by time (by each week, month, year, quarter)
select year([order date (DateOrders)])[Year], datepart(quarter,[order date (DateOrders)]) [Quarter], month([order date (DateOrders)]) [Month], datepart(week,[order date (DateOrders)]) [Week], sum(cast([Order Item Quantity] as float))[Total Order Item Qty] from Sales_Shipment_Data
group by year([order date (DateOrders)]),month([order date (DateOrders)]),datepart(quarter,[order date (DateOrders)]),datepart(week,[order date (DateOrders)])
order by [Year],[Quarter],[Month],[Week]

--6. Sales units/value  by time (by each week, month, year, quarter)
select year([order date (DateOrders)])[Year], datepart(quarter,[order date (DateOrders)]) [Quarter], month([order date (DateOrders)]) [Month], datepart(week,[order date (DateOrders)]) [Week], sum(cast([Sales per customer] as float))  [Total Sales Value] from Sales_Shipment_Data
group by year([order date (DateOrders)]),month([order date (DateOrders)]),datepart(quarter,[order date (DateOrders)]),datepart(week,[order date (DateOrders)])
order by [Year],[Quarter],[Month],[Week]

--7. Profit orders/value  by time (by each week, month, year, quarter)
select year([order date (DateOrders)])[Year], datepart(quarter,[order date (DateOrders)]) [Quarter], month([order date (DateOrders)]) [Month], datepart(week,[order date (DateOrders)]) [Week], count([Order Profit Per Order]) [No of Profit Orders] from Sales_Shipment_Data
group by year([order date (DateOrders)]),month([order date (DateOrders)]),datepart(quarter,[order date (DateOrders)]),datepart(week,[order date (DateOrders)])
order by [Year],[Quarter],[Month],[Week]

--8. Order profit per order  by time (by each week, month, year, quarter)
select year([order date (DateOrders)])[Year], datepart(quarter,[order date (DateOrders)]) [Quarter], month([order date (DateOrders)]) [Month], datepart(week,[order date (DateOrders)]) [Week], sum(cast([Order Profit Per Order] as float))  [Total Order profit per order Value] from Sales_Shipment_Data
group by year([order date (DateOrders)]),month([order date (DateOrders)]),datepart(quarter,[order date (DateOrders)]),datepart(week,[order date (DateOrders)])
order by [Year],[Quarter],[Month],[Week]

--9. Order count by country/state/  by time (by each week, month, year, quarter)
select [Order Country],[Order State] ,year([order date (DateOrders)])[Year], datepart(quarter,[order date (DateOrders)]) [Quarter], month([order date (DateOrders)]) [Month], datepart(week,[order date (DateOrders)]) [Week], count([Order Id])  [No of Orders] from Sales_Shipment_Data
group by [Order Country],[Order State], year([order date (DateOrders)]),month([order date (DateOrders)]),datepart(quarter,[order date (DateOrders)]),datepart(week,[order date (DateOrders)])
order by [Year],[Quarter],[Month],[Week] 

--10. Inventory Units by each class or cluster
select Class, count(cast([safety stock] as float)) [Inventory Unit] from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]
group by Class

--11. Inventory Value by each class or cluster
select Class, sum(cast([safety stock] as float)) [Inventory Value] from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]
group by Class

--12. inventory by class
select Class, count(t2.[product name])[No of Products In Inventory] from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]
group by Class

--13. Detail Stock Action (products to be ordered, not required to ordered)
select count([order-now]) [Products Not Required to order] from Inventory_Stock_Data
where [order-now] = 'green'

select count([order-now]) [Products to be order] from Inventory_Stock_Data
where [order-now] = 'orange'

--14. Product Order qty trend  (by time (by each week, month, year, quarter))
select year([order date (DateOrders)])[Year], datepart(quarter,[order date (DateOrders)]) [Quarter], month([order date (DateOrders)]) [Month], datepart(week,[order date (DateOrders)]) [Week], sum(cast([Order Item Total] as float)) [Prod Order Qty] from Sales_Shipment_Data t1 left join Inventory_Stock_Data t2 on t1.[Product Id] = t2.[product id]
group by year([order date (DateOrders)]),month([order date (DateOrders)]),datepart(quarter,[order date (DateOrders)]),datepart(week,[order date (DateOrders)])
order by [Year],[Quarter],[Month],[Week]

--15. Top 10 Most ordered products/Top 10 Most Categories/Top 10 cities interms of revenue and sale units (quantity)
--a)Top 10 Ordered products
select top 10 [Product Name] , sum(cast([Order Profit Per Order] as float)) [Revenue] , sum(cast([Order Item Quantity] as float)) [Sale Units] from Sales_Shipment_Data
group by [Product Name]
order by [Revenue] desc , [Sale Units] desc 

--b)Top 10 Categories
select top 10 [Category Name] , sum(cast([Order Profit Per Order] as float)) [Revenue] , sum(cast([Order Item Quantity] as float)) [Sale Units] from Sales_Shipment_Data
group by [Category Name]
order by [Revenue] desc , [Sale Units] desc

--c)Top 10 Cities
select top 10 [Order City] , sum(cast([Order Profit Per Order] as float)) [Revenue] , sum(cast([Order Item Quantity] as float)) [Sale Units] from Sales_Shipment_Data
group by [Order City]
order by [Revenue] desc , [Sale Units] desc

--16. Top payment methods by each product category.
select [Type] , count([Category Name])[No of Payment] from Sales_Shipment_Data
group by [Type]
order by count([Category Name]) desc 

--17. Which shipping mode is more efficient interms of not delaying?
select [Shipping Mode],count([Delivery Status])[Qty Shipped] from Sales_Shipment_Data
group by [Shipping Mode]
order by count([Delivery Status]) desc

--18. Number of orders, sales, qty  by order status
select [Order Status], count([Order Id])[No of Orders],sum(cast(Sales as float))[Total Sales], sum(cast([Order Item Quantity] as float))[Total Qty] from Sales_Shipment_Data
group by [Order Status]

--19. Which categories are most profitable categories (top5)?
select top 5 [Category Name], sum(cast([Order Profit Per Order] as float)) [Profit] from Sales_Shipment_Data
group by [Category Name]
order by [Profit] desc

--20. Which categoires have been given highest average discount (top5)?
select top 5 [Category Name], avg(cast([Order Item Discount] as float))[highest avg discount] from Sales_Shipment_Data
group by [Category Name]
order by avg(cast([Order Item Discount] as float)) desc


