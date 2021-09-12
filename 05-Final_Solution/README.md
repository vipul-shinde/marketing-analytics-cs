# 5. Final Solution

Now that we have identified the key columns and performed all our table analysis, lets start implementing the final solution to get all the answers required by the business team for sending the email template.

## 5.1 Category Insights

Let's start creating temporary tables for each of the requirements one by one and then merge them later into a single SQL script.

### 5.1.1 Create Base Dataset

We first create a ```complete_joint_dataset``` implementing all the required joins as seen before. Lets also include the ```rental_date``` column for each rental by the customer. This will help us break any ties if any for choosing the top 2 categories of each customer.

```sql
DROP TABLE IF EXISTS complete_joint_dataset;
CREATE TEMP TABLE complete_joint_dataset AS (
SELECT
  rental.customer_id,
  inventory.film_id,
  film.title,
  category.name AS category_name,
  rental.rental_date
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_category
  ON film.film_id = film_category.film_id
INNER JOIN dvd_rentals.category
  ON film_category.category_id = category.category_id
);

--Display sample outputs from the above table
SELECT *
FROM complete_joint_dataset
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | film_id | title           | category_name | rental_date         |
|-------------|---------|-----------------|---------------|---------------------|
| 130         | 80      | BLANKET BEVERLY | Family        | 2005-05-24T22:53:30 |
| 459         | 333     | FREAKY POCUS    | Music         | 2005-05-24T22:54:33 |
| 408         | 373     | GRADUATE LORD   | Children      | 2005-05-24T23:03:39 |
| 333         | 535     | LOVE SUICIDES   | Horror        | 2005-05-24T23:04:41 |
| 222         | 450     | IDOLS SNATCHERS | Children      | 2005-05-24T23:05:21 |

</details>

### 5.1.2 Category Counts

Now, that we have the total dataset table containing records for each customer's rental along with its category, let's calculate the category count for each customer's rental records. Also, lets take a look at the records when ```customer_id = 1```.

```sql
DROP TABLE IF EXISTS category_counts;
CREATE TEMP TABLE category_counts AS (
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM complete_joint_dataset
GROUP BY 
  customer_id,
  category_name
);

--Display sample outputs from the above table
SELECT *
FROM category_counts
WHERE customer_id = 1
ORDER BY
  rental_count DESC,
  latest_rental_date DESC;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | category_name | rental_count | latest_rental_date  |
|-------------|---------------|--------------|---------------------|
| 1           | Classics      | 6            | 2005-08-19T09:55:16 |
| 1           | Comedy        | 5            | 2005-08-22T19:41:37 |
| 1           | Drama         | 4            | 2005-08-18T03:57:29 |
| 1           | Animation     | 2            | 2005-08-22T20:03:46 |
| 1           | Sci-Fi        | 2            | 2005-08-21T23:33:57 |
| 1           | New           | 2            | 2005-08-19T13:56:54 |
| 1           | Action        | 2            | 2005-08-17T12:37:54 |
| 1           | Music         | 2            | 2005-07-09T16:38:01 |
| 1           | Sports        | 2            | 2005-07-08T07:33:56 |
| 1           | Family        | 1            | 2005-08-02T18:01:38 |
| 1           | Documentary   | 1            | 2005-08-01T08:51:04 |
| 1           | Foreign       | 1            | 2005-07-28T16:18:23 |
| 1           | Travel        | 1            | 2005-07-11T10:13:46 |
| 1           | Games         | 1            | 2005-07-08T03:17:05 |

</details>

### 5.1.3 Total Counts

Since, we later need to calculate the percentage of each category it counts to the customers viewing history, lets create a ```total_counts``` table from the above table.

```sql
DROP TABLE IF EXISTS total_counts;
CREATE TEMP TABLE total_counts AS(
SELECT
  customer_id,
  SUM(rental_count) AS total_count
FROM category_counts
GROUP BY customer_id
);

--Display sample outputs from the above table
SELECT *
FROM total_counts
ORDER BY customer_id
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | total_count |
|-------------|-------------|
| 1           | 32          |
| 2           | 27          |
| 3           | 26          |
| 4           | 22          |
| 5           | 38          |

</details>

### 5.1.4 Top Categories

Now, lets filter out the top 2 categories for each customer based on their rental_count and to avoid any ties, order the categories by its name and the ```latest_rental_date``` in that category.

```sql
DROP TABLE IF EXISTS top_categories;
CREATE TEMP TABLE top_categories AS (
WITH ranked_cte AS (
  SELECT
    customer_id,
    category_name,
    rental_count,
    DENSE_RANK() OVER (
      PARTITION BY customer_id
      ORDER BY
        rental_count DESC,
        latest_rental_date DESC,
        category_name
    ) AS category_rank
  FROM category_counts
)

SELECT *
FROM ranked_cte
WHERE category_rank <= 2
);

--Display sample outputs from the above table
SELECT *
FROM top_categories
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | category_name | rental_count | category_rank |
|-------------|---------------|--------------|---------------|
| 1           | Classics      | 6            | 1             |
| 1           | Comedy        | 5            | 2             |
| 2           | Sports        | 5            | 1             |
| 2           | Classics      | 4            | 2             |
| 3           | Action        | 4            | 1             |

</details>

### 5.1.5 Average Category Counts

Here, we calculate the average rental count for each category. This will help us in filling one of the requirements.

```sql
DROP TABLE IF EXISTS average_category_count;
CREATE TEMP TABLE average_category_count AS (
SELECT
  category_name,
  FLOOR(AVG(rental_count)) AS category_count
FROM category_counts
GROUP BY category_name
);

--Display sample outputs from the above table
SELECT *
FROM average_category_count
ORDER BY category_name;
```

<details>
<summary>Click to view output.</summary>
<br>

| category_name | category_count |
|---------------|----------------|
| Action        | 2              |
| Animation     | 2              |
| Children      | 1              |
| Classics      | 2              |
| Comedy        | 1              |
| Documentary   | 2              |
| Drama         | 2              |
| Family        | 2              |
| Foreign       | 2              |
| Games         | 2              |
| Horror        | 1              |
| Music         | 1              |
| New           | 2              |
| Sci-Fi        | 2              |
| Sports        | 2              |
| Travel        | 1              |

</details>

### 5.1.6 Top Category Percentile

Here, we compare each customers top category ```rental_count``` to all the other customers. In short, we calculate what percentile the customer fits in for their top category.

```sql
DROP TABLE IF EXISTS top_category_percentile;
CREATE TEMP TABLE top_category_percentile AS (
WITH calculated_cte AS (
SELECT
  top_categories.customer_id,
  top_categories.category_name AS top_category_name,
  top_categories.rental_count,
  category_counts.category_name,
  top_categories.category_rank,
  PERCENT_RANK() OVER (
    PARTITION BY category_counts.category_name
    ORDER BY category_counts.rental_count DESC
  ) AS raw_percentile_value
FROM top_categories
LEFT JOIN category_counts
  ON top_categories.customer_id = category_counts.customer_id
)

SELECT
  customer_id,
  category_name,
  rental_count,
  CASE
    WHEN ROUND(100 * raw_percentile_value) = 0 THEN 1
    ELSE ROUND(100 * raw_percentile_value)
  END AS percentile
FROM calculated_cte
WHERE category_rank = 1
AND top_category_name = category_name
);

--Display sample outputs from the above table
SELECT *
FROM top_category_percentile
ORDER BY customer_id
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | category_name | rental_count | percentile |
|-------------|---------------|--------------|------------|
| 1           | Classics      | 6            | 1          |
| 2           | Sports        | 5            | 2          |
| 3           | Action        | 4            | 4          |
| 4           | Horror        | 3            | 8          |
| 5           | Classics      | 7            | 1          |

</details>

### 5.1.7 First Category Insights

For the top category, we require ```average_comparison``` and ```percentile``` for each customer. Lets compile both of these requirements into a single table.

```sql
DROP TABLE IF EXISTS first_category_insights;
CREATE TEMP TABLE first_category_insights AS (
SELECT
  t1.customer_id,
  t1.category_name,
  t1.rental_count,
  t1.rental_count - t2.category_count AS average_comparison,
  t1.percentile
FROM top_category_percentile AS t1
LEFT JOIN average_category_count AS t2
  ON t1.category_name = t2.category_name
);

--Display sample outputs from the above table
SELECT *
FROM first_category_insights
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | category_name | rental_count | average_comparison | percentile |
|-------------|---------------|--------------|--------------------|------------|
| 323         | Action        | 7            | 5                  | 1          |
| 506         | Action        | 7            | 5                  | 1          |
| 151         | Action        | 6            | 4                  | 1          |
| 410         | Action        | 6            | 4                  | 1          |
| 126         | Action        | 6            | 4                  | 1          |

</details>

### 5.1.8 Second Category Insights

And for the second category, we need to calculate its ```total_percentage``` that it contains when compared to a customers total rental watching history.

```sql
DROP TABLE IF EXISTS second_category_insights;
CREATE TEMP TABLE second_category_insights AS (
SELECT
  t1.customer_id,
  t1.category_name,
  t1.rental_count,
  ROUND(
    100 * t1.rental_count::NUMERIC / t2.total_count
  ) AS total_percentage
FROM top_categories AS t1
LEFT JOIN total_counts AS t2
  ON t1.customer_id = t2.customer_id
WHERE category_rank = 2
);

SELECT *
FROM second_category_insights
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | category_name | rental_count | total_percentage |
|-------------|---------------|--------------|------------------|
| 184         | Drama         | 3            | 13               |
| 87          | Sci-Fi        | 3            | 10               |
| 477         | Travel        | 3            | 14               |
| 273         | New           | 4            | 11               |
| 550         | Drama         | 4            | 13               |

</details>

## 5.2 Category Recommendations

### 5.2.1 Film Counts

First, we will calculate the total ```rental_count``` which is how many times a particular film has been rented by customers. This will help us in recommending new films to customers which they haven't watched yet.

```sql
DROP TABLE IF EXISTS film_counts;
CREATE TEMP TABLE film_counts AS (
SELECT DISTINCT
  film_id,
  title,
  category_name,
  COUNT(*) OVER (
    PARTITION BY film_id
  ) AS rental_count
FROM complete_joint_dataset
);

SELECT *
FROM film_counts
ORDER BY rental_count DESC
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| film_id | title               | category_name | rental_count |
|---------|---------------------|---------------|--------------|
| 103     | BUCKET BROTHERHOOD  | Travel        | 34           |
| 738     | ROCKETEER MOTHER    | Foreign       | 33           |
| 767     | SCALAWAG DUCK       | Music         | 32           |
| 730     | RIDGEMONT SUBMARINE | New           | 32           |
| 331     | FORWARD TEMPLE      | Games         | 32           |

</details>

### 5.2.2 Category Film Exclusions

We now make a list of all the films every customer has watched along with the ```film_id``` so it helps us in recommending unwatched films to customers. This can be used by performing an ```ANTI JOIN``` later with the ```film_counts``` table. 

```sql
DROP TABLE IF EXISTS category_film_exclusion;
CREATE TEMP TABLE category_film_exclusion AS (
SELECT DISTINCT
  customer_id,
  film_id,
  title,
  category_name
FROM complete_joint_dataset
);

SELECT *
FROM category_film_exclusion
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | film_id | title                  | category_name |
|-------------|---------|------------------------|---------------|
| 194         | 264     | DWARFS ALTER           | Games         |
| 293         | 902     | TRADING PINOCCHIO      | Sports        |
| 64          | 366     | GOLDFINGER SENSIBILITY | Drama         |
| 329         | 886     | THEORY MERMAID         | Animation     |
| 172         | 154     | CLASH FREDDY           | Animation     |

</details>

### 5.2.3 Final Category Recommendations

Finally, we find out the 3 films that we can recommend to each customer based on their top two categories. Here, we use a ```LEFT JOIN``` with the ```film_counts``` table and rank films of each category depending on the ```rental_count``` of that film across all the customers and later we use an ```ANTI JOIN``` with the ```category_film_exclusion``` to exclude film that have been already watched from the recommendation list.

```sql
DROP TABLE IF EXISTS category_recommendations;
CREATE TEMP TABLE category_recommendations AS (
WITH ranked_films_cte AS (
SELECT
  top_categories.customer_id,
  top_categories.category_name,
  top_categories.category_rank,
  film_counts.film_id,
  film_counts.title,
  film_counts.rental_count,
  DENSE_RANK() OVER (
    PARTITION BY 
      top_categories.customer_id,
      top_categories.category_rank
    ORDER BY
      film_counts.rental_count DESC,
      film_counts.title
  ) AS reco_rank
FROM top_categories
LEFT JOIN film_counts
  ON top_categories.category_name = film_counts.category_name
WHERE NOT EXISTS (
  SELECT 1
  FROM category_film_exclusion
  WHERE 
    category_film_exclusion.customer_id = top_categories.customer_id AND
    category_film_exclusion.film_id = film_counts.film_id
)
)

SELECT *
FROM ranked_films_cte
WHERE reco_rank <= 3
);

-- Display sample output recommendations for customer_id = 1
SELECT *
FROM category_recommendations
WHERE customer_id = 1;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | category_name | category_rank | film_id | title               | rental_count | reco_rank |
|-------------|---------------|---------------|---------|---------------------|--------------|-----------|
| 1           | Classics      | 1             | 891     | TIMBERLAND SKY      | 31           | 1         |
| 1           | Classics      | 1             | 358     | GILMORE BOILED      | 28           | 2         |
| 1           | Classics      | 1             | 951     | VOYAGE LEGALLY      | 28           | 3         |
| 1           | Comedy        | 2             | 1000    | ZORRO ARK           | 31           | 1         |
| 1           | Comedy        | 2             | 127     | CAT CONEHEADS       | 30           | 2         |
| 1           | Comedy        | 2             | 638     | OPERATION OPERATION | 27           | 3         |

</details>

## 5.3 Actor Insights

### 5.3.1 Actor Joint Table

Here, we create a similar base table as ```complete_joint_dataset``` but this time we join the tables ```film_actor``` and ```actor``` along with the ```rental``` table. This will give us a list of all the customers rental along with all the actors that starred in it.

```sql
DROP TABLE IF EXISTS actor_joint_dataset;
CREATE TEMP TABLE actor_joint_dataset AS (
SELECT 
  rental.customer_id,
  rental.rental_id,
  rental.rental_date,
  film.film_id,
  film.title,
  actor.actor_id,
  actor.first_name,
  actor.last_name
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_actor
  ON film.film_id = film_actor.film_id
INNER JOIN dvd_rentals.actor
  ON film_actor.actor_id = actor.actor_id
);

SELECT *
FROM actor_joint_dataset
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | rental_id | rental_date              | film_id | title           | actor_id | first_name | last_name |
|-------------|-----------|--------------------------|---------|-----------------|----------|------------|-----------|
| 130         | 1         | 2005-05-24T22:53:30.000Z | 80      | BLANKET BEVERLY | 200      | THORA      | TEMPLE    |
| 130         | 1         | 2005-05-24T22:53:30.000Z | 80      | BLANKET BEVERLY | 193      | BURT       | TEMPLE    |
| 130         | 1         | 2005-05-24T22:53:30.000Z | 80      | BLANKET BEVERLY | 173      | ALAN       | DREYFUSS  |
| 130         | 1         | 2005-05-24T22:53:30.000Z | 80      | BLANKET BEVERLY | 16       | FRED       | COSTNER   |
| 459         | 2         | 2005-05-24T22:54:33.000Z | 333     | FREAKY POCUS    | 147      | FAY        | WINSLET   |

</details>

Let's also check out the distinct values count for a few columns.

```sql
SELECT
  COUNT(*) AS total_row_count,
  COUNT(DISTINCT rental_id) AS unique_rental_id,
  COUNT(DISTINCT film_id) AS unique_film_id,
  COUNT(DISTINCT actor_id) AS unique_actor_id,
  COUNT(DISTINCT customer_id) AS unique_customer_id
FROM actor_joint_dataset;
```

*Output:*

| total_row_count | unique_rental_id | unique_film_id | unique_actor_id | unique_customer_id |
|-----------------|------------------|----------------|-----------------|--------------------|
| 87980           | 16004            | 955            | 200             | 599                |

### 5.3.2 Top Actor Counts

Now, based on the ```actor_joint_dataset```, we calculate the count of the total number of actors film a customer has watched and then select the top actor based on the ```DENSE_RANK()``` window function value. This will take care of our first actor insights requirement for the email template.

```sql
DROP TABLE IF EXISTS top_actor_counts;
CREATE TEMP TABLE top_actor_counts AS (
WITH actor_counts AS (
SELECT 
  customer_id,
  actor_id,
  first_name,
  last_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM actor_joint_dataset
GROUP BY
  customer_id,
  actor_id,
  first_name,
  last_name
),
ranked_actor_cte AS (
SELECT
  actor_counts.*,
  DENSE_RANK() OVER (
    PARTITION BY customer_id
    ORDER BY
      rental_count DESC,
      latest_rental_date DESC,
      first_name,
      last_name
  ) AS actor_rank
FROM actor_counts
)

SELECT
  customer_id,
  actor_id,
  first_name,
  last_name,
  rental_count
FROM ranked_actor_cte
WHERE actor_rank = 1
);

--Display a few sample dataset rows
SELECT *
FROM top_actor_counts
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | actor_id | first_name | last_name | rental_count |
|-------------|----------|------------|-----------|--------------|
| 1           | 37       | VAL        | BOLGER    | 6            |
| 2           | 107      | GINA       | DEGENERES | 5            |
| 3           | 150      | JAYNE      | NOLTE     | 4            |
| 4           | 102      | WALTER     | TORN      | 4            |
| 5           | 12       | KARL       | BERRY     | 4            |

</details>

## 5.4 Actor Recommendations

### 5.4.1 Actor Film Counts

We first calculate the actor-film rental counts

```sql
DROP TABLE IF EXISTS actor_film_counts;
CREATE TEMP TABLE actor_film_counts AS (
WITH film_counts AS (
SELECT
  film_id,
  COUNT(DISTINCT rental_id) AS rental_count
FROM actor_joint_dataset
GROUP BY film_id
)

SELECT DISTINCT
  t1.film_id,
  t1.actor_id,
  t1.title,
  film_counts.rental_count
FROM actor_joint_dataset AS t1
LEFT JOIN film_counts
  ON t1.film_id = film_counts.film_id
);

--Display sample row outputs from above table
SELECT *
FROM actor_film_counts
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| film_id | actor_id | title            | rental_count |
|---------|----------|------------------|--------------|
| 1       | 1        | ACADEMY DINOSAUR | 23           |
| 1       | 10       | ACADEMY DINOSAUR | 23           |
| 1       | 20       | ACADEMY DINOSAUR | 23           |
| 1       | 30       | ACADEMY DINOSAUR | 23           |
| 1       | 40       | ACADEMY DINOSAUR | 23           |

</details>

### 5.4.2 Actor Film Exclusions

Now, we will create a table of films that should be excluded while recommending based on the customers most watched actor films. This will be a combination of the films that the customer has already watched along with the films that we have recommended in their top 2 category recommendation sections.

```sql
DROP TABLE IF EXISTS actor_film_exclusions;
CREATE TEMP TABLE actor_film_exclusions AS (
SELECT DISTINCT
  customer_id,
  film_id
FROM complete_joint_dataset

UNION

SELECT DISTINCT
  customer_id,
  film_id
FROM category_recommendations
);

SELECT *
FROM actor_film_exclusions
LIMIT 5;
```

<details>
<summary>Click to view output.</summary>
<br>

| customer_id | film_id |
|-------------|---------|
| 493         | 567     |
| 114         | 789     |
| 596         | 103     |
| 176         | 121     |
| 459         | 724     |

</details>
