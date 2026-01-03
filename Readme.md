# Zepto Product & Pricing Data Analysis (SQL)

## Overview
This project analyzes Zepto’s product and pricing data using SQL Server to
uncover revenue-driving categories, identify stock-out risks, and correct
pricing inconsistencies that could mislead business decisions.

The focus was on translating raw transactional data into actionable insights
for inventory and pricing optimization.

## Tools & Technologies
- SQL Server (data cleaning, transformations, analysis)
- Excel (cross-checking calculations and results)

## Business Questions Addressed
- Which products have the highest MRP and how often are they out of stock?
- Which categories contribute the most to estimated revenue?
- Are pricing values stored correctly for accurate reporting?

## Key Analysis Performed
- Ranked top products by MRP and identified frequent stock-out patterns
- Converted pricing data from paise to rupees to ensure accurate analytics
- Estimated category-wise revenue to highlight concentration risks
- Used filtering, aggregation, and window functions for insights

## Key Insights
- Several high-MRP products show recurring stock-outs, indicating potential
  revenue loss due to inventory gaps
- Pricing data stored in paise led to incorrect revenue calculations until
  normalized
- A small number of categories contribute a majority of estimated revenue,
  suggesting dependency risk and optimization opportunities

## How to Run
1. Execute table creation scripts from the `sql` folder
2. Run data cleaning and normalization queries
3. Execute analysis queries to reproduce insights
