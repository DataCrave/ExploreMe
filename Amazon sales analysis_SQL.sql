-- 1.	What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT `product line`) AS Product_line FROM amazon;

-- 2.	Which product line has the highest sales?
SELECT `Product line`, COUNT(Total) AS TotalSales
FROM amazon GROUP BY `Product line` ORDER BY TotalSales DESC
LIMIT 1;

-- 3.	Which product line generated the highest revenue?

SELECT `Product line`, ROUND(SUM(Total),2) AS Total_revenue
FROM amazon GROUP BY `Product line`
ORDER BY Total_revenue DESC LIMIT 1;

-- 4.	Which product line incurred the highest Value Added Tax?

SELECT `Product line`, ROUND(SUM(`Tax 5%`),2) AS Total_VAT
FROM amazon GROUP BY `Product line` ORDER BY Total_VAT DESC
LIMIT 1;

-- 5.	For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
-- Average is 322.96674900000005
-- A-340
-- B-332
-- c-328
select `product line`,
CASE 
	WHEN Total > (SELECT AVG(Total) FROM amazon) THEN "GOOD"
    ELSE "BAD"
    END AS Review
FROM amazon;

-- 6.	Which product line is most frequently associated with each gender?
select  gender, `product line`, count(*) as category_count 
from amazon group by gender, `product line`order by category_count DESC;

-- 7.	Calculate the average rating for each product line.

SELECT `Product line`, ROUND(AVG(Rating),2) AS AverageRating
FROM amazon GROUP BY `Product line`;

-- Sales Analysis

-- 1.	How much revenue is generated each month?
SELECT MonthName,ROUND(SUM(Total * Quantity), 2) AS Revenue
FROM amazon GROUP BY MonthName ORDER BY Revenue DESC;

-- 2.	In which month did the cost of goods sold reach its peak?
-- COGS------ COST OF GOODS SOLD (materials_cost + labor_cost + overhead_cost)

SELECT MonthName, ROUND(SUM(COGS),2) as Peak_COGS FROM amazon
GROUP BY MonthName ORDER BY Peak_COGS DESC LIMIT 1;


-- 3.	Identify the branch that exceeded the average number of products sold.

SELECT Branch, SUM(Quantity) FROM amazon
GROUP BY Branch HAVING SUM(Quantity)>(SELECT AVG(Quantity) from amazon) ORDER BY SUM(Quantity) DESC LIMIT 1;

-- 4.	Count the sales occurrences for each time of day on every weekday.

SELECT TimeOfDay, count(*) as Sales_Count from amazon 
where DayName IN ('MON','TUE','WED','THU','FRI') group by TimeOfDay;

-- 5.	What is the count of distinct cities in the dataset?
-- Mandalay, Naypyitaw, Yangon

select COUNT(distinct City ) City_name FROM amazon;

-- 6.	In which city was the highest revenue recorded?

select city, ROUND(sum(Total), 2) as Highest_revenue from amazon
group by City Order by Highest_revenue DESC LIMIT 1;

-- 7.	Determine the city with the highest VAT percentage.
select city, ROUND((SUM(`Tax 5%`)/SUM(Total)*100), 2) Highest_VAT from amazon group by city order by Highest_VAT DESC LIMIT 1;


-- Customer Analysis
-- 1.	For each branch, what is the corresponding city?

select DISTINCT Branch as D_Branch, city from amazon ORDER BY Branch;

-- 2.	Which payment method occurs most frequently?

select Payment, COUNT(*) as Method_Count from amazon group by payment 
order by Method_count desc limit 1;

-- 3.	Identify the customer type contributing the highest revenue.

select `customer type`, ROUND(sum(total), 2) as Contribution from amazon group by `customer type` 
Order by contribution desc limit 1;

-- 4.	Identify the customer type with the highest VAT payments.

select `customer type`, ROUND(sum(`Tax 5%`), 2) as Highest_VAT from amazon 
group by `customer type` Order by Highest_VAT desc limit 1;

-- 5.	What is the count of distinct customer types in the dataset?

select COUNT(DISTINCT(`customer type`)) customer_types from amazon;

-- 6.	What is the count of distinct payment methods in the dataset?
select COUNT(DISTINCT(Payment)) Payment_methods from amazon;

-- 7.	Which customer type occurs most frequently?
select `customer type`, COUNT(*) Frequent_customers from amazon group by `customer type`
order by Frequent_Customers DESC LIMIT 1;
-- 8.	Identify the customer type with the highest purchase frequency.

SELECT `Customer type`, COUNT(`Invoice ID`) AS Purchase_Frequency FROM amazon 
GROUP BY `Customer type` ORDER BY Purchase_Frequency DESC LIMIT 1;

-- 9.	Determine the predominant gender among customers.

SELECT Gender, COUNT(*) AS Gender_count FROM amazon 
GROUP BY Gender ORDER BY Gender_Count DESC LIMIT 1;

-- 10.	Examine the distribution of genders within each branch.

SELECT Branch,Gender,COUNT(*) AS GenderCount
FROM amazon GROUP BY Branch, Gender ORDER BY Branch;

-- 11.	Identify the time of day when customers provide the most ratings.

select TimeOfDay, COUNT(rating) Ratings_received from amazon GROUP BY TimeOfDay ORDER BY ratings_received desc limit 1;
-- 12.	Determine the time of day with the highest customer ratings for each branch.

WITH RatingsCount AS (
    SELECT Branch, TimeOfDay, ROUND(AVG(Rating), 2) AS Avg_Rating FROM amazon
    GROUP BY Branch, TimeOfDay ),
MaxRatings AS (
    SELECT Branch, MAX(Avg_Rating) AS highest_customer_ratings FROM RatingsCount
    GROUP BY Branch)
SELECT r.Branch, r.TimeOfDay, r.Avg_Rating AS highest_customer_ratings
FROM RatingsCount r JOIN MaxRatings m ON r.Branch = m.Branch AND r.Avg_Rating = m.highest_customer_ratings
ORDER BY r.Branch, r.TimeOfDay;

-- 13.	Identify the day of the week with the highest average ratings.
SELECT DayName, ROUND(AVG(rating), 2) AS average_rating
FROM amazon GROUP BY dayname ORDER BY average_rating DESC LIMIT 1;

-- 14.	Determine the day of the week with the highest average ratings for each branch.

WITH AvgRatings AS (
    SELECT Branch, DayName, ROUND(AVG(Rating),2) AS avg_rating
    FROM amazon
    GROUP BY Branch, DayName
)
SELECT Branch, DayName, avg_rating
FROM AvgRatings
WHERE (Branch, avg_rating) IN (
    SELECT Branch, MAX(avg_rating)
    FROM AvgRatings
    GROUP BY Branch
)
ORDER BY Branch, avg_rating DESC;



-- Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.

ALTER TABLE amazon
ADD COLUMN TimeOfDay VARCHAR(20);

-- Update the 'TimeOfDay' column based on the 'Time' column
UPDATE amazon
SET timeofday = CASE
    WHEN TIME_FORMAT(Time, '%H:%i') BETWEEN '06:00' AND '11:59' THEN 'Morning'
    WHEN TIME_FORMAT(Time, '%H:%i') BETWEEN '12:00' AND '17:59' THEN 'Afternoon'
    WHEN TIME_FORMAT(Time, '%H:%i') BETWEEN '18:00' AND '23:59' THEN 'Evening'
    ELSE 'Unknown'
END;
SELECT * FROM amazon;

-- Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.

ALTER TABLE amazon
ADD COLUMN DayName VARCHAR(3);
UPDATE amazon
SET DayName = CASE DAYOFWEEK(Date)
    WHEN 2 THEN 'Mon'
    WHEN 3 THEN 'Tue'
    WHEN 4 THEN 'Wed'
    WHEN 5 THEN 'Thu'
    WHEN 6 THEN 'Fri'
    WHEN 7 THEN 'Sat'
    WHEN 1 THEN 'Sun'
    ELSE 'Unknown'
END;

-- Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.

ALTER TABLE amazon
ADD COLUMN MonthName VARCHAR(3);

UPDATE amazon
SET MonthName = CASE MONTH(Date)
    WHEN 1 THEN 'Jan'
    WHEN 2 THEN 'Feb'
    WHEN 3 THEN 'Mar'
    ELSE 'Unknown'
END;
