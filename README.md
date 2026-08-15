# 📊 E-Commerce Sales & Logistics Analysis (Olist Dataset)

## 📌 Project Overview
This project provides an end-to-end analytical deep dive into e-commerce performance, regional fulfillment efficiency, and customer satisfaction (CSAT) using Brazilian e-commerce transaction data.

By combining **PostgreSQL** for complex aggregations and **Microsoft Excel** for executive reporting, this analysis identifies revenue concentration drivers, regional logistics bottlenecks, and the precise impact of delivery delays on customer review scores.

---

## 🎯 Business Problem & Key Questions
1. **Category Yield vs. Volume:** Which product categories generate the highest revenue, and how do high-volume categories compare to high-AOV (Average Order Value) niches?
2. **Geographic Logistics Disparities:** How do delivery lead times and freight costs vary across Brazilian states relative to revenue concentration?
3. **Logistics & CSAT Sensitivity:** At what threshold do delivery delays severely trigger 1-star reviews and drop overall customer satisfaction?

---

## 🛠️ Tech Stack & Tools Used
* **Database / SQL:** PostgreSQL (CTEs, Conditional Aggregations, Date Arithmetic, Explicit Type Casting, Joins, Aggregations, NULL Handling)
* **Data Visualization & Dashboarding:** Microsoft Excel (KPI Scorecards, Dual-Axis Combo Charts, 100% Stacked Bar Charts)
* **Dataset:** Olist Brazilian E-Commerce Public Dataset (Kaggle) [https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce]

---

## 📂 Repository Structure
```text
├── sql/
│   └── ecommerce_analysis.sql         # SQL queries for category yield, geographic lead times, & CSAT
├── dashboard/
│   └── Sales_Logistics_Dashboard.xlsx # 4-sheet formatted Excel executive workbook
└── README.md                          # Project documentation & executive summary

```

---

## 🔍 SQL Query Breakdown & Analytical Approach

### Query 1: Product Category Yield Analysis

* **Objective:** Clean and translate raw product category names while calculating gross revenue, order volume, and AOV per category.
* **Key SQL Techniques:** `LEFT JOIN` for English category translation, `COALESCE` with `CASE WHEN` to patch missing mappings (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`), and `WHERE order_status = 'delivered'`.

```sql
SELECT
    COALESCE(
        CASE 
            WHEN p.product_category_name = 'pc_gamer' THEN 'PC Gaming'
            WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'Portable Kitchen Appliances'
            ELSE ct.product_category_name_english
        END, 
        'Uncategorized'
    ) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS gross_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY gross_revenue DESC;

```

### Query 2: Regional Fulfillment & Freight Cost Analysis

* **Objective:** Evaluate regional demand concentration alongside fulfillment efficiency across Brazilian states (`customer_state`).
* **Key SQL Techniques:** Date subtraction arithmetic using `EXTRACT(DAY FROM (...)::numeric)` to measure actual delivery duration in calendar days.

```sql
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS gross_revenue,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_cost,
    ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))::numeric), 1) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY customer_state
ORDER BY gross_revenue DESC;

```

### Query 3: Logistics Delays vs. Review Score Distribution (CSAT Penalty)

* **Objective:** Categorize orders into delay performance buckets and calculate the proportion of 1-star to 5-star reviews per bucket.
* **Key SQL Techniques:** Common Table Expression (`WITH order_delays`), date bucket logic via `CASE WHEN`, and conditional aggregations (`COUNT(CASE WHEN r.review_score = X THEN 1 END)`).

```sql
WITH order_delays AS (
    SELECT
        o.order_id,
        o.order_estimated_delivery_date::date AS estimated_date,
        o.order_delivered_customer_date::date AS delivered_date,
        (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) AS delay_in_days,
        CASE
            WHEN o.order_delivered_customer_date::date < o.order_estimated_delivery_date::date THEN '1. Early'
            WHEN o.order_delivered_customer_date::date = o.order_estimated_delivery_date::date THEN '2. On-Time'
            WHEN (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) BETWEEN 1 AND 3 THEN '3. Late (1-3 days)'
            WHEN (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) BETWEEN 4 AND 7 THEN '4. Late (4-7 days)'
            ELSE '5. Late (8+ days)'
        END AS delivery_performance
    FROM orders o
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
)
SELECT 
    od.delivery_performance,
    COUNT(DISTINCT od.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND((COUNT(CASE WHEN r.review_score = 1 THEN 1 END) * 100.0) / COUNT(r.review_id), 2) AS pct_1_star_reviews,
    ROUND((COUNT(CASE WHEN r.review_score = 2 THEN 1 END) * 100.0) / COUNT(r.review_id), 2) AS pct_2_star_reviews,
    ROUND((COUNT(CASE WHEN r.review_score = 3 THEN 1 END) * 100.0) / COUNT(r.review_id), 2) AS pct_3_star_reviews,
    ROUND((COUNT(CASE WHEN r.review_score = 4 THEN 1 END) * 100.0) / COUNT(r.review_id), 2) AS pct_4_star_reviews,
    ROUND((COUNT(CASE WHEN r.review_score = 5 THEN 1 END) * 100.0) / COUNT(r.review_id), 2) AS pct_5_star_reviews
FROM order_delays od
JOIN order_reviews r ON r.order_id = od.order_id
GROUP BY od.delivery_performance
ORDER BY od.delivery_performance;

```

---

## 📈 Dashboard Architecture & Insights

The accompanying **Excel Executive Dashboard** is organized into four purpose-built tabs:

| Tab Name | Main Visuals / Components | Key Takeaway / Insight |
| --- | --- | --- |
| **`Executive Summary`** | KPI Cards (`Gross Revenue`, `Delivered Orders`, `AOV`), Bulleted Insights | Provides top-line summary metrics (**R$ 13.22M** revenue, **96.4k** orders) and executive findings. |
| **`Category Performance`** | Horizontal Bar Chart (*Top 10 Categories by Gross Revenue*) | High-AOV segments like *Watches & Gifts* (**R$ 212.23**) generate higher revenue per order than volume drivers like *Bed, Bath & Table*. |
| **`Geographic Logistics`** | Dual-Axis Combo Chart (*Revenue Concentration vs. Delivery Lead Times*) | São Paulo (`SP`) dominates demand (**8.3-day** average delivery time), while remote states like `RR` face **27.8-day** lead times and higher freight costs. |
| **`Logistics & Review Scores`** | 100% Stacked Bar Chart (*Star Breakdown Across Delay Tiers*) | **Critical CSAT Tipping Point:** 1-star reviews surge from **6.6%** (Early) to **58.5%** (Late 4–7 days) and **69.7%** (Late 8+ days), causing average CSAT to drop to **1.70/5.00**. |

### 1. Category Performance
![Category Performance Chart](assets/category_performance.png)

### 2. Geographic Logistics
![Geographic Logistics Combo Chart](assets/geographic_logistics.png)

### 3. Logistics Delays & Review Scores
![Logistics Delays Stacked Bar Chart](assets/logistics_reviews.png)

---

## 💡 Strategic Business Recommendations

1. **Optimize Remote Fulfillment Operations:** Establish regional fulfillment partnerships or micro-fulfillment nodes in Northern and Northeastern states (`RR`, `AP`, `AM`) to compress delivery times below 15 days and mitigate high freight cost barriers.
2. **Proactive Delay Mitigation & Customer Communication:** Implement automated tracking alerts when shipments exceed a 3-day delay threshold, stopping customer friction before delays cross the 4-day mark where 1-star reviews spike past 58%.
3. **Targeted High-AOV Category Growth:** Shift marketing budget and promotional focus toward high-margin, high-AOV categories (*Watches & Gifts*, *Computers Accessories*) to maximize basket value over low-margin volume products.

---

## 👤 Author

* **Huseyn** — Computer Science Student
