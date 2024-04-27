# Generate a report of individual product sales aggregated on a monthly basis at the prod code level for Croma India FY-2021/
# Gross Sales report for FY21 for Croma India
/* The report shall have the following fields:-
--> Month
--> Product Name
--> Variant
--> Qty sold
--> Gross price per item
--> Total gross price */
# I will generate the report without using UD-F
# Step 1: Find the customer code for Croma India
SELECT * FROM dim_customer
WHERE customer LIKE "%croma%"; # Customer code for Croma India is "90002002"

# Step 2: Getting FY21 dates for Croma India without using UD-F
SELECT FSM.date, MONTHNAME(date_add(date, INTERVAL 4 MONTH)) AS Fiscal_Month, DP.product, DP.variant, FSM.sold_quantity,
FGP.gross_price, ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price
FROM fact_sales_monthly FSM
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = YEAR(date_add(FSM.date, INTERVAL 4 MONTH))
WHERE FSM.customer_code = 90002002 AND YEAR(date_add(date, INTERVAL 4 MONTH)) = 2021
ORDER BY Total_Gross_Price DESC;
# Now, we get dates from Sep-2020 to Aug-2021, i.e FY21 = Sep 2020 to Aug 2021

# Now, using UD-F to generate the same report
SELECT FSM.date, MONTHNAME(date_add(FSM.date, INTERVAL 4 MONTH)) AS Fiscal_Month, FSM.product_code, DP.product, DP.variant, 
FSM.sold_quantity, FGP.gross_price, ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price
FROM fact_sales_monthly FSM
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FY(FSM.date)
WHERE FSM.customer_code = 90002002 AND FY(date) = 2021 # used UD-F here
ORDER BY Total_Gross_Price DESC;

# Getting the same report for a particular quarter
SELECT FSM.date, MONTHNAME(date_add(FSM.date, INTERVAL 4 MONTH)) AS Fiscal_Month, FSM.product_code, DP.product, DP.variant, 
FSM.sold_quantity, ROUND(FGP.gross_price,2) AS Gross_price, ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price
FROM fact_sales_monthly FSM
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FY(FSM.date)
WHERE FSM.customer_code = 90002002 AND FY(date) = 2021 AND fiscal_quarters(date) = "Quarter-1"
ORDER BY Total_Gross_Price DESC;


# Aggregated monthly sales report for Croma India
SELECT FSM.date, MONTHNAME(date_add(FSM.date, INTERVAL 4 MONTH)) AS Fiscal_Month, FSM.product_code, FSM.sold_quantity, 
ROUND(FGP.gross_price,2) AS Gross_price, ROUND(SUM((FGP.gross_price*FSM.sold_quantity)),2) AS Total_Gross_Price
FROM fact_sales_monthly FSM
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FY(FSM.date)
WHERE FSM.customer_code = 90002002
GROUP BY FSM.date
ORDER BY FSM.date ASC;

# Generate a yearly report for Croma India where there are two columns
/* 1. Fiscal Year
   2. Total Gross Sales amount In that year from Croma */
SELECT FY(date) AS Fiscal_Year, FSM.product_code, FSM.sold_quantity, 
ROUND(FGP.gross_price,2) AS Gross_price, ROUND(SUM((FGP.gross_price*FSM.sold_quantity))/1000000,2) AS Annual_GS_Millions
FROM fact_sales_monthly FSM
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FY(FSM.date)
WHERE FSM.customer_code = 90002002
GROUP BY Fiscal_Year # OR GROUP BY FY(date)
ORDER BY Fiscal_Year DESC; # OR ORDER BY FY(date)
--- 
SELECT YEAR(DATE_ADD(FSM.date, INTERVAL 4 MONTH)) AS Fiscal_Year, FSM.product_code, FSM.sold_quantity, 
ROUND(FGP.gross_price,2) AS Gross_price, ROUND(SUM((FGP.gross_price*FSM.sold_quantity))/1000000,2) AS Annual_GS_Millions
FROM fact_sales_monthly FSM
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FY(FSM.date)
WHERE FSM.customer_code = 90002002
GROUP BY Fiscal_Year
ORDER BY Fiscal_Year DESC;
---

# Aggregated monthly sales report for Amazon India
-- Here, Amazon India has 2 different customer codes
SELECT FSM.date, MONTHNAME(date_add(FSM.date, INTERVAL 4 MONTH)) AS Fiscal_Month, FSM.product_code, DC.customer_code,
ROUND(SUM((FGP.gross_price*FSM.sold_quantity)),2) AS Total_Gross_Price
FROM fact_sales_monthly FSM
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FY(FSM.date)
JOIN dim_customer DC ON DC.customer_code = FSM.customer_code
WHERE FSM.customer_code IN (90002008, 90002016)
GROUP BY FSM.date
ORDER BY FSM.date ASC;

---
# Stored proc to determine market badge
SELECT FY(FSM.date) AS Fiscal_Year, DC.market, DC.region, SUM(FSM.sold_quantity) AS Total_sold_Qty_mn
FROM fact_sales_monthly FSM
JOIN dim_customer DC
ON DC.customer_code = FSM.customer_code
WHERE FY(FSM.date) = 2021 AND DC.market = "India"
GROUP BY DC.market;
---

# Customer performance report
# Query optimization 1:
# Creating a date table to reduce using FY function to retrieve fiscal year
EXPLAIN ANALYZE
SELECT FSM.date, DP.product, DP.variant, FSM.sold_quantity, ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price,
FPID.pre_invoice_discount_pct
FROM fact_sales_monthly FSM
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_pre_invoice_deductions FPID ON FPID.customer_code = FSM.customer_code AND FPID.fiscal_year = FY(FSM.date)
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FY(FSM.date)
WHERE FY(FSM.date) = 2021
ORDER BY Total_Gross_Price DESC
LIMIT 1000000;
---
/* The above query gave the results in 7 seconds. hence created dim_Date table to optimize the query.
Will recheck how effective was the said optimization */
EXPLAIN ANALYZE
SELECT FSM.date, DP.product, DP.variant, FSM.sold_quantity, ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price,
FPID.pre_invoice_discount_pct
FROM fact_sales_monthly FSM
JOIN dim_date DD ON DD.calendar_date = FSM.date
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_pre_invoice_deductions FPID ON FPID.customer_code = FSM.customer_code AND FPID.fiscal_year = DD.fiscal_year
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = DD.fiscal_year
WHERE DD.fiscal_year = 2020
ORDER BY Total_Gross_Price DESC
LIMIT 1000000;
# This took only a second to retrieve the data, thus optimization successful
---
# Query optimization 2:
# Creating a fiscal_year column within FSM, to avoid using FY function, therefore the above query can be further optimized as,
EXPLAIN ANALYZE
SELECT FSM.date, DP.product, DP.product_code, DP.variant, FSM.sold_quantity, 
ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price, FPID.pre_invoice_discount_pct
FROM fact_sales_monthly FSM
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_pre_invoice_deductions FPID ON FPID.customer_code = FSM.customer_code AND FPID.fiscal_year = FSM.fiscal_year
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FSM.fiscal_year
WHERE FSM.fiscal_year = 2021
ORDER BY Total_Gross_Price DESC
LIMIT 1000000;
---

# CTE's and VIEWS:
# We have pre_inv discounts now. To calculate NIS, [GP-(GP*Pre-ID)], use CTE's
WITH CTE_NIS AS (
SELECT FSM.date, DP.product, DP.product_code, DP.variant, FSM.sold_quantity, 
ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price, FPID.pre_invoice_discount_pct
FROM fact_sales_monthly FSM
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_pre_invoice_deductions FPID ON FPID.customer_code = FSM.customer_code AND FPID.fiscal_year = FSM.fiscal_year
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FSM.fiscal_year
WHERE FSM.fiscal_year = 2021
ORDER BY Total_Gross_Price DESC
LIMIT 1000000)
SELECT *, ROUND((Total_Gross_Price - (Total_Gross_Price*pre_invoice_discount_pct)),2) AS NIS
FROM CTE_NIS;
/* Now, to get net sales, we need to do a join on post_inv table & then apply post_inv discounts to NIS.
To arrive at that we need another CTE and the code gets longer (Thus use VIEWS) */
-- Created a pre_invoice_view
SELECT *, ROUND((Total_Gross_Price - (Total_Gross_Price*pre_invoice_discount_pct)),2) AS NIS, 
# OR use (1-pre_invoice_discount_pct)*Total_Gross_Price
(FPOD.discounts_pct + FPOD.other_deductions_pct) AS post_invoice_discount_pct
FROM pre_invoice_view PIV
JOIN fact_post_invoice_deductions FPOD
ON FPOD.date = PIV.date AND FPOD.customer_code = PIV.customer_code AND FPOD.product_code = PIV.product_code;
# To get NS, either use CTE or create another VIEW
---
SELECT *, (NIS - (NIS * post_invoice_discount_pct)) AS Net_Sales
FROM post_invoice_view;
# Using the codes from line 162,163, created a new VIEW for Net Sales, just in case

SELECT * FROM net_Sales_view;
# From this virtual table (i.e VIEW), we can get Top 5 Markets by Net Sales for FY-2021
SELECT fiscal_year, market, ROUND(SUM(net_sales)/1000000,2) AS Total_Net_sales_million
FROM net_Sales_view
WHERE fiscal_year = 2021
GROUP BY market
ORDER BY Total_Net_sales_million DESC
LIMIT 5;
---
# Top-5 Customers by Net Sales for FY-2021
SELECT fiscal_year, customer, ROUND(SUM(net_sales)/1000000,2) AS Total_Net_sales_million
FROM net_Sales_view
WHERE fiscal_year = 2021
GROUP BY customer
ORDER BY Total_Net_sales_million DESC
LIMIT 5;
---
# Top-N Products by Net Sales for FY-2021
SELECT fiscal_year, product, ROUND(SUM(net_sales)/1000000,2) AS Total_Net_sales_million
FROM net_Sales_view
WHERE fiscal_year = 2021
GROUP BY product
ORDER BY Total_Net_sales_million DESC
LIMIT 5;
---
# Bottom-N Products by Net Sales for FY-2021
SELECT fiscal_year, product, ROUND(SUM(net_sales)/1000000,2) AS Total_Net_sales_million
FROM net_Sales_view
WHERE fiscal_year = 2021
GROUP BY product
ORDER BY Total_Net_sales_million ASC
LIMIT 5;

---
# Creating a view for Gross Sales
SELECT FSM.date, FSM.fiscal_year, DC.customer_code, DC.customer, DC.market, DP.product, DP.variant, FSM.sold_quantity, 
FGP.gross_price, ROUND((FGP.gross_price*FSM.sold_quantity),2) AS Total_Gross_Price
FROM fact_sales_monthly FSM
JOIN dim_customer DC ON DC.customer_code = FSM.customer_code
JOIN dim_product DP ON DP.product_code = FSM.product_code
JOIN fact_gross_price FGP ON FGP.product_code = FSM.product_code AND FGP.fiscal_year = FSM.fiscal_year
ORDER BY Total_Gross_Price DESC;

