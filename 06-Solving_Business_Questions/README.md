# 6. Business Questions

## Overview

The following questions are part of the final case study quiz - these are example questions the Marketing team might be interested in!

### 6.1 Which film title was the most recommended for all customers?

```sql
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
```

*Output:*

| title               | reco_count |
|---------------------|------------|
| **DOGMA FAMILY**    | **126**    |
| JUGGLER HARDLY      | 123        |
| STORM HAPPINESS     | 111        |
| HANDICAP BOONDOCK   | 109        |
| GLEAMING JAWBREAKER | 106        |

### 6.2 How many customers were included in the email campaign?

```sql
SELECT
  COUNT(DISTINCT customer_id) AS total_customers
FROM final_data_asset;
```

*Output:*

| total_customers |
|-----------------|
| 599             |

### 6.3 Out of all the possible films - what percentage coverage do we have in our recommendations?

```sql
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
```

*Output:*

| coverage_percentage |
|---------------------|
| 25                  |

### 6.4 What is the most popular top category?

```sql
SELECT
  category_name,
  COUNT(*) AS total_count
FROM first_category_insights
GROUP BY category_name
ORDER BY total_count DESC;
```

*Output:*

| category_name | total_count |
|---------------|-------------|
| **Sports**    | **67**      |
| Action        | 60          |
| Sci-Fi        | 58          |
| Animation     | 50          |
| Foreign       | 43          |
| Drama         | 38          |
| Documentary   | 38          |
| New           | 35          |
| Family        | 34          |
| Games         | 31          |
| Classics      | 30          |
| Travel        | 27          |
| Horror        | 23          |
| Music         | 22          |
| Comedy        | 22          |
| Children      | 21          |

### 6.5 What is the 4th most popular top category?

```sql
WITH ranked_cte AS (
SELECT
  category_name,
  COUNT(*) AS total_count,
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS cat_rank
FROM first_category_insights
GROUP BY category_name
)

SELECT *
FROM ranked_cte
WHERE cat_rank=4;
```

*Output:*

| category_name | total_count | cat_rank |
|---------------|-------------|----------|
| Animation     | 50          | 4        |

### 6.6 What is the average percentile ranking for each customer in their top category rounded to the nearest 2 decimal places?

```sql
SELECT
  ROUND(CAST(AVG(percentile) AS NUMERIC), 
  2
  ) AS average_percentile
FROM first_category_insights;
```

*Output:*

| average_percentile |
|--------------------|
| 5.10               |

### 6.7 What is the cumulative distribution of the top 5 percentile values for the top category from the first_category_insights table rounded to the nearest round percentage?

```sql
SELECT
  ROUND(percentile) AS percentile,
  COUNT(*) AS frequency,
  ROUND(100 * CUME_DIST() OVER (
          ORDER BY ROUND(percentile))
    ) AS cde
FROM first_category_insights
GROUP BY percentile
ORDER BY percentile
LIMIT 5;
```

*Output:*

| percentile | frequency | cde |
|------------|-----------|-----|
| 1          | 159       | 4   |
| 2          | 126       | 9   |
| 3          | 41        | 13  |
| 4          | 50        | 17  |
| 5          | 14        | 22  |

### 6.8 What is the median of the second category percentage of entire viewing history?

```sql
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_percentage) AS median
FROM second_category_insights;
```

*Output:*

| median |
|--------|
| 13     |

### 6.9 What is the 80th percentile of films watched featuring each customer’s favorite actor?

```sql
SELECT
  PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY rental_count) AS _80th_percentile_films
FROM top_actor_counts;
```

*Output:*

| _80th_percentile_films |
|------------------------|
| 5                      |

### 6.10 What was the average number of films watched by each customer?

```sql
SELECT
  ROUND(AVG(total_count)) AS average_films_watched
FROM total_counts;
```

*Output:*

| average_films_watched |
|-----------------------|
| 27                    |

### 6.11 What is the top combination of top 2 categories and how many customers if the order is relevant (e.g. Horror and Drama is a different combination to Drama and Horror)

```sql
SELECT
  cat_1,
  cat_2,
  COUNT(*) AS freq_count
FROM final_data_asset
GROUP BY
  cat_1,
  cat_2
ORDER BY freq_count DESC
LIMIT 5;
```

*Output:*

| cat_1      | cat_2         | freq_count |
|------------|---------------|------------|
| **Sports** | **Animation** | **11**     |
| Action     | Documentary   | 9          |
| Animation  | Drama         | 9          |
| Sci-Fi     | Family        | 8          |
| Animation  | Family        | 7          |

### 6.12 Which actor was the most popular for all customers?

```sql
SELECT
  actor,
  COUNT(*) AS freq_count
FROM final_data_asset
GROUP BY actor
ORDER BY freq_count DESC
LIMIT 1;
```

*Output:*

| actor       | freq_count |
|-------------|------------|
| Walter Torn | 13         |

### 6.13 How many films on average had customers already seen that feature their favorite actor rounded to closest integer?

```sql
SELECT 
  ROUND(AVG(rental_count)) AS avg_count
FROM top_actor_counts;
```

*Output:*

| avg_count |
|-----------|
| 4         |

<hr>

### 6.14 What is the most common top categories combination if order was irrelevant and how many customers have this combination? (e.g. Horror and Drama is a the same as Drama and Horror)

```sql
SELECT
  LEAST(cat_1, cat_2) AS category_1,
  GREATEST(cat_1, cat_2) AS category_2,
  COUNT(*) AS freq_count
FROM final_data_asset
GROUP BY
  category_1,
  category_2
ORDER BY freq_count DESC
LIMIT 5;
```

*Output:*

| category_1    | category_2  | freq_count |
|---------------|-------------|------------|
| **Animation** | **Sports**  | **14**     |
| Action        | Documentary | 12         |
| Family        | Sci-Fi      | 12         |
| Animation     | Family      | 12         |
| Documentary   | Drama       | 12         |

# Thank you!