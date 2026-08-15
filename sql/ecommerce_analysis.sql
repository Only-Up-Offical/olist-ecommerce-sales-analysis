-- ==============================================================================
-- Project: E-Commerce Sales & Logistics Analysis (Olist Dataset)
-- Author: Huseyn
-- Description: SQL scripts for cleaning, translating product categories, 
--              aggregating geographic logistics metrics, and measuring CSAT.
-- Database: PostgreSQL 18
-- ==============================================================================


-- ==============================================================================
-- QUERY 1: Product Category Yield & Revenue Performance
-- Purpose: Clean and translate raw Portuguese category names to English,
--          patching missing mappings and calculating Gross Revenue and AOV.
-- ==============================================================================

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
JOIN products p 
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct 
    ON p.product_category_name = ct.product_category_name
JOIN orders o 
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY gross_revenue DESC;


-- ==============================================================================
-- QUERY 2: Regional Fulfillment & Freight Cost Analysis
-- Purpose: Analyze total order volume, gross revenue, average freight cost, 
--          and delivery lead times (in days) grouped by customer state.
-- ==============================================================================

SELECT
	c.customer_state,
	COUNT(DISTINCT o.order_id) AS total_orders,
	ROUND(SUM(oi.price), 2) AS gross_revenue,
	ROUND(AVG(oi.freight_value), 2) AS avg_freight_cost,
	ROUND(AVG( EXTRACT( DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))::numeric), 1) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY customer_state
ORDER BY gross_revenue DESC;


-- ==============================================================================
-- QUERY 3: Delivery Delays vs. Customer Review Distribution (CSAT Penalty)
-- Purpose: Categorize orders by delivery fulfillment performance and calculate 
--          the percentage distribution of 1-star through 5-star review scores.
-- ==============================================================================

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
