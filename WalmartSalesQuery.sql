CREATE DATABASE IF NOT EXISTS salesDataWalmart;

salesCREATE TABLE IF NOT EXISTS sales (
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
	product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1) 
);



-- ------------------------------------------------------------------------
-- --------------- Feature Engineering ------------------------------------

-- time_of_day

SELECT
	time,
    (CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
			WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
			WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
			ELSE "Evening"
    END
);

-- day_name 

SELECT 
	date,
    DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- month_name 

SELECT 
	date,
    MONTHNAME(date)
FROM sales;
	

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);
-- ------------------------------------------------------------------------


-- ------------------------------------------------------------------------
-- ----------------------------- Generic ----------------------------------


-- Q1. How many unique cities does the data have? Ans: 3 - Yangon, Naypyitaw, Mandalay
SELECT 
	DISTINCT city 
FROM sales;

-- Q2. In which city is each branch? Ans: A, C, B respectively
SELECT 
	DISTINCT branch
FROM sales;

SELECT 
	DISTINCT city,
    branch
FROM sales;
-- ------------------------------------------------------------------------


-- ------------------------------------------------------------------------
-- ----------------------------- Product ----------------------------------

-- Q1. How many unique product lines does the data have? Ans: 6
SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

-- Q2. What is the most common payment method? Ans: Cash
SELECT
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- Q3. What is the most selling product line? Ans: Fashion accessories
SELECT
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- Q4. What is the total revenue by month?
SELECT 
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- Q5. What month had the largest COGS? Ans: January
SELECT
	month_name AS month,
    SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- Q6. What product line had the largest revenue? Ans: Food and beverages
SELECT 
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- Q7. What is the city with the largest revenue? Ans: Naypyitaw
SELECT 
	branch,
	city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER by total_revenue DESC;

-- Q8. What product line had the largest VAT? Ans: Food and beverages 
SELECT
	product_line,
    SUM(VAT) AS total_VAT
FROM sales
GROUP BY product_line
ORDER by total_VAT DESC;

-- Q9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
    AVG(quantity) AS avg_sales
FROM sales;

SELECT
		product_line,
		CASE 
			WHEN AVG(quantity) > 6 THEN "Good" -- i think this line is wrong
		ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

ALTER TABLE sales ADD COLUMN good_or_bad VARCHAR(5);

UPDATE sales
SET good_or_bad = DAYNAME(date);

-- Q10. Which branch sold more products than average product sold? -- not sure: where the avg is checked here
SELECT
	branch,
    SUM(quantity) as total_sold
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);


-- Q11. What is the most common product line by gender? Ans: Fashion accessories for females, Health and beauty for males
SELECT
	product_line,
    gender,
	COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- Q12. What is the average rating of each product line?
SELECT
    product_line,
    ROUND(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;
-- ------------------------------------------------------------------------



-- ------------------------------------------------------------------------
-- ----------------------------- Sales ----------------------------------
-- Q1. Number of sales made in each time of the day per weekday
SELECT 
	day_name, 
    time_of_day, 
    COUNT(*) AS sales_count
FROM sales
GROUP BY day_name, time_of_day
ORDER BY 
	CASE day_name
		WHEN 'Monday' THEN 1
		WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,
    CASE time_of_day
		WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Evening' THEN 3
	END;

-- Q2. Which of the customer types brings the most revenue? Ans: Member
SELECT 
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Q3. Which city has the largest tax percent/ VAT (Value Added Tax)? Ans: Naypyitaw
SELECT
	city,
	ROUND(AVG(VAT), 2) AS avg_VAT
FROM sales
GROUP BY city
ORDER BY avg_VAT DESC;

-- Q4. Which customer type pays the most in VAT? Ans: Member
SELECT 
	customer_type,
    SUM(VAT) AS total_VAT
FROM sales
GROUP BY customer_type
ORDER BY total_VAT DESC;

-- ------------------------------------------------------------------------



-- ------------------------------------------------------------------------
-- ----------------------------- Customer ----------------------------------
-- Q1. How many unique customer types does the data have? Ans: 2
SELECT 
	COUNT(DISTINCT customer_type) AS unique_customers
FROM sales;

-- Q2. How many unique payment methods does the data have? Ans: 3
SELECT
	COUNT(DISTINCT payment_method) AS unique_payment_methods
FROM sales;

-- Q3. What is the most common customer type? Ans: Normal
SELECT
	customer_type,
    COUNT(customer_type) AS customer_count
FROM sales
GROUP BY customer_type
ORDER BY customer_count;

-- Q4. Which customer type buys the most? Ans: Members
SELECT
	customer_type,
    SUM(quantity) as total_qty
FROM sales
GROUP BY customer_type
ORDER BY total_qty DESC;

-- Q5. What is the gender of most of the customers? Ans: Female
SELECT
	gender,
    COUNT(*) AS count
FROM sales
GROUP BY gender
ORDER BY count;

-- Q6. What is the gender distribution per branch?
SELECT
	branch,
    gender,
    COUNT(*) AS count
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender;

-- Q7. Which time of the day do customers give most ratings? Ans: Evening
SELECT
	time_of_day,
    COUNT(rating) AS count
FROM sales
GROUP BY time_of_day 
ORDER BY count DESC;

-- Q8. Which time of the day do customers give most ratings per branch? Ans: A-Evening, B-Evening, C-Evening
SELECT
	branch,
	time_of_day,
    COUNT(rating) as count
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, count DESC;

-- Q9. Which day of the week has the best avg ratings? Ans: Monday
SELECT
	day_name,
    ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Q10. Which day of the week has the best average ratings per branch? Ans: A-Friday, B-Monday, C-Saturday
SELECT
    branch,
    day_name,
    ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;

-- ------------------------------------------------------------------------

