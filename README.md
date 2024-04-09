# AtliQ-Technologies_SQL

# **Brief Intro:**
-- AtliQ Hardwares is a consumer goods electronics company who manufacture computer hardwares, peripherals, networking & storage devices, laptops (business/gaming), etc. and have their operations in various countries and a warehouse setup in India.
-- One of their goals is to expand their warehouse and business across suitable countries to generate more revenue and gain market share.
-- Their business is growing rapidly and they still rely on excel files for data analytics, thus there is a rise in the usage of databases in AtliQ tech.
-- Excel files are hard to consume and not effective in generating insights.
-- Also due to the lack of effective analytics the company faced a major loss in Latin America. 
-- Senior executives of this company have decided to invest in a data analytics project and have assigned a team for this work, my work starts here.

# **Why Databases are better than Excel files:**
1. Data Integrity and Consistency: SQL databases enforce data integrity through features like primary keys, foreign keys, and constraints, ensuring that data remains consistent and accurate. Excel files lack such mechanisms, making them prone to errors, inconsistencies, and data corruption.

2. Scalability and Performance: SQL databases are designed to handle large volumes of data efficiently, offering better scalability and performance compared to Excel files. With optimized indexing, query optimization, and support for concurrent transactions, SQL databases can handle complex data operations and high concurrency requirements, which Excel files struggle with as they are limited by their file size and processing capabilities.


# **Problem statement and the resultant tasks:**
*Task 1:* 
--> Generate a report of individual product sales aggregated on a monthly basis at the prod code level for Croma India FY-2021
                                         OR 
    Generate a Gross Sales report for the FY21 for Croma India customer
       
--> The report shall have the following fields:
    --> Month
    --> Product Name
    --> Variant
    --> Qty sold
    --> Gross price per item
    --> Total gross price (product of Gross price per item and Sold quantity)


# **How I achieved the task?:**

--> Created a user-defined function to generate Fiscal Years for AtliQ tech. (AtliQ's fiscal year starts in September and ends in August)
    
  ![Fiscal year function](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/72858e1c-f5d3-46f2-9ae5-0600fa23524e)

--> In addition, being future-proof, I created user-defined Functions for fiscal month and fiscal quarters as well.

![Fiscal quarter function](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/3a5e9139-614f-41cf-a5d6-2f1b840015de)

![Fiscal month function](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/bf8dbdaf-7ab6-47d8-bea1-c0c633d4991e)

--> To get, product_code, product and variant columns, I did a Join on dim_product table and to get Gross price did a Join on fact_gross_price table with fact_sales_monthly 
    table
--> Then, derived a calculated column post-joining tables named Tota_Gross_Price by the product of sold_quantity and gross_price
--> Given the task conditions to generate Gross sales report for Croma India and FY-2021, applied WHERE clauses for Croma customer_code and FY 2021.

![Croma India FY21 GS report](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/12086c2e-e8bc-480e-a6b1-c5d82605da66)







*Task 2:*
--> Generate an aggregated monthly sales report for Croma India customer so that we can track how much sales is generated by this customer for AtliQ,
    so that we can manage our relationships accordingly.
--> Keep the following fields:
    --> Month
    --> Total gross sales for that month from Croma India

# **How I achieved the task?:**
 --> Joined fact_gross_price with fact_sales_monthly
 --> Filtered the result for Croma India customer_code and used the user-defined function fiscal_month to generate the said report.

    
  ![Monthly sales report Croma India](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/c2304e8c-d7c0-4f64-bfac-f08223b6c2eb)







*Task 3:*
--> Generate a yearly report for Croma India having these 2 fields:
    --> Fiscal Year
    --> Total Gross Sales amount in that year from Croma
    
# **How I achieved the task?:**
--> Joined fact_gross_price with fact_sales_monthly to get gross_price, from the result set calculated Gross sales
--> Filtered the result for Croma India customer_code and rounded off the gross sales value to millions for better readability


![Yearly GS report Croma India](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/7fffdba7-053d-40d7-bc2e-2f09be0d3743)







*Task 4:*
--> Generating monthly gross sales report for any customer for the convenient usage of stakeholders, managers, etc.

# **How I achieved the task?:**
--> Developed a stored procedure to enable the users to generate Gross sales reports for any desired customer and fiscal years
--> Gave the inputs for the user to type in the desired customer code and Fiscal year.



![stored_proc](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/770f4b5a-841c-4e09-80ad-fbc3f6f4a614)








--> There might be a customer who has many customer_codes, we can use find_in_set() function there, cast it as TEXT data type and we can get the result set
--> I've crafted a separate stored procedure to get gross sales report for Amazon ( because Amazon has multiple customer_codes)



![Stored+proc Amazon](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/bff9de99-b539-486e-b909-2bbbb14fb107)





![GS_monthly_Girias_stored_proc](https://github.com/JoysonPrince/AtliQ-Technologies_SQL/assets/137388224/7dcc4854-6211-48ef-ac2c-6161c79f963c)

