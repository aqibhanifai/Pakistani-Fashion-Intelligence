-- ============================================================
-- PAKISTANI FASHION INTELLIGENCE
-- Step 3 - Complete PostgreSQL Project
--
-- Prepared by: Aqib Hanif
-- Assigned By: Mam Sumayyea Salahuddin
-- Institute: Arfa Karim Incubation Center, Peshawar
--
-- Project:
-- Fashion Brand Competitive Price Analytics
--
-- Brands:
-- 1. J.
-- 2. Maria.B
-- 3. Sana Safinaz
--
-- Purpose:
-- In this SQL file, I create my project database and table,
-- import my processed data, check data quality, and answer the
-- main business questions required for my Excel dashboard.
--
-- Important:
-- I am using PostgreSQL in VS Code.
-- My local PostgreSQL server is running on port 5433.
--
-- Input file:
-- 02_processed_fashion_products.csv
-- ============================================================



-- ============================================================
-- STEP 1 - CREATE THE PROJECT DATABASE
-- ============================================================

-- I run this section while I am connected to the default
-- PostgreSQL database named "postgres".
--
-- I only need to create this database once.

CREATE DATABASE fashion_analytics;


-- ------------------------------------------------------------
-- IMPORTANT - STOP HERE AFTER RUNNING STEP 1
-- ------------------------------------------------------------

-- After the database is created:
--
-- 1. I refresh the database list in VS Code.
-- 2. I open/connect to the new database:
--
--       fashion_analytics
--
-- 3. I run this check:
--
--       SELECT current_database();
--
-- The result should be:
--
--       fashion_analytics
--
-- PostgreSQL does not use "USE database_name" like MySQL.
-- Therefore, I reconnect my VS Code query to fashion_analytics
-- before continuing with Step 2.



-- ============================================================
-- STEP 2 - CONFIRM THE CURRENT DATABASE
-- ============================================================

-- I use this query to make sure I am working in the correct
-- project database before creating any tables.

SELECT current_database() AS connected_database;



-- ============================================================
-- STEP 3 - REMOVE AN OLD PROJECT TABLE IF IT EXISTS
-- ============================================================

-- I remove an older version of the table so I can rebuild the
-- project cleanly if I run this setup again.

DROP TABLE IF EXISTS fashion_products CASCADE;



-- ============================================================
-- STEP 4 - CREATE THE MAIN PRODUCT TABLE
-- ============================================================

-- This table follows the processed dataset created in my
-- Step 2 Jupyter Notebook.

CREATE TABLE fashion_products (

    product_id                  VARCHAR(30) PRIMARY KEY,

    snapshot_date               DATE,

    brand                       VARCHAR(50) NOT NULL,

    product_name                TEXT NOT NULL,

    sku                         VARCHAR(100),

    category                    VARCHAR(50) NOT NULL,

    subcategory                 VARCHAR(80),

    collection                  VARCHAR(120),

    original_price              NUMERIC(12,2) NOT NULL,

    sale_price                  NUMERIC(12,2) NOT NULL,

    discount_amount             NUMERIC(12,2) DEFAULT 0,

    discount_percent            NUMERIC(8,2) DEFAULT 0,

    sale_status                 VARCHAR(30),

    price_segment               VARCHAR(30),

    discount_band               VARCHAR(40),

    category_median_price       NUMERIC(12,2),

    price_index                 NUMERIC(10,2),

    availability                VARCHAR(30),

    currency                    VARCHAR(10),

    price_competitiveness_score NUMERIC(8,2),

    discount_strategy_score     NUMERIC(8,2),

    product_variety_score       NUMERIC(8,2),

    availability_score          NUMERIC(8,2),

    brand_intelligence_score    NUMERIC(8,2),

    product_url                 TEXT,

    source_website              VARCHAR(150),

    scrape_date                 DATE,

    -- I add simple checks to prevent impossible prices.
    CONSTRAINT chk_original_price_positive
        CHECK (original_price > 0),

    CONSTRAINT chk_sale_price_positive
        CHECK (sale_price > 0),

    CONSTRAINT chk_sale_not_above_original
        CHECK (sale_price <= original_price),

    CONSTRAINT chk_discount_percent
        CHECK (discount_percent BETWEEN 0 AND 100)
);



-- ============================================================
-- STEP 5 - CHECK THAT THE TABLE WAS CREATED
-- ============================================================

-- At this point, the table should exist but should still have
-- zero rows because I have not imported the CSV yet.

SELECT
    COUNT(*) AS rows_before_import
FROM fashion_products;



-- ============================================================
-- STEP 6 - IMPORT MY PROCESSED CSV
-- ============================================================

-- My input file is:
--
--     02_processed_fashion_products.csv
--
-- RECOMMENDED METHOD IN VS CODE DATABASE CLIENT:
--
-- 1. Expand fashion_analytics.
-- 2. Find the fashion_products table.
-- 3. Use the table Import / CSV Import option if available.
-- 4. Select:
--
--        02_processed_fashion_products.csv
--
-- 5. CSV settings:
--
--        Format     = CSV
--        Header     = Yes
--        Delimiter  = ,
--        Encoding   = UTF-8
--
-- 6. Import the file.
--
-- ------------------------------------------------------------
-- OPTIONAL METHOD IF I USE PostgreSQL psql TERMINAL
-- ------------------------------------------------------------
--
-- I can use the following command in psql:
--
-- \copy fashion_products
-- FROM 'C:/FULL/PATH/02_processed_fashion_products.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
--
-- I do NOT run \copy as normal SQL in the VS Code query editor
-- because it is a psql command.



-- ============================================================
-- STEP 7 - VERIFY THE CSV IMPORT
-- ============================================================

-- My current project dataset contains 281 scraped products.
-- I check the imported row count after importing the CSV.

SELECT
    COUNT(*) AS total_imported_products
FROM fashion_products;


-- I check how many products belong to each brand.

SELECT
    brand,
    COUNT(*) AS products
FROM fashion_products
GROUP BY brand
ORDER BY products DESC;


-- My current dataset should be close to:
--
-- J.             = 100
-- Maria.B        = 100
-- Sana Safinaz   = 81
--
-- Total          = 281



-- ============================================================
-- STEP 8 - BASIC DATA QUALITY CHECKS
-- ============================================================

-- I check whether any required product IDs are missing.

SELECT
    COUNT(*) AS missing_product_ids
FROM fashion_products
WHERE product_id IS NULL;


-- I check whether duplicate product URLs exist.

SELECT
    brand,
    product_url,
    COUNT(*) AS duplicate_count
FROM fashion_products
GROUP BY brand, product_url
HAVING COUNT(*) > 1;


-- I check whether any sale price is higher than the original
-- price. My processed dataset should return zero rows.

SELECT
    product_id,
    brand,
    product_name,
    original_price,
    sale_price
FROM fashion_products
WHERE sale_price > original_price;


-- I check the available project categories.

SELECT DISTINCT
    category
FROM fashion_products
ORDER BY category;



-- ============================================================
-- STEP 9 - OVERALL PROJECT KPI SUMMARY
-- ============================================================

-- This query gives me the main KPI numbers for the top row of
-- my Excel dashboard.

SELECT
    COUNT(DISTINCT brand) AS total_brands,

    COUNT(*) AS total_products,

    COUNT(DISTINCT category) AS total_categories,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY sale_price)::NUMERIC,
        2
    ) AS median_price,

    ROUND(
        AVG(discount_percent),
        2
    ) AS average_discount_percent,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN sale_status = 'On Sale' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS sale_products_percent

FROM fashion_products;



-- ============================================================
-- STEP 10 - BUSINESS QUESTION 1
-- WHICH BRAND HAS THE LOWEST MEDIAN PRICE?
-- ============================================================

-- I use median price because expensive fashion outliers can
-- make a simple average less representative.

SELECT
    brand,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY sale_price)::NUMERIC,
        2
    ) AS median_price

FROM fashion_products

GROUP BY brand

ORDER BY median_price ASC;



-- ============================================================
-- STEP 11 - BUSINESS QUESTION 2
-- WHICH BRAND HAS THE HIGHEST AVERAGE DISCOUNT?
-- ============================================================

SELECT
    brand,

    ROUND(
        AVG(discount_percent),
        2
    ) AS average_discount_percent

FROM fashion_products

GROUP BY brand

ORDER BY average_discount_percent DESC;



-- ============================================================
-- STEP 12 - BUSINESS QUESTION 3
-- WHAT PERCENTAGE OF EACH BRAND'S PRODUCTS ARE ON SALE?
-- ============================================================

-- I use CASE WHEN to classify the products inside my SQL query.

SELECT
    brand,

    COUNT(*) AS total_products,

    SUM(
        CASE
            WHEN sale_status = 'On Sale' THEN 1
            ELSE 0
        END
    ) AS sale_products,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN sale_status = 'On Sale' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS sale_product_percent

FROM fashion_products

GROUP BY brand

ORDER BY sale_product_percent DESC;



-- ============================================================
-- STEP 13 - BUSINESS QUESTION 4
-- WHICH CATEGORIES HAVE THE MOST PRODUCTS?
-- ============================================================

SELECT
    category,
    COUNT(*) AS products

FROM fashion_products

GROUP BY category

ORDER BY products DESC;



-- ============================================================
-- STEP 14 - BRAND x CATEGORY PRODUCT MIX
-- ============================================================

-- I use this result for my Brand x Category heatmap in Excel.

SELECT
    brand,
    category,
    COUNT(*) AS product_count

FROM fashion_products

GROUP BY
    brand,
    category

ORDER BY
    brand,
    product_count DESC;



-- ============================================================
-- STEP 15 - BRAND x CATEGORY MEDIAN PRICE
-- ============================================================

-- This helps me compare brands inside the same product category.

SELECT
    brand,
    category,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY sale_price)::NUMERIC,
        2
    ) AS median_sale_price

FROM fashion_products

GROUP BY
    brand,
    category

ORDER BY
    category,
    median_sale_price;



-- ============================================================
-- STEP 16 - PRICE SEGMENT DISTRIBUTION
-- ============================================================

-- My Step 2 Python notebook created four price groups:
--
-- Budget
-- Mid Range
-- Premium
-- Luxury
--
-- I calculate both the count and percentage for each brand.

SELECT
    brand,
    price_segment,

    COUNT(*) AS products,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY brand
        ),
        2
    ) AS percentage_of_brand

FROM fashion_products

GROUP BY
    brand,
    price_segment

ORDER BY
    brand,
    products DESC;



-- ============================================================
-- STEP 17 - AVAILABILITY BY BRAND
-- ============================================================

-- This query supports the Availability by Brand visual.

SELECT
    brand,
    availability,

    COUNT(*) AS products,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY brand
        ),
        2
    ) AS availability_percent

FROM fashion_products

GROUP BY
    brand,
    availability

ORDER BY
    brand,
    products DESC;



-- ============================================================
-- STEP 18 - TOP 10 DEALS BY SAVINGS
-- ============================================================

-- I rank products using the amount of money saved.

SELECT
    product_id,
    brand,
    product_name,
    category,
    original_price,
    sale_price,
    discount_amount,
    discount_percent

FROM fashion_products

WHERE discount_amount > 0

ORDER BY
    discount_amount DESC,
    discount_percent DESC

LIMIT 10;



-- ============================================================
-- STEP 19 - TOP 5 DISCOUNTED PRODUCTS INSIDE EACH BRAND
-- ============================================================

-- I use a CTE and ROW_NUMBER() to demonstrate a PostgreSQL
-- window function.

WITH ranked_products AS (

    SELECT
        product_id,
        brand,
        product_name,
        category,
        sale_price,
        discount_amount,
        discount_percent,

        ROW_NUMBER() OVER (
            PARTITION BY brand
            ORDER BY
                discount_percent DESC,
                discount_amount DESC
        ) AS row_num

    FROM fashion_products
)

SELECT
    product_id,
    brand,
    product_name,
    category,
    sale_price,
    discount_amount,
    discount_percent

FROM ranked_products

WHERE row_num <= 5

ORDER BY
    brand,
    row_num;



-- ============================================================
-- STEP 20 - AFFORDABILITY RANKING
-- ============================================================

-- I first calculate median brand prices in a CTE.
-- Then I use RANK() to rank the brands from lowest to highest.

WITH brand_price AS (

    SELECT
        brand,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY sale_price
        ) AS median_price

    FROM fashion_products

    GROUP BY brand
)

SELECT
    brand,

    ROUND(
        median_price::NUMERIC,
        2
    ) AS median_price,

    RANK() OVER (
        ORDER BY median_price ASC
    ) AS affordability_rank

FROM brand_price

ORDER BY affordability_rank;



-- ============================================================
-- STEP 21 - AVERAGE PRICE INDEX BY BRAND
-- ============================================================

-- Price Index compares a product with the median price of its
-- own category.
--
-- Below 100 = cheaper than category median
-- Around 100 = close to category median
-- Above 100 = more expensive than category median

SELECT
    brand,

    ROUND(
        AVG(price_index),
        2
    ) AS average_price_index

FROM fashion_products

GROUP BY brand

ORDER BY average_price_index ASC;



-- ============================================================
-- STEP 22 - BRAND INTELLIGENCE SCORE
-- ============================================================

-- I created this score in Python using:
--
-- Price Competitiveness = 30%
-- Discount Strategy     = 25%
-- Product Variety       = 25%
-- Availability          = 20%
--
-- The score is already stored in my processed dataset.

SELECT DISTINCT
    brand,

    ROUND(
        price_competitiveness_score,
        2
    ) AS price_competitiveness_score,

    ROUND(
        discount_strategy_score,
        2
    ) AS discount_strategy_score,

    ROUND(
        product_variety_score,
        2
    ) AS product_variety_score,

    ROUND(
        availability_score,
        2
    ) AS availability_score,

    ROUND(
        brand_intelligence_score,
        2
    ) AS brand_intelligence_score

FROM fashion_products

ORDER BY brand_intelligence_score DESC;



-- ============================================================
-- STEP 23 - COMPLETE BRAND PERFORMANCE SUMMARY
-- ============================================================

-- I combine the main brand-level measures into one result.
-- This is useful for my dashboard and final business insights.

SELECT
    brand,

    COUNT(*) AS total_products,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY sale_price
        )::NUMERIC,
        2
    ) AS median_price,

    ROUND(
        AVG(sale_price),
        2
    ) AS average_price,

    ROUND(
        AVG(discount_percent),
        2
    ) AS average_discount_percent,

    COUNT(
        DISTINCT category
    ) AS categories,

    SUM(
        CASE
            WHEN sale_status = 'On Sale' THEN 1
            ELSE 0
        END
    ) AS sale_products,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN sale_status = 'On Sale' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS sale_product_percent,

    ROUND(
        MAX(brand_intelligence_score),
        2
    ) AS brand_intelligence_score

FROM fashion_products

GROUP BY brand

ORDER BY brand_intelligence_score DESC;



-- ============================================================
-- STEP 24 - CATEGORY SUMMARY
-- ============================================================

-- This gives me price and discount information for each main
-- product category.

SELECT
    category,

    COUNT(*) AS products,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY sale_price
        )::NUMERIC,
        2
    ) AS median_price,

    ROUND(
        AVG(discount_percent),
        2
    ) AS average_discount_percent

FROM fashion_products

GROUP BY category

ORDER BY products DESC;



-- ============================================================
-- STEP 25 - DISCOUNT BAND DISTRIBUTION
-- ============================================================

-- This query helps me understand whether products have low,
-- medium, high, or very high discounts.

SELECT
    discount_band,
    COUNT(*) AS products,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_products

FROM fashion_products

GROUP BY discount_band

ORDER BY products DESC;



-- ============================================================
-- STEP 26 - SALE PRICE VS DISCOUNT DATA
-- ============================================================

-- I use these fields for the Excel scatter plot:
--
-- X-axis = Sale Price
-- Y-axis = Discount %
-- Color  = Brand

SELECT
    product_id,
    brand,
    product_name,
    category,
    sale_price,
    discount_percent

FROM fashion_products

ORDER BY
    brand,
    sale_price;



-- ============================================================
-- STEP 27 - CREATE A VIEW FOR MY EXCEL DASHBOARD
-- ============================================================

-- I create a reusable PostgreSQL view containing the clean
-- fields required by my final dashboard.

CREATE OR REPLACE VIEW vw_fashion_dashboard AS

SELECT
    product_id,
    snapshot_date,
    brand,
    product_name,
    category,
    subcategory,
    collection,
    original_price,
    sale_price,
    discount_amount,
    discount_percent,
    sale_status,
    price_segment,
    discount_band,
    category_median_price,
    price_index,
    availability,
    price_competitiveness_score,
    discount_strategy_score,
    product_variety_score,
    availability_score,
    brand_intelligence_score

FROM fashion_products;



-- ============================================================
-- STEP 28 - TEST THE DASHBOARD VIEW
-- ============================================================

-- I display the first ten records to confirm my view works.

SELECT *
FROM vw_fashion_dashboard
LIMIT 10;



-- ============================================================
-- STEP 29 - CREATE SIMPLE DATABASE INDEXES
-- ============================================================

-- These indexes make common filtering fields easier for
-- PostgreSQL to search when the dataset becomes larger.

CREATE INDEX IF NOT EXISTS idx_fashion_brand
ON fashion_products (brand);


CREATE INDEX IF NOT EXISTS idx_fashion_category
ON fashion_products (category);


CREATE INDEX IF NOT EXISTS idx_fashion_price_segment
ON fashion_products (price_segment);


CREATE INDEX IF NOT EXISTS idx_fashion_sale_status
ON fashion_products (sale_status);


CREATE INDEX IF NOT EXISTS idx_fashion_availability
ON fashion_products (availability);



-- ============================================================
-- STEP 30 - FINAL DATABASE OBJECT CHECK
-- ============================================================

-- I confirm that my table and dashboard view exist.

SELECT
    table_schema,
    table_name,
    table_type

FROM information_schema.tables

WHERE table_schema = 'public'
  AND table_name IN (
      'fashion_products',
      'vw_fashion_dashboard'
  )

ORDER BY table_name;



-- ============================================================
-- STEP 31 - FINAL PROJECT RESULT
-- ============================================================

-- This is the final overall summary I can show in class.

SELECT
    COUNT(DISTINCT brand) AS brands,

    COUNT(*) AS products,

    COUNT(DISTINCT category) AS categories,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY sale_price
        )::NUMERIC,
        2
    ) AS median_price,

    ROUND(
        AVG(discount_percent),
        2
    ) AS average_discount_percent,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN sale_status = 'On Sale' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS sale_products_percent

FROM fashion_products;



-- ============================================================
-- END OF STEP 3 - POSTGRESQL
-- ============================================================

-- What I have covered in this SQL file:
--
-- CREATE DATABASE
-- CREATE TABLE
-- CSV import workflow
-- Data validation
-- SELECT
-- WHERE
-- GROUP BY
-- ORDER BY
-- CASE WHEN
-- Aggregate functions
-- Median using PERCENTILE_CONT
-- CTE
-- ROW_NUMBER()
-- RANK()
-- Window functions
-- PostgreSQL VIEW
-- INDEXES
-- Business analysis
-- Dashboard preparation
--
-- My next project step is to use these results in my
-- interactive Microsoft Excel dashboard.
-- ============================================================
