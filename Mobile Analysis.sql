--SQL Advance Case Study


--Q1--BEGIN 
	
	/*1.	List all the states in which we have customers who have bought cellphones 
	from 2005 till */

SELECT [State]
from FACT_TRANSACTIONS as T
inner join DIM_LOCATION as L    
on T.IDLocation = L.IDLocation
inner join DIM_MODEL as M 
on T.IDModel = M.IDModel
where [date] between '2005-01-01' and getdate()



--Q1--END

--Q2--BEGIN
	--What state in the US is buying more 'Samsung' cell phones?
	select top 1 State  
	from DIM_LOCATION as L
	inner join FACT_TRANSACTIONS as T on L.IDLocation = T.IDLocation
	inner join DIM_MODEL as M on T.IDModel = M.IDModel
	inner join DIM_MANUFACTURER as MR on M.IDManufacturer = MR.IDManufacturer
    where Manufacturer_Name = 'Samsung'
	group by State
	order by sum(Quantity) desc











--Q2--END

--Q3--BEGIN      
	--Show the number of transactions for each model per zip code per state.
	select [Model_Name],[State] ,ZipCode, count(IDCustomer) as Transactions_
	from FACT_TRANSACTIONS as T
	inner join DIM_LOCATION as L
	
	on T.IDLocation = L.IDLocation
	inner join DIM_MODEL as M       
	on T.IDModel = M.IDModel
	group by Model_Name,[State], ZipCode










--Q3--END

--Q4--BEGIN
--4.	Show the cheapest cellphone
select  top 1 IDModel,Model_Name from 
DIM_MODEL
order by unit_price desc







--Q4--END

--Q5--BEGIN
/*Find out the average price for each model in the top5 manufacturers in 
	terms of sales quantity and order by average price.*/
	select M.IDModel,avg(Unit_price) as AVG_Price
	from DIM_MODEL as M
	inner join DIM_MANUFACTURER as MR  
	on M.IDModel =M.IDModel
	where Manufacturer_name in (select  top 5 Manufacturer_Name from DIM_MODEL as M 
	                            inner join FACT_TRANSACTIONS  as T on 
		                        M.IDModel = T.IDModel
		                        inner join DIM_MANUFACTURER as MR
		                        on M.IDManufacturer = MR.IDManufacturer
	                            group by Manufacturer_Name
		                        order by sum(Quantity) desc)
  group by M.IDModel
  order by AVG(Unit_price) desc









--Q5--END

--Q6--BEGIN
/*List the names of the customers and the average amount spent in 2009, 
	where the average is higher than 500*/
	select Customer_Name , Avg(TotalPrice) as Spending 
	from DIM_CUSTOMER as C
	left join FACT_TRANSACTIONS as T
	on C.IDCustomer = T.IDCustomer
	where year(Date) = '2009'
	group by Customer_Name
	having avg(totalprice) > '500'












--Q6--END
	
--Q7--BEGIN  
	/*List if there is any model that was in the top 5 in terms of quantity, 
	simultaneously in 2008, 2009 and 2010*/

	select Model_Name from (
select   top 5 Model_Name , sum(quantity) as quantity_sold  from DIM_MODEL as M
inner join  FACT_TRANSACTIONS as T
on M.IDModel = T.IDModel
where year(date) =2008
group by Model_Name
order by quantity_sold desc) as x
intersect
select Model_Name from (
select   top 5 Model_Name , sum(quantity) as quantity_sold  from DIM_MODEL as M
inner join  FACT_TRANSACTIONS as T
on M.IDModel = T.IDModel
where year(date) =2009
group by Model_Name
order by quantity_sold desc) as y
intersect
select Model_Name from (
select   top 5 Model_Name , sum(quantity) as quantity_sold  from DIM_MODEL M 
inner join  FACT_TRANSACTIONS T
on M.IDModel = T.IDModel
where year(date) =2010
group by Model_Name
order by quantity_sold desc) as z

																																																																																																																											















--Q7--END	
--Q8--BEGIN
/*Show the manufacturer with the 2nd top sales in the year of 2009 and the 
	manufacturer with the 2nd top sales in the year of 2010.*/
	select Manufacturer_Name,sum(TotalPrice) as Revenue
	from FACT_TRANSACTIONS as T
	inner join DIM_MODEL as M
	on T.IDModel = M.IDModel
	inner join DIM_MANUFACTURER as MR
    on M.IDManufacturer = MR.IDManufacturer
	where year(Date) = '2009'
	group by Manufacturer_Name
	order by sum(TotalPrice) desc

















--Q8--END
--Q9--BEGIN
	--Show the manufacturers that sold cellphone in 2010 but didn’t in 2009.

	select Manufacturer_Name 
	from FACT_TRANSACTIONS as T
	inner join DIM_MODEL as  ML
	on T.IDModel = ML.IDModel
	inner join DIM_MANUFACTURER as M
	on ML.IDManufacturer   = M.IDManufacturer   
	where year(Date) = '2010'
	Except
	select Manufacturer_Name
	from FACT_TRANSACTIONS as T
	inner join DIM_MODEL as  ML
	on T.IDModel = ML.IDModel
	inner join DIM_MANUFACTURER as M
	on ML.IDManufacturer   = M.IDManufacturer   
	where year(Date) = '2009'
	
	
	















--Q9--END

--Q10--BEGIN
	/*Find top 100 customers and their average spend, average quantity by each year.
	Also find the percentage of change in their spend.*/
	


	select   top 5 Model_Name , sum(quantity) as quantity_sold  from DIM_MODEL a 
inner join  FACT_TRANSACTIONS b
on a.IDModel = b.IDModel
where year(date) =2009
group by Model_Name
order by quantity_sold desc















--Q10--END
select   x.Customer_Name, avg(x.Sp) avg_sp , count(YR)
from
(
select  Customer_Name,(T.TotalPrice * T.Quantity) as Sp ,YEAR(DATE) as YR
from DIM_CUSTOMER as C
inner join FACT_TRANSACTIONS as t
on C.IDCustomer = t.IDCustomer
order by (T.TotalPrice * T.Quantity) desc
) as x
group by x.Customer_Name  