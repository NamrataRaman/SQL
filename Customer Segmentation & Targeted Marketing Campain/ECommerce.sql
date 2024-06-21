use [ECommerce];
--Is there any growing trend in Brazil?
--Select Year, Month, Revenue From Order Join with Payment Group By Year, Month Order By Year, Month

select 
 RANK() OVER (ORDER BY round(sum(p.payment_value),2) desc) AS Ranking
, YEAR(o.order_purchase_timestamp) as Year
,Month(o.order_purchase_timestamp) as Month
,round(sum(p.payment_value),2) as Revenue
from [Online].[Orders] o
left join [Online].[Order_Payments] p
on o.[order_id] = p.[order_id]
group by YEAR(o.order_purchase_timestamp), Month(o.order_purchase_timestamp)
order by Ranking asc


--Can we see some seasonality with peaks at specific month?

Select Month(order_purchase_timestamp) as Month 
,COUNT(distinct(order_id)) as order_count
From [Online].[Orders]
group by  Month(order_purchase_timestamp)
order by  Month(order_purchase_timestamp);


--Understanding buying patterns of brazilian customers.
--case if Hour between 0-5 then Dawn, 6-11 mornig, 12-17 Afternoon, 18-23 Night
 --order_purchase_timestamp,
SELECT    
    case 
		when DATEPART(HOUR, order_purchase_timestamp) between 0 and 5 then 'Dawn'
		when DATEPART(HOUR, order_purchase_timestamp) between 6 and 11 then 'Morning'
		when DATEPART(HOUR, order_purchase_timestamp) between 12 and 17 then 'Afternoon'
		when DATEPART(HOUR, order_purchase_timestamp) between 18 and 23 then 'Night' 
	end as order_Hour
	,COUNT(distinct(order_id)) as order_count

FROM
    [Online].[Orders]
	group by   case 
		when DATEPART(HOUR, order_purchase_timestamp) between 0 and 5 then 'Dawn'
		when DATEPART(HOUR, order_purchase_timestamp) between 6 and 11 then 'Morning'
		when DATEPART(HOUR, order_purchase_timestamp) between 12 and 17 then 'Afternoon'
		when DATEPART(HOUR, order_purchase_timestamp) between 18 and 23 then 'Night' 
	end
	order by order_count


	--Analysing month by month orders by state
Select c.[customer_state] 
, DateName( month ,o.order_purchase_timestamp) as Order_Month   
,Month(o.order_purchase_timestamp) as Month
,count(o.[order_id]) as order_count
From [Online].[Orders] o
Left join [Online].[Customers] c
on o.[customer_id] = c.[customer_id]
group by c.[customer_state] , Month(o.order_purchase_timestamp) ,DateName( month ,o.order_purchase_timestamp)
order by c.[customer_state] ,Month(o.order_purchase_timestamp) ,DateName( month ,o.order_purchase_timestamp)


--Distribution of customer across Brazilian state.
Select 
[customer_state]
,Count([customer_id]) as Customer_Count
From [Online].[Customers]
Group By [customer_state]
Order By Customer_Count Desc;


--Analysing Mean and Sum of price and Frieght value by customer state.
--[Online].[Order_Items],[Online].[Customers],[Online].[Orders]
Select 
Sum(cast(oi.price as decimal(6,2))) as sum_price
,Format(Avg(oi.price),'N2') as avg_price
,Sum(cast(oi.freight_value as decimal(6,2)))as sum_freight
,Format(Avg(oi.freight_value),'N2') as avg_freight
, c.customer_state
From [Online].[Customers] c
Left join [Online].[Orders] o
on c.[customer_id] = o.[customer_id]
Left join [Online].[Order_Items] oi
on o.[order_id] = oi.[order_id]
Group By c.customer_state


--Calculating days between purchaging, delivery and estimated delivery state wise.
--datediff
SELECT 
c.customer_state
,AVG(DATEDIFF(day,o.[order_purchase_timestamp],o.[order_delivered_customer_date])) AS Diff_btw_Pur_Delivery
,AVG(DATEDIFF(day,o.[order_purchase_timestamp],o.[order_estimated_delivery_date])) AS Diff_btw_Pur_estDelivery
from [Online].[Orders] o
Left Join [Online].[Customers] c
on o.[customer_id] = c.[customer_id]
where o.[order_delivered_customer_date] is not null
Group By c.customer_state
Order By Diff_btw_Pur_Delivery


--Count of orders based on the payment installment
Select op.payment_installments,count(o.order_id) as order_count
From [Online].[Orders] o
Left Join [Online].[Order_Payments] op
on o.order_id = op.order_id
Where o.[order_status] !='canceled' and op.payment_installments is not null
Group By payment_installments
order by order_count desc



