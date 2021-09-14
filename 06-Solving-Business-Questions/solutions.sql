-- The following questions are part of the final case study quiz - these are example questions the Marketing team might be interested in!

-- 1. Which film title was the most recommended for all customers?

WITH all_recommended_films AS (
SELECT
  title
FROM category_recommendations

UNION ALL

SELECT 
  title
FROM actor_recommendations
)

SELECT 
  title,
  COUNT(*) AS reco_count
FROM all_recommended_films
GROUP BY title
ORDER BY reco_count DESC
LIMIT 5;

-- 2. How many customers were included in the email campaign?

SELECT
  COUNT(DISTINCT customer_id) AS total_customers
FROM final_data_asset;

-- 3 Out of all the possible films - what percentage coverage do we have in our recommendations?

WITH all_recommended_films AS (
SELECT
  title
FROM category_recommendations
UNION 
SELECT 
  title
FROM actor_recommendations
),

recommendations AS (
SELECT COUNT(DISTINCT title) AS total_recommended_count
FROM all_recommended_films
),

all_films AS (
SELECT COUNT(DISTINCT title) AS total_film_count
FROM dvd_rentals.film
)

SELECT
  ROUND(
    100 * t1.total_recommended_count::NUMERIC / t2.total_film_count
  ) AS coverage_percentage
FROM recommendations AS t1
CROSS JOIN all_films AS t2;

