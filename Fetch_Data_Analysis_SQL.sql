-- 🔹 Question 1: What are the top 5 brands by receipts scanned among users 21 and over?
SELECT 
    cp.BRAND, 
    COUNT(ct.RECEIPT_ID) AS total_receipts  -- Counting the number of receipts scanned per brand
FROM transactions_cleaned ct
JOIN users_cleaned cu ON ct.USER_ID = cu.ID  -- Joining with users table to filter by age
JOIN products_cleaned cp ON ct.BARCODE = cp.BARCODE  -- Joining with products table to get brand names

WHERE 
    (strftime('%Y', 'now') - strftime('%Y', cu.BIRTH_DATE)) >= 21  -- Filtering for users aged 21+

GROUP BY cp.BRAND  -- Grouping by brand to count total receipts scanned
ORDER BY total_receipts DESC  -- Sorting brands by the highest number of receipts scanned
LIMIT 5;  -- Selecting only the top 5 brands


-- Question 2: Top 5 brands by sales among users with accounts for at least six months
WITH UserTenure AS ( -- Step 1: Identify users who have had their accounts for at least six months
    SELECT ID
    FROM users_cleaned
    WHERE DATE(CREATED_DATE) <= DATE('now', '-6 months')  -- Filtering users who joined at least 6 months ago
)
SELECT P.BRAND, -- -- Step 2: Find the top 5 brands by total sales among these long-term users
       SUM(CAST(T.FINAL_SALE AS DECIMAL)) AS Total_Sales  -- Summing total sales per brand

FROM transactions_cleaned T
JOIN UserTenure U ON T.USER_ID = U.ID  -- Joining with filtered users to consider only long-term accounts
JOIN products_cleaned P ON T.BARCODE = P.BARCODE  -- Joining with products to get brand names
GROUP BY P.BRAND  -- Grouping by brand to calculate total revenue for each
ORDER BY Total_Sales DESC  -- Sorting brands by highest total sales
LIMIT 5;  -- Selecting only the top 5 brands

-- 🔹 Question 3: Generation-wise Health & Wellness Sales
WITH UserGeneration AS ( -- Step 1: Categorize users into generations based on their birth year
    SELECT ID,
           CASE 
               WHEN strftime('%Y', BIRTH_DATE) >= strftime('%Y', 'now', '-27 years') THEN 'Gen Z'  -- Born in the last 27 years
               WHEN strftime('%Y', BIRTH_DATE) >= strftime('%Y', 'now', '-43 years') THEN 'Millennials'  -- Born in the last 43 years
               WHEN strftime('%Y', BIRTH_DATE) >= strftime('%Y', 'now', '-59 years') THEN 'Gen X'  -- Born in the last 59 years
               WHEN strftime('%Y', BIRTH_DATE) >= strftime('%Y', 'now', '-78 years') THEN 'Baby Boomers'  -- Born in the last 78 years
               ELSE 'Silent Generation'  -- Anyone older falls into this category
           END AS Generation
    FROM users_cleaned
) -- Step 2: Calculate total Health & Wellness sales per generation and their percentage of total sales
SELECT UG.Generation, 
       SUM(CAST(T.FINAL_SALE AS DECIMAL)) AS Health_Wellness_Sales,  -- Summing total sales in Health & Wellness
       (SUM(CAST(T.FINAL_SALE AS DECIMAL)) * 100.0 /  -- Calculating the percentage contribution of each generation to overall sales
       (SELECT SUM(CAST(FINAL_SALE AS DECIMAL)) FROM transactions_cleaned)) AS Percentage    
FROM transactions_cleaned T
JOIN UserGeneration UG ON T.USER_ID = UG.ID  -- Joining with categorized user generations
JOIN products_cleaned P ON T.BARCODE = P.BARCODE  -- Joining with products to filter Health & Wellness purchases
WHERE P.CATEGORY_1 = 'Health & Wellness'  -- Filtering transactions only in this category
GROUP BY UG.Generation  -- Grouping by generation to get sales per group
ORDER BY Health_Wellness_Sales DESC;  -- Sorting from highest to lowest total sales

-- Open-Ended Question 1: Identifying Fetch’s power users
/*Who are Fetch’s power users? 
-- Open - Ended Question 1 :Who are Fetch’s power users?
-- First, I want to identify Fetch’s power users.
-- I'll define power users as those who have scanned the most receipts and have the highest total sales.*/
SELECT T.USER_ID, 
       COUNT(DISTINCT T.RECEIPT_ID) AS Total_Receipts,  -- Count the unique receipts scanned by each user
       SUM(CAST(T.FINAL_SALE AS DECIMAL)) AS Total_Sales  -- -- Sum up total sales for each user
FROM transactions_cleaned T ---- Pulling data from the transactions table
GROUP BY T.USER_ID
ORDER BY Total_Receipts DESC, Total_Sales DESC   -- -- Grouping by user ID to calculate stats per user
-- I want to prioritize users who scan the most receipts first.
-- If two users have the same number of receipts, I'll sort them by their total sales.
LIMIT 10; ---- Finally, I only want to see the **top 10** power users



-- Question 2: Leading brand in the Dips & Salsa category
SELECT P.BRAND, 
       SUM(CAST(T.FINAL_SALE AS DECIMAL)) AS Total_Sales -- -- Calculate total sales per brand
FROM transactions_cleaned T
JOIN products_cleaned P ON T.BARCODE = P.BARCODE -- -- Link transactions to product details
WHERE P.CATEGORY_2 = 'Dips & Salsa' ---- Focus only on "Dips & Salsa" products
GROUP BY P.BRAND  -- Aggregate sales by brand
ORDER BY Total_Sales DESC  -- Rank brands by highest sales
LIMIT 5;  -- Display top 5 brands

/*
 Assumptions:
1️. Ranking is based on **total sales revenue**.
2️.  Brands listed as **"Unknown"** indicate **missing brand information**.
3️. Analysis is restricted to products classified as **"Dips & Salsa"**.
*/

