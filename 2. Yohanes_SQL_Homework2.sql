-- Case 1

select * from superstore_order where "Ship Mode" = 'Same Day';
-- Extract late same day
select distinct   "Order ID",
			"Order Date",
			"Ship Date",
			"Ship Mode"
	from superstore_order
	where 	extract(day from "Order Date") <> extract(day from "Ship Date")
			and "Ship Mode" = 'Same Day';
-- Final Code
with late_same_day as
(
	select 	"Order ID",
			"Order Date",
			"Ship Date",
			"Ship Mode"
	from superstore_order
	where 	extract(day from "Order Date") <> extract(day from "Ship Date")
			and "Ship Mode" = 'Same Day'
)
select count("Order ID") as "Total Late SAME DAY"
from late_same_day;

-- Case 2

select 	"Order ID",
		"Discount",
 		case when "Discount" < 0.2 then 'LOW'
 	  		 when "Discount" >= 0.2 and "Discount" < 0.4 then 'MODERATE'
 		else 'HIGH'
 		end as "Discount Level",
 		"Profit"
from superstore_order;

--Final Code
with discount_level as
(
	select 	"Order ID",
			"Discount",
			case when "Discount" < 0.2 then 'LOW'
				 when "Discount" >= 0.2 and "Discount" < 0.4 then 'MODERATE'
			else 'HIGH'
			end as "Discount Level",
			"Profit"
	from superstore_order
)
select 	"Discount Level",
		round(cast(avg("Profit") as numeric), 2) as "Average Profit"
from discount_level
group by 1
order by 2 desc;

select * from superstore_product;
select * from superstore_order;
-- Case 3
-- Order by Profit
with cat_subcat as
(
	select 	o."Product ID",
			p."Category",
			p."Sub-Category",
			o."Discount",
			o."Profit"
	from superstore_order o
	join superstore_product p on o."Product ID" = p."Product ID"
)
select 	"Category",
		"Sub-Category",
		round(cast(avg("Discount") as numeric), 2) as "Average Discount",
		round(cast(avg("Profit") as numeric), 2) as "Average Profit"
from  cat_subcat
group by 1,2
order by 4 desc;

-- Order by Discount
with cat_subcat as
(
	select 	o."Product ID",
			p."Category",
			p."Sub-Category",
			o."Discount",
			o."Profit"
	from superstore_order o
	join superstore_product p on o."Product ID" = p."Product ID"
)
select 	"Category",
		"Sub-Category",
		round(cast(avg("Discount") as numeric), 2) as "Average Discount",
		round(cast(avg("Profit") as numeric), 2) as "Average Profit"
from  cat_subcat
group by 1,2
order by 3 desc;


-- Case 4
-- Order by Profit DESC
with t_cust as
(
	select "Customer ID", "State", "Segment"
	from superstore_customer
	where "State" in ('California','Texas','Georgia')
),
t_order as
(
	select "Customer ID", "Order Date", "Sales", "Profit"
	from superstore_order
	where extract(year from "Order Date") = 2016
)

select c."Segment",
	   round(cast(sum(o."Sales") as numeric), 2) as "Sum Sales",
	   round(cast(avg(o."Profit") as numeric), 2) as "Average Profit"
from t_order o
right join t_cust c on o."Customer ID" = c."Customer ID"
group by 1
order by 3 desc;

select * from superstore_customer;
select * from superstore_product;
select * from superstore_order;

-- Case 5:
-- 1 customer can have more than one varied discount
with t_discount as
(
	select "Customer ID",
		   round(cast(avg("Discount") as numeric), 2) as "Average Discount"
	from superstore_order
	group by 1
	having round(cast(avg("Discount") as numeric), 2) > 0.4
),
t_customer as
(
	select "Customer ID",
		   "Region"
	from superstore_customer
)
select 	c."Region",
count(d."Customer ID") as "Count Customer",
round(cast(avg(d."Average Discount") as numeric), 2) as "Avg Disc (Region)"
from t_discount d
left join t_customer c on d."Customer ID" = c."Customer ID"
group by 1
order by 2;