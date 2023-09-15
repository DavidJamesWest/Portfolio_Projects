-- Select all columns from the table
SELECT * FROM Portfolio_Project.dbo.fruitvegprices

-- Value counts for the items in the category column
select category, count(*) as [count] 
from Portfolio_Project.dbo.fruitvegprices 
group by category 
order by [count] desc

-- Show prices per unit in descending order
select item, price
from Portfolio_Project.dbo.fruitvegprices 
group by item, price 
order by price desc

-- Show average prices per unit per category
SELECT category, avg(price) as average
FROM Portfolio_Project.dbo.fruitvegprices
group by (category)
order by average desc

-- Show count of each unit type
select unit, count(unit) as [count]
from Portfolio_Project.dbo.fruitvegprices
group by unit
order by [count]
 
-- Show average price per unit for vegetables
select category, round(avg(price), 2) as [avg], unit
from Portfolio_Project.dbo.fruitvegprices
where category = 'vegetable'
group by category, unit
order by [avg] desc

-- Show value counts of items
select item, count(item) as [count] 
from Portfolio_Project.dbo.fruitvegprices
group by item
order by [count] desc

-- Show the prices above $10 per kg in the 3rd quarter ordered by date
select * 
from Portfolio_Project.dbo.fruitvegprices
where unit = 'kg'
and price > 10 
and date between '2022-07-01' and '2022-09-30'
order by date

-- Show the relative gooseberry price change by date 
-- Save as a view for use at a later date
-- Drop view if changes to the view are required
--drop view if exists GooseberryPricePercent
--create view GooseberryPricePercent as
with PricePercentTable as 
(select * , LAG(price) over (order by date) as PrevPrice,
price - LAG(price) over (order by date) as PriceDiff
from Portfolio_Project.dbo.fruitvegprices
where variety = 'gooseberries')
--order by date)
select *, (PriceDiff/price)*100 as PricePercent
from PricePercentTable
--where PrevPrice IS NOT NULL
--order by date

-- Show relative price change for all item varities
--create view RelativePriceDiff as
select item, variety, date, price, LAG(price) over (partition by item, variety order by date) as PrevPrice,
price - LAG(price) over (partition by item, variety order by date) as PriceDiff
from Portfolio_Project.dbo.fruitvegprices
order by item, variety, date

-- Create table for egg prices and then creat a new table for the combined date
drop table if exists Portfolio_Project.dbo.eggprices
create table Portfolio_Project.dbo.eggprices (
category nvarchar(255),
item nvarchar(255),
variety nvarchar(255),
[date] date,
price float,
unit nvarchar(255)
)

insert into Portfolio_Project.dbo.eggprices(category, item, variety, date, price, unit)
values 
('dry_goods', 'eggs', 'large', '2023-08-05', 2.81, 'dozen'),
('dry_goods', 'eggs', 'large', '2023-08-12', 2.95, 'dozen'),
('dry_goods', 'eggs', 'large', '2023-08-19', 3.05, 'dozen'),
('dry_goods', 'eggs', 'large', '2023-08-26', 3.01, 'dozen'),
('dry_goods', 'eggs', 'large', '2023-09-02', 2.75, 'dozen'),
('dry_goods', 'eggs', 'large', '2023-08-09', 2.90, 'dozen'),
('dry_goods', 'eggs', 'large', '2023-08-16', 2.54, 'dozen'),
('dry_goods', 'eggs', 'medium', '2023-08-01', 1.84, 'half_dozen'),
('dry_goods', 'eggs', 'medium', '2023-08-15', 2.22, 'half_dozen'),
('dry_goods', 'eggs', 'medium', '2023-08-29', 1.99, 'half_dozen'),
('dry_goods', 'eggs', 'medium', '2023-09-12', 1.87, 'half_dozen')

select * into Portfolio_Project.dbo.CombinedPrices from Portfolio_Project.dbo.fruitvegprices
union
select * from Portfolio_Project.dbo.eggprices

select * from Portfolio_Project.dbo.CombinedPrices
where category = 'dry_goods'

-- Creat table of store section for the different categories
drop table if exists Portfolio_Project.dbo.store_section
create table Portfolio_Project.dbo.store_section (
category nvarchar(255),
section nvarchar(255)
)

insert into Portfolio_Project.dbo.store_section(category, section)
values 
('dry_goods', 'aisle_1'),
('vegetable', 'aisle_6'),
('fruit', 'aisle_7'),
('cut_flowers', 'tills'),
('pot_plants', 'foyer')

-- Join store section categories to the combined prices table
select *
from Portfolio_Project.dbo.CombinedPrices
inner join Portfolio_Project.dbo.store_section on Portfolio_Project.dbo.CombinedPrices.category = Portfolio_Project.dbo.store_section.category
