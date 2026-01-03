drop table if exists zepto;

drop table if exists zepto_stage;


use  zepto_sql_project;

--- create Table zepto

create table zepto(
sku_id int identity(1,1) primary key,
Category varchar(120),
name varchar (150),
mrp numeric(8,2),
discountPercent numeric(5,2),
availableQuantity integer,
discountedSellingPrice numeric(8,2),
weightInGms integer,
outOfStock BIT ,
quantity integer
);

--- stagging Table

CREATE TABLE zepto_stage (
    Category  VARCHAR(100),
    name VARCHAR(100),
    mrp VARCHAR(100),
    discountPercent VARCHAR(100),
    availableQuantity VARCHAR(100),
    discountedSellingPrice VARCHAR(100),
    weightInGms VARCHAR(100),
    outOfStock VARCHAR(20),
	quantity varchar(100)
);

---insert into staging table

BULK INSERT zepto_stage
FROM 'C:\zepto\zepto_v2.csv'
WITH (
    FIRSTROW = 2,              
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);


---clean and insert into final table

INSERT INTO zepto (
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
)
SELECT
    LTRIM(RTRIM(category)),

    LTRIM(RTRIM(name)),

    TRY_CAST(
        REPLACE(REPLACE(NULLIF(LTRIM(RTRIM(mrp)),'') , ',', ''), '₹', '')
        AS DECIMAL(22,2)
    ),

    TRY_CAST(NULLIF(LTRIM(RTRIM(discountPercent)),'') AS DECIMAL(5,2)),

    TRY_CAST(NULLIF(LTRIM(RTRIM(availableQuantity)),'') AS INT),

    TRY_CAST(
        REPLACE(REPLACE(NULLIF(LTRIM(RTRIM(discountedSellingPrice)),'') , ',', ''), '₹', '')
        AS DECIMAL(22,2)
    ),

    TRY_CAST(NULLIF(LTRIM(RTRIM(weightInGms)),'') AS INT),

    CASE
        WHEN LOWER(LTRIM(RTRIM(outOfStock))) IN ('true','1','yes') THEN 1
        WHEN LOWER(LTRIM(RTRIM(outOfStock))) IN ('false','0','no') THEN 0
        ELSE NULL
    END,

    TRY_CAST(NULLIF(LTRIM(RTRIM(quantity)),'') AS INT)

FROM zepto_stage

WHERE
    TRY_CAST(REPLACE(REPLACE(NULLIF(LTRIM(RTRIM(mrp)),'') , ',', ''),'₹','') AS DECIMAL(22,2)) IS NOT NULL
    AND TRY_CAST(NULLIF(LTRIM(RTRIM(discountedSellingPrice)),'') AS DECIMAL(22,2)) IS NOT NULL;


--error in table

drop table if exists zepto_error;

CREATE TABLE zepto_error (
    raw_row VARCHAR(MAX),
    error_reason VARCHAR(200),
    load_time DATETIME DEFAULT GETDATE()
);

INSERT INTO zepto_error (raw_row, error_reason)
SELECT 
    CONCAT_WS(',', Category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, outOfStock, quantity),
    'Invalid numeric value'
FROM zepto_stage
WHERE 
    TRY_CAST(NULLIF(LTRIM(RTRIM(mrp)),'') AS DECIMAL(22,2)) IS NULL
    OR TRY_CAST(NULLIF(LTRIM(RTRIM(discountedSellingPrice)),'') AS DECIMAL(22,2)) IS NULL
    OR TRY_CAST(NULLIF(LTRIM(RTRIM(availableQuantity)),'') AS INT) IS NULL
    OR TRY_CAST(NULLIF(LTRIM(RTRIM(weightInGms)),'') AS INT) IS NULL
    OR TRY_CAST(NULLIF(LTRIM(RTRIM(quantity)),'') AS INT) IS NULL;

select * from zepto_error

SELECT mrp
FROM zepto_stage
WHERE TRY_CAST(NULLIF(LTRIM(RTRIM(mrp)),'') AS DECIMAL(22,2)) IS NULL
  AND NULLIF(LTRIM(RTRIM(mrp)),'') IS NOT NULL;

  SELECT *
FROM zepto_stage
WHERE TRY_CAST(mrp AS DECIMAL(10,2)) IS NULL
  AND mrp IS NOT NULL;




select * from zepto_stage;

--- Data exploration 

--- count of rows

select count(*) from zepto ;

--- sample data

select top 10 * from zepto;

---null values

select * from zepto
where name is null
or
Category is null
or
mrp is null
or
discountPercent is null
or
availableQuantity is null
or
discountedSellingPrice is null
or
weightInGms is null
or
outOfStock is null
or
quantity is null

--- different product categories

select distinct category from zepto
order by category


--- products in stock vs out of stock

select outOfStock,count(sku_id)
from zepto
group by outOfStock

--- product names present mutipe times

select name,count(sku_id) as "numbers_of_sku"
from zepto
group by name
having count(sku_id)>1
order by count(sku_id) desc ;

--- data cleaning 

select * from zepto
where mrp=0 or discountedSellingPrice = 0;

delete from zepto where mrp = 0;

--- convert paise into rupees
update zepto set mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

--update
UPDATE zepto
SET mrp = mrp * 10000,
    discountedSellingPrice = discountedSellingPrice * 10000;


select mrp,discountedSellingPrice from zepto


--data analysis

-- Q1. Find the top 10 best-value products based on the discount percentage.

select distinct top 10 name,mrp,discountedSellingPrice 
from zepto
order by discountedSellingPrice desc

-- Q2.What are the Products with High MRP but Out of Stock

select distinct top 10 name ,mrp
from zepto
where outOfStock = 1 
order by mrp desc;

-- Q3.Calculate Estimated Revenue for each category

SELECT category,
 SUM(discountedSellingPrice * quantity) AS estimated_revenue
FROM zepto
GROUP BY category
ORDER BY estimated_revenue DESC;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.

SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.

select top 5 category,
round(avg(discountPercent),2) as average_discountPercent
from zepto
group by  category
order by average_discountPercent desc

-- Q6. Find the price per gram for products above 100g and sort by best value.

select  name,discountedSellingPrice,weightInGms,
round(discountedSellingPrice/weightInGms,2) as price_per_gram
from zepto
where weightInGms >= 100 
order by price_per_gram;


--Q7.Group the products into categories like Low, Medium, Bulk.

select distinct name , weightInGms,
case when weightInGms < 1000 Then 'low'
	when weightInGms < 5000 then 'medium'
	else 'bulk'
	end as weight_per_category
from zepto

--Q8.What is the Total Inventory Weight Per Category 

select category , 
sum(weightInGms*availableQuantity) as total_weight
from zepto 
group by category
order by total_weight ;
















