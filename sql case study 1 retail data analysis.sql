select *from Customer
select *from prod_cat_info
select *from Transactions

--Q.1 what is the total number of rows in each of the 3 tables in the database?
	select 'customer_table' as Table_Name, count(*) as Nuber_of_Rows from customer  
	union all
	select 'Product_table', count(*) from prod_cat_info
	union all
	select 'transaction', count(*) from Transactions 

--Q.2 What is the total number of transactions that have a return
	select count(*) totalorder_return from Transactions
	where rate  < 0
	

--Q.3  3.As you would have noticed, the dates provided across the datasets are not in a correct format. 
--As first steps, pls convert the date variables into valid date formats before proceeding ahead.
    select tran_date,  convert(date,tran_date) as convert_date
	from Transactions

--Q.4 --What is the time range of the transaction data available for analysis? 
 ---Show the output in number of days, months and years simultaneously in different columns.
 select Max(CAST(tran_date as date)) as Max_date,
 min(cast(tran_date as date )) as MIn_date,
 datediff(day,MIN(cast(tran_date as date)),MAX(cast(tran_date as date))) as Day_diff,
 datediff(MONTH,MIN(cast(tran_date as date)),MAX(cast(tran_date as date))) as MONTH_Diff,
 datediff(year,MIN(cast(tran_date as date)),MAX(cast(tran_date as date))) as Year_diff
 from Transactions


	

--5.Which product category does the sub-category “DIY” belong to?
select  prod_cat ,prod_subcat
from prod_cat_info 
where prod_subcat  = 'DIY'


-----DATA___ANALYSIS
--1.Which channel is most frequently used for transactions?
select top 1 Store_type ,count(transaction_id) as TOTAL_TRANSACTION from Transactions
group by Store_type
order by TOTAL_TRANSACTION desc




--2.What is the count of Male and Female customers in the database?
select  gender,count(gender) as Total_population
from customer
where gender in ('M','F')
group by Gender


--3.From which city do we have the maximum number of customers and how many?
select top 1 city_code , count(customer_id) as NUMBER_OF_CUSTOMER from Customer
group by city_code
order by count(customer_id) desc


--4.How many sub-categories are there under the Books category?
select  prod_cat,count(prod_subcat) as count_subcategory 
from prod_cat_info
where prod_cat ='Books'
group by prod_cat

--5.What is the maximum quantity of products ever ordered?

select top 1 b.prod_cat , count(b.prod_cat_code) as TOTAL_ORDER 
from Transactions a
inner join  prod_cat_info b
on a.prod_cat_code = b. prod_cat_code
and a.prod_subcat_code =b. prod_sub_cat_code
where qty > 0
group by b.prod_cat, b.prod_cat_code
order by TOTAL_ORDER desc



---6.What is the net total revenue generated in categories Electronics and Books?
select sum(Total_Revenue) as Total_Revenue
from (select b.prod_cat,sum(a.total_amt) as Total_Revenue
from Transactions a
inner join prod_cat_info b
on a.prod_cat_code = b.prod_cat_code
and a.prod_subcat_code = b.prod_sub_cat_code
where b.prod_cat in ('Electronics','books')
group by b.prod_cat) as x

--7.How many customers have >10 transactions with us, excluding returns?
select count(*) as Total_Number_Of_Customer from (select  a.customer_id , count(transaction_id) as Total_NUMBER_OF_CUSTOMERS 
from customer as a
inner join transactions b
on a.customer_ID = b.cust_id
where total_amt > 0
group by customer_id
having  count(transaction_id) > 10) as X

--8.What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?
select cast(sum(total_revenue) As float) as Combined_Revenue_From_Electronics_and_Clothings from (select b.prod_cat,sum(a.total_amt) as TOTAL_REVENUE 
from Transactions a
inner join prod_cat_info b
on a.prod_cat_code = b.prod_cat_code
and a.prod_subcat_code = b.prod_sub_cat_code
where b.prod_cat in ('Electronics','CLOTHING') and store_type ='FLAGSHIP STORE'
group by b.prod_cat) as x

--9.What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.
select c.Prod_Subcat , sum(total_amt) as Total_Revenue
from customer a  inner join transactions b
on a.customer_id =b.cust_id
inner join prod_cat_info c
on b.prod_cat_code = c.prod_cat_code
and b.prod_subcat_code = c.prod_sub_cat_code
where gender ='M' and prod_cat ='Electronics'
group by c.prod_subcat

--10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?
  select top 5
     P.prod_subcat as Subcategory ,
      Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)[Sales]  , 
     Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2) [Returns] ,
    Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)[Total_Qty],
    ((Round(SUM(cast( case when T.Qty < 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100 as [Return_%],
    ((Round(SUM(cast( case when T.Qty > 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100 as [Sales_%]
    from Transactions as T
    INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
    group by P.prod_subcat
    order by [Sales_%] desc


--11.-For all customers aged between 25 to 35 years ,find what is the net total revenue generated by these consumers in last 30 days of transactions from 
-------max transaction date available in the data?

select Customer_Id ,SUM(total_amt) as Total_Revenue
from
(select *,DATEDIFF(year,a.DOB,GETDATE()) as Age from Customer a
inner join 
Transactions b
on a.customer_Id = b.cust_id) as X
where Age between 25 and 35 and tran_date > (select dateadd(DAY,-30, MAX(tran_date))from Transactions)
group by Customer_Id

---Q-12---find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?
select top 1 p.Prod_Cat , COUNT(qty) as Number_Of_Returns
From transactions as t 
inner join prod_cat_info as p 
on t.prod_subcat_code=p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
where total_amt < 0 and tran_date > (select dateadd(month,-3, MAX(tran_date))from Transactions)
--and tran_date < (select MAX(tran_date) from Transactions)
group by p.prod_cat
order by NUMBER_OF_RETURNS desc


--13 Which store-type sells the maximum products; by value of sales amount and by quantity sold?

select top 1 Store_Type, round(SUM(total_amt),2)as Total_Sales , SUM(qty) as Quantity_Sold from Transactions
group by Store_type
order by 
SUM(total_amt) desc, SUM(qty) desc

--14.-What are the categories for which average revenue is above the overall average.

select a.prod_cat as Product_Category , AVG(total_amt) as Average_Revenue
from prod_cat_info a
inner join Transactions b
on a.prod_cat_code=b.prod_cat_code
and a.prod_sub_cat_code = b.prod_subcat_code
group by a.prod_cat
having  AVG(total_amt) > (select avg(total_amt) from Transactions)


--15.Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.


select c.prod_cat as Product_Catrgory,c.prod_subcat as Product_Subcategory,avg(d.total_Amt) as Average_Amount ,sum(d.total_amt) as Total_Amount
from prod_cat_info  c
inner join Transactions d 
on c.prod_cat_code=d.prod_cat_code
and c.prod_sub_cat_code = d.prod_subcat_code
where c.prod_cat in ( select top 5 a.prod_cat -- This subquery is written to find the top 5 CATEGORIES IN TERMS OF QTY SOLD 
from prod_cat_info a
inner join Transactions b
on a.prod_cat_code=b.prod_cat_code
and a.prod_sub_cat_code = b.prod_subcat_code
group by a.prod_cat
order by sum(b.QTY) desc )
group by c.prod_subcat,c.prod_cat


