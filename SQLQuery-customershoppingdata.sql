SELECT *
FROM customer_shopping_data$

--Find missing values--
SELECT
    COUNT(CASE WHEN Invoice_no IS NULL THEN 1 END) AS missing_invoice_no,
    COUNT(CASE WHEN customer_id IS NULL THEN 1 END) AS missing_customer_id,
    COUNT(CASE WHEN gender IS NULL THEN 1 END) AS missing_gender,
    COUNT(CASE WHEN age IS NULL THEN 1 END) AS missing_age,
    COUNT(CASE WHEN category IS NULL THEN 1 END) AS missing_category,
    COUNT(CASE WHEN quantity IS NULL THEN 1 END) AS missing_quantity,
    COUNT(CASE WHEN price IS NULL THEN 1 END) AS missing_price,
    COUNT(CASE WHEN payment_method IS NULL THEN 1 END) AS missing_payment_method,
    COUNT(CASE WHEN invoice_date IS NULL THEN 1 END) AS missing_invoice_date,
    COUNT(CASE WHEN shopping_mall IS NULL THEN 1 END) AS missing_shopping_mall
FROM customer_shopping_data$;

--Delete missing values--
DELETE FROM customer_shopping_data$
WHERE
    Invoice_no IS NULL OR
    customer_id IS NULL OR
    gender IS NULL OR
    age IS NULL OR
    category IS NULL OR
    quantity IS NULL OR
    price IS NULL OR
    payment_method IS NULL OR
    invoice_date IS NULL OR
    shopping_mall IS NULL;

--Total number of malls in the list--
SELECT COUNT(DISTINCT shopping_mall) AS number_of_malls
FROM customer_shopping_data$;

--Most to least visit malls from asc to dsc order--
SELECT shopping_mall, COUNT(*) AS visit_count
FROM customer_shopping_data$
GROUP BY shopping_mall
ORDER BY visit_count DESC;

--Years most to least crowded--
SELECT
    YEAR(invoice_date) AS visit_year,
    COUNT(*) AS visit_count
FROM customer_shopping_data$
GROUP BY YEAR(invoice_date)
ORDER BY visit_count DESC;

--Specific year for the most visited mall--
SELECT TOP 1
    YEAR(invoice_date) AS visit_year,
    shopping_mall,
    COUNT(*) AS visit_count
FROM customer_shopping_data$
GROUP BY YEAR(invoice_date), shopping_mall
ORDER BY visit_count DESC;

--Specific year for the least visited mall--
SELECT TOP 1
    YEAR(invoice_date) AS visit_year,
    shopping_mall,
    COUNT(*) AS visit_count
FROM customer_shopping_data$
GROUP BY YEAR(invoice_date), shopping_mall
ORDER BY visit_count ASC;

--Quarterly visits--
SELECT
    YEAR(invoice_date) AS visit_year,
    shopping_mall,
    DATEPART(QUARTER, invoice_date) AS visit_quarter,
    COUNT(*) AS visit_count
FROM customer_shopping_data$
GROUP BY YEAR(invoice_date), shopping_mall, DATEPART(QUARTER, invoice_date)
ORDER BY visit_year, visit_quarter, visit_count DESC;

--Popular payment method--
SELECT TOP 1
    payment_method,
    COUNT(*) AS payment_count
FROM customer_shopping_data$
GROUP BY payment_method
ORDER BY payment_count DESC;

--Highest priced item--
SELECT
    category,
    MAX(price) AS highest_price
FROM customer_shopping_data$
GROUP BY category;

--Lowest priced item--
SELECT
    category,
    MIN(price) AS lowest_price
FROM customer_shopping_data$
GROUP BY category;

--Highest price paid by cash--
SELECT
    MAX(price) AS highest_cash_price
FROM customer_shopping_data$
WHERE payment_method = 'Cash';

--Lowest price paid by cash--
SELECT
    MIN(price) AS lowest_cash_price
FROM customer_shopping_data$
WHERE payment_method = 'Cash';

--Unique items in category field--
SELECT DISTINCT category
FROM customer_shopping_data$;

--Most bought item category--
SELECT TOP 1
    category,
    SUM(quantity) AS total_quantity
FROM customer_shopping_data$
GROUP BY category
ORDER BY total_quantity DESC;

--Least bought item category--
SELECT TOP 1
    category,
    SUM(quantity) AS total_quantity
FROM customer_shopping_data$
GROUP BY category
ORDER BY total_quantity ASC;

--Age grouping--
SELECT
    *,
    CASE
        WHEN age BETWEEN 0 AND 14 THEN '0-14'
        WHEN age BETWEEN 15 AND 25 THEN '15-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        WHEN age BETWEEN 56 AND 65 THEN '56-65'
        WHEN age BETWEEN 66 AND 75 THEN '66-75'
        WHEN age BETWEEN 76 AND 100 THEN '76-100'
        ELSE 'Unknown'
    END AS age_group
FROM customer_shopping_data$;

--Most common item purchased by each age group--
WITH AgeGroupData AS (
    SELECT
        *,
        CASE
            WHEN age BETWEEN 0 AND 14 THEN '0-14'
            WHEN age BETWEEN 15 AND 25 THEN '15-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            WHEN age BETWEEN 46 AND 55 THEN '46-55'
            WHEN age BETWEEN 56 AND 65 THEN '56-65'
            WHEN age BETWEEN 66 AND 75 THEN '66-75'
            WHEN age BETWEEN 76 AND 100 THEN '76-100'
            ELSE 'Unknown'
        END AS age_group
    FROM customer_shopping_data$
)

SELECT
    age_group,
    category AS most_common_item,
    COUNT(*) AS item_count
FROM AgeGroupData
GROUP BY age_group, category
ORDER BY age_group, item_count DESC;

--Which age group was visiting the malls the most--
WITH AgeGroupData AS (
    SELECT
        *,
        CASE
            WHEN age BETWEEN 0 AND 14 THEN '0-14'
            WHEN age BETWEEN 15 AND 25 THEN '15-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            WHEN age BETWEEN 46 AND 55 THEN '46-55'
            WHEN age BETWEEN 56 AND 65 THEN '56-65'
            WHEN age BETWEEN 66 AND 75 THEN '66-75'
            WHEN age BETWEEN 76 AND 100 THEN '76-100'
            ELSE 'Unknown'
        END AS age_group
    FROM customer_shopping_data$
)

SELECT
    age_group,
    COUNT(*) AS visit_count
FROM AgeGroupData
GROUP BY age_group
ORDER BY visit_count DESC;

--Male to female ratio--
SELECT
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS male_count,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS female_count,
    ROUND(COUNT(CASE WHEN gender = 'Male' THEN 1 END) * 1.0 / NULLIF(COUNT(CASE WHEN gender = 'Female' THEN 1 END), 0), 2) AS male_to_female_ratio
FROM customer_shopping_data$;

--Most common item bought by male and female--
WITH GenderItemCounts AS (
    SELECT
        gender,
        category AS most_common_item,
        COUNT(*) AS item_count
    FROM customer_shopping_data$
    GROUP BY gender, category
    ORDER BY gender, item_count DESC
)

SELECT
    gender,
    most_common_item,
    item_count
FROM (
    SELECT
        gender,
        most_common_item,
        item_count,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY item_count DESC) AS ranking
    FROM GenderItemCounts
) AS RankedItems
WHERE ranking = 1;

--Customer who visited the malls the most--
SELECT TOP 1
    customer_id,
    COUNT(*) AS visit_count
FROM customer_shopping_data$
GROUP BY customer_id
ORDER BY visit_count DESC;

--Mean for the "age" column--
SELECT AVG(age) AS mean_age
FROM customer_shopping_data$;

--Mean for the "price" column--
SELECT AVG(price) AS mean_price
FROM customer_shopping_data$;

--Median for the "age" column--
SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) OVER () AS median_age
FROM customer_shopping_data$;


--Median for the "price" column--
SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER () AS median_price
FROM customer_shopping_data$;


--Mode for the "age" column--
SELECT
    age AS mode_age
FROM (
    SELECT age, COUNT(*) AS age_count
    FROM customer_shopping_data$
    GROUP BY age
    ORDER BY age_count DESC
    OFFSET 0 ROWS
    FETCH NEXT 1 ROWS ONLY
) AS MostCommonAge;

--Mode for the "price" column--
SELECT
    price AS mode_price
FROM (
    SELECT price, COUNT(*) AS price_count
    FROM customer_shopping_data$
    GROUP BY price
    ORDER BY price_count DESC
    OFFSET 0 ROWS
    FETCH NEXT 1 ROWS ONLY
) AS MostCommonPrice;

/* 
If you're encountering an "out-of-range" error when converting NVARCHAR to DATETIME, it might be due to invalid date values or a mismatch between the specified date format and the actual date values in your data.

Here are steps you can take to handle this situation:

Identify Invalid Date Values:
Run a query to identify rows with invalid date values:

sql
Copy code
SELECT invoice_date
FROM customer_shopping_data$
WHERE TRY_CONVERT(DATETIME, invoice_date, 120) IS NULL;
This query will return rows where the conversion to DATETIME is not successful, helping you identify problematic date values.

Update Invalid Dates:
If you find invalid dates, you need to correct or remove them. You can either correct the values or set them to NULL, depending on your data quality requirements.

sql
Copy code
UPDATE customer_shopping_data$
SET invoice_date = NULL
WHERE TRY_CONVERT(DATETIME, invoice_date, 120) IS NULL;
This will set invalid dates to NULL.

Convert to DATETIME:
After handling invalid dates, attempt to convert the column again:

sql
Copy code
ALTER TABLE customer_shopping_data$
ALTER COLUMN invoice_date DATETIME;

UPDATE customer_shopping_data$
SET invoice_date = CONVERT(DATETIME, invoice_date, 120); -- Use the appropriate date format code
Make sure to use the correct date format code for your data.

Verify the Changes:
Check a few rows to verify that the conversion has been successful:

sql
Copy code
SELECT TOP 10 invoice_date
FROM customer_shopping_data$;--
*/