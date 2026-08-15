# E-Commerce Sales & Logistics Analysis

A business-focused SQL and dashboard project analyzing sales performance, delivery efficiency, and customer satisfaction using the Olist Brazilian e-commerce dataset.

## Project Overview
This project explores how e-commerce performance is shaped by product mix, regional logistics, and customer experience. The analysis answers three practical business questions:

- Which product categories generate the most revenue?
- Which states have the biggest fulfillment and freight challenges?
- At what delivery delay threshold does customer satisfaction noticeably drop?

By combining PostgreSQL analysis with an executive Excel dashboard, this project turns raw transaction data into business insight.

## Why this project matters
E-commerce companies do not win only by selling more products. They win by balancing:

- profitable categories
- efficient delivery operations
- customer trust and satisfaction

This project shows how those factors connect in a real-world retail environment.

## Key Findings
- Revenue is concentrated in a small set of high-performing product categories.
- Delivery performance varies significantly by state, with large gaps in lead time and freight cost.
- Long delays strongly correlate with lower review scores, especially after the 4–7 day delay range.
- The project highlights a clear customer experience risk threshold where delays begin to damage satisfaction materially.

## Tech Stack
- PostgreSQL for data cleaning and aggregation
- SQL queries for category, logistics, and review analysis
- Microsoft Excel for executive dashboard reporting
- Olist public Brazilian e-commerce dataset

## Repository Structure
```text
├── sql/
│   └── ecommerce_analysis.sql        # SQL analysis for category, logistics, and CSAT
├── dashboard/
│   └── Sales_Logistics_Dashboard.xlsx # Executive Excel dashboard
├── assets/
│   ├── category_performance.png
│   ├── geographic_logistics.png
│   └── logistics_reviews.png
├── README.md
└── .gitignore
```

## Business Questions Answered
### 1. Which categories drive the most value?
The analysis compares category revenue, order volume, and average order value to identify both high-volume and high-value product segments.

### 2. Where are the biggest logistics bottlenecks?
The project measures delivery time and freight cost by customer state to highlight performance gaps in regional operations.

### 3. How do delays affect customer satisfaction?
The analysis segments orders by delivery performance and measures review score distribution, showing how late deliveries lead to worse customer sentiment.

## SQL Analysis Highlights
The SQL workflow covers three main areas:

### Query 1: Category Yield & Revenue Analysis
This query cleans translated product categories, standardizes missing category names, and calculates:

- total orders
- gross revenue
- average order value

It uses joins, category mapping logic, and aggregation to compare category performance.

### Query 2: Regional Fulfillment Analysis
This query evaluates:

- order volume by state
- total revenue by state
- average freight cost
- average delivery lead time

It helps identify which regions are generating demand but suffering from transportation inefficiency.

### Query 3: Delivery Delay vs. Review Score Analysis
This query classifies orders by delivery performance and measures rating distribution by delay tier. It highlights how late deliveries worsen customer sentiment and contribute to poor review outcomes.

## Dashboard Snapshot
The dashboard includes executive-level views for:

- category performance
- regional logistics comparison
- delivery delay impact on reviews

### Category Performance
![Category Performance Chart](assets/category_performance.png)

### Geographic Logistics
![Geographic Logistics Combo Chart](assets/geographic_logistics.png)

### Delivery Delay vs. Reviews
![Logistics Delays Stacked Bar Chart](assets/logistics_reviews.png)

## Key Insights from the Dashboard
- High-value categories generate meaningful profit per order even when they are not the largest volume drivers.
- Remote and less-connected states face noticeably longer delivery cycles and elevated logistics costs.
- Delivery delays create a strong negative effect on review scores, especially once orders move beyond a moderate delay threshold.
- Customer satisfaction falls steeply when delivery performance becomes visibly late.

## Recommended Actions
1. Improve fulfillment in high-cost or remote regions by optimizing regional distribution and delivery partnerships.
2. Proactively communicate with customers when delays begin to exceed expected thresholds.
3. Prioritize fast, reliable shipping for categories with strong margin potential.
4. Focus promotions on categories that produce better value per order while maintaining delivery efficiency.

## How to Run
1. Import the Olist dataset into PostgreSQL.
2. Load the relevant tables such as orders, order_items, customers, products, category_translation, and order_reviews.
3. Open and run the queries in [sql/ecommerce_analysis.sql](sql/ecommerce_analysis.sql).
4. Review the Excel dashboard in the dashboard folder for a business-ready summary.

## Project Impact
This project demonstrates practical analytical thinking: it moves beyond descriptive statistics and turns data into operational recommendations. It is a strong example of using data to answer real business problems rather than just producing charts for the sake of charts.

## Author
Huseyn

Computer Science Student
