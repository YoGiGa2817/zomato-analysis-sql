-- Create Database (Agar pehle se nahi bana hai)
CREATE DATABASE IF NOT EXISTS zomato_db;
USE zomato_db;

-- Quick structural view of the table
-- Expected Columns: restaurant_id, restaurant_name, city, average_cost_for_two, aggregate_rating, votes, cuisines
SELECT * FROM zomato_data LIMIT 5;

-- 1. Handling Null values in Ratings and Costs
-- Setting unrated restaurants to 0 and missing costs to the city average

UPDATE zomato_data
SET aggregate_rating = 0.0
WHERE aggregate_rating IS NULL;

UPDATE zomato_data t1
JOIN (
    SELECT city, AVG(average_cost_for_two) as avg_city_cost 
    FROM zomato_data 
    WHERE average_cost_for_two IS NOT NULL AND average_cost_for_two > 0
    GROUP BY city
) t2 ON t1.city = t2.city
SET t1.average_cost_for_two = ROUND(t2.avg_city_cost, 0)
WHERE t1.average_cost_for_two IS NULL OR t1.average_cost_for_two = 0;


-- 2. Performance Tiering using Window Functions
-- Target: Identify top performers and calculate rating gaps using LAG()

WITH CityRestaurantRankings AS (
    SELECT 
        city,
        restaurant_name,
        average_cost_for_two,
        aggregate_rating,
        votes,
        -- Grouping by city and ranking based on rating and popularity (votes)
        RANK() OVER (PARTITION BY city ORDER BY aggregate_rating DESC, votes DESC) as restaurant_rank,
        -- Fetching the rating of the immediate next-best restaurant in the same city
        LAG(aggregate_rating, 1) OVER (PARTITION BY city ORDER BY aggregate_rating DESC, votes DESC) as next_best_rating
    FROM 
        zomato_data
    WHERE 
        votes > 50 -- Filtering out low engagement records for baseline accuracy
)
SELECT 
    city,
    restaurant_name,
    average_cost_for_two,
    aggregate_rating,
    restaurant_rank,
    -- Handling the boundary case for rank 1 using COALESCE
    COALESCE(ROUND(next_best_rating - aggregate_rating, 2), 0) as rating_gap_from_competitor
FROM 
    CityRestaurantRankings
WHERE 
    restaurant_rank <= 10; -- Focusing on top 10 performers per city




-- 3. Analyzing Price Segments vs Avg Ratings to find Pricing Sweet-Spots
-- Target: Uncover non-linear correlation in mid-tier segments

WITH PriceSegmentation AS (
    SELECT 
        restaurant_id,
        city,
        average_cost_for_two,
        aggregate_rating,
        votes,
        -- Segmenting based on cost distribution mapping
        CASE 
            WHEN average_cost_for_two <= 300 THEN 'Budget (<300)'
            WHEN average_cost_for_two > 300 AND average_cost_for_two <= 700 THEN 'Mid-Tier (301-700)'
            WHEN average_cost_for_two > 700 AND average_cost_for_two <= 1500 THEN 'Premium (701-1500)'
            ELSE 'Luxury (>1500)'
        END as price_segment
)
SELECT 
    price_segment,
    COUNT(restaurant_id) as total_restaurants,
    ROUND(AVG(aggregate_rating), 2) as avg_rating,
    SUM(votes) as total_engagement,
    ROUND(AVG(votes), 0) as avg_votes_per_restaurant
FROM 
    PriceSegmentation
GROUP BY 
    price_segment
ORDER BY 
    avg_rating DESC; 
-- Notice how Mid-Tier might perform better or worse compared to Budget/Premium!




-- 4. Regional Market Share and Demand Penetration Analysis
-- Target: Identify high-demand zones vs saturated markets

WITH TotalMarketMetrics AS (
    SELECT 
        COUNT(restaurant_id) as global_restaurant_count,
        SUM(votes) as global_total_votes
    FROM zomato_data
),
CityMetrics AS (
    SELECT 
        city,
        COUNT(restaurant_id) as city_restaurant_count,
        SUM(votes) as city_total_votes,
        ROUND(AVG(average_cost_for_two), 2) as city_avg_cost
    FROM 
        zomato_data
    GROUP BY 
        city
)
SELECT 
    c.city,
    c.city_restaurant_count,
    -- Percentage Contribution of Restaurants in this city to the overall market
    ROUND((c.city_restaurant_count * 100.0) / m.global_restaurant_count, 2) as restaurant_market_share_pct,
    c.city_total_votes as total_city_orders_engagement,
    -- Engagement share highlights high demand zones even if restaurant count is low
    ROUND((c.city_total_votes * 100.0) / m.global_total_votes, 2) as engagement_share_pct,
    c.city_avg_cost
FROM 
    CityMetrics c
CROSS JOIN 
    TotalMarketMetrics m
ORDER BY 
    engagement_share_pct DESC;



