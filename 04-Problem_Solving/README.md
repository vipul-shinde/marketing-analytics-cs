# 4. SQL Problem Solving

## 4.1 Base table

Let's again take a look at our base table that we implemented during our last section after joining the tables.

```sql
DROP TABLE IF EXISTS final_table_join_data;
CREATE TEMP TABLE final_table_join_data AS (
SELECT 
  rental.customer_id,
  film.film_id,
  film.title,
  film_category.category_id,
  category.name AS category_name
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

SELECT *
FROM final_table_join_data
LIMIT 10;
```

*Output:*

| customer_id | film_id | title           | category_id | category_name |
|-------------|---------|-----------------|-------------|---------------|
| 130         | 80      | BLANKET BEVERLY | 8           | Family        |
| 459         | 333     | FREAKY POCKS    | 12          | Music         |
| 408         | 373     | GRADUATE LORD   | 3           | Children      |
| 333         | 535     | LOVE SUICIDES   | 11          | Horror        |
| 222         | 450     | IDOLS SNATCHERS | 3           | Children      |
| 549         | 613     | MYSTIC TRUMAN   | 5           | Comedy        |
| 269         | 870     | SWARM GOLD      | 11          | Horror        |
| 239         | 510     | LAWLESS VISION  | 2           | Animation     |
| 126         | 565     | MATRIX SNOWMAN  | 9           | Foreign       |
| 399         | 396     | HANGING DEEP    | 7           | Drama         |

## 4.2 Group by count to get rental count

As we need the rental count for each film watched by the customer based on its category, let's do a group by across the above table and get our results.

Now, as per the business requirement, we need to find the top 2 categories for each customer based on the rental count and also calculate some aggregated functions such as percentile, average_count and percentage_count for each category. But for doing tht we'll need the values for all customers across all categories and not just top 2. If we only query the top 2 and do our aggregated functions, the data will be skewed.

Let's first check the output of group by when ```customer_id``` = 1, 2, 3. The output is segregated based on the id just for easy viewing.

```sql
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count
FROM final_table_join_data
WHERE customer_id IN (1, 2, 3)
GROUP BY 
  customer_id,
  category_name
ORDER BY 
  customer_id,
  rental_count DESC;
```

**when ```customer_id``` = 1**

*Output:*

| customer_id | category_name | rental_count |
|-------------|---------------|--------------|
| 1           | Classics      | 6            |
| 1           | Comedy        | 5            |
| 1           | Drama         | 4            |
| 1           | Action        | 2            |
| 1           | Music         | 2            |
| 1           | New           | 2            |
| 1           | Sci-Fi        | 2            |
| 1           | Sports        | 2            |
| 1           | Animation     | 2            |
| 1           | Documentary   | 1            |
| 1           | Family        | 1            |
| 1           | Games         | 1            |
| 1           | Travel        | 1            |
| 1           | Foreign       | 1            |

<br>

**when ```customer_id``` = 2**

<details>
<summary>Click to view output</summary>
<br>

| customer_id | category_name | rental_count |
|-------------|---------------|--------------|
| 2           | Sports        | 5            |
| 2           | Classics      | 4            |
| 2           | Animation     | 3            |
| 2           | Action        | 3            |
| 2           | Travel        | 2            |
| 2           | Games         | 2            |
| 2           | New           | 2            |
| 2           | Foreign       | 1            |
| 2           | Children      | 1            |
| 2           | Documentary   | 1            |
| 2           | Family        | 1            |
| 2           | Music         | 1            |
| 2           | Sci-Fi        | 1            |
| 3           | Action        | 4            |
| 3           | Animation     | 3            |
| 3           | Sci-Fi        | 3            |
| 3           | Sports        | 2            |
| 3           | Comedy        | 2            |
| 3           | Games         | 2            |
| 3           | Horror        | 2            |
| 3           | Music         | 2            |
| 3           | New           | 2            |
| 3           | Drama         | 1            |
| 3           | Family        | 1            |
| 3           | Documentary   | 1            |
| 3           | Classics      | 1            |

</details>

<br>

**when ```customer_id``` = 3**

<details>
<summary>Click to view output</summary>
<br>

| customer_id | category_name | rental_count |
|-------------|---------------|--------------|
| 3           | Action        | 4            |
| 3           | Animation     | 3            |
| 3           | Sci-Fi        | 3            |
| 3           | Sports        | 2            |
| 3           | Comedy        | 2            |
| 3           | Games         | 2            |
| 3           | Horror        | 2            |
| 3           | Music         | 2            |
| 3           | New           | 2            |
| 3           | Drama         | 1            |
| 3           | Family        | 1            |
| 3           | Documentary   | 1            |
| 3           | Classics      | 1            |

</details>

## 4.3 Dealing with ties

We know that we need the top 2 categories for each customer based on their rental count, but what if there is a tie. For eg,

When we check the top 3 categories for customer 3, we get the following output.

| customer_id | category_name | rental_count |
|-------------|---------------|--------------|
| 3           | Action        | 4            |
| 3           | Animation     | 3            |
| 3           | Sci-Fi        | 3            |

Here there is a tie because ```rental_count``` = 3 for both Animation and Sci-Fi film categories. So, here we can always sort it alphabetically and select the 1st or 2nd category. This is easy and maybe the least time consuming option preferred. But, what we can also do is check out the ```rental_date``` column and see which category book the customer bought the last and based on that, we select the category. Let's check how we can implement it using SQL for customer 3.

```sql
-- First add the rental_date column from our original rental table into our final one
DROP TABLE IF EXISTS final_table_join_data;
CREATE TEMP TABLE final_table_join_data AS (
SELECT 
  rental.customer_id,
  film.film_id,
  film.title,
  film_category.category_id,
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

-- Getting the top categories for customer 3
SELECT 
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM final_table_join_data
WHERE customer_id = 3
GROUP BY
  customer_id,
  category_name
ORDER BY 
  customer_id,
  rental_count DESC,
  latest_rental_date DESC;
```

*Output:*

| customer_id | category_name | rental_count | latest_rental_date       |
|-------------|---------------|--------------|--------------------------|
| 3           | Action        | 4            | 2005-07-29T11:07:04.000Z |
| 3           | Sci-Fi        | 3            | 2005-08-22T09:37:27.000Z |
| 3           | Animation     | 3            | 2005-08-18T14:49:55.000Z |
| 3           | Music         | 2            | 2005-08-23T07:10:14.000Z |
| 3           | Comedy        | 2            | 2005-08-20T06:14:12.000Z |
| 3           | Horror        | 2            | 2005-07-31T11:32:58.000Z |
| 3           | Sports        | 2            | 2005-07-30T13:31:20.000Z |
| 3           | New           | 2            | 2005-07-28T04:46:30.000Z |
| 3           | Games         | 2            | 2005-07-27T04:54:42.000Z |
| 3           | Classics      | 1            | 2005-08-01T14:19:48.000Z |
| 3           | Family        | 1            | 2005-07-31T03:27:58.000Z |
| 3           | Drama         | 1            | 2005-07-30T21:45:46.000Z |
| 3           | Documentary   | 1            | 2005-06-19T08:34:53.000Z |

Now, we can see that the ```Sci-Fi``` category has taken up the second most watched category place for customer 3. Earlier, it was ```Animation```.

## 4.3 Calculating average of all categories

We can calculate the average across categories for the first three customers for now as follows.

```sql
WITH aggregated_rental_count AS (
SELECT 
  customer_id,
  category_name,
  COUNT(*) AS rental_count
FROM final_table_join_data
WHERE customer_id IN (1, 2, 3)
GROUP BY
  customer_id,
  category_name
)

SELECT 
  category_name,
  ROUND(
  AVG(rental_count), 
  2) AS average_value
FROM aggregated_rental_count
GROUP BY category_name
ORDER BY category_name;
```

*Output:*

| category_name | average_value |
|---------------|---------------|
| Action        | 3.00          |
| Animation     | 2.67          |
| Children      | 1.00          |
| Classics      | 3.67          |
| Comedy        | 3.50          |
| Documentary   | 1.00          |
| Drama         | 2.50          |
| Family        | 1.00          |
| Foreign       | 1.00          |
| Games         | 1.67          |
| Horror        | 2.00          |
| Music         | 1.67          |
| New           | 2.00          |
| Sci-Fi        | 2.00          |
| Sports        | 3.00          |
| Travel        | 1.50          |

## 4.4 Data aggregation on the whole dataset

Now that we have seen the aggregation performed for just 3 customers, lets do it across the whole dataset. As said earlier, we do need the top 2 categories but in order to perform the average_rental_count, percentile and percentage_count, we need aggregation on the whole data so let's do it.

We will split our aggregations and create temporary tables for each of them.

### 4.4.1 Customer Rental count

Let's first aggregate the ```rental_count``` for each customer's record for each category. Here, we'll also select the ```latest_rental_date``` for that category which will be useful for us in sorting as seen earlier.

```sql
DROP TABLE IF EXISTS category_rental_count;
CREATE TEMP TABLE category_rental_count AS (
SELECT 
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM final_table_join_data
GROUP BY
  customer_id,
  category_name
);

-- Checking the records for customer_id = 1
SELECT *
FROM category_rental_count
WHERE customer_id = 1
ORDER BY
  rental_count DESC,
  latest_rental_date DESC;
```

*Output:*

| customer_id | category_name | rental_count | latest_rental_date       |
|-------------|---------------|--------------|--------------------------|
| 1           | Classics      | 6            | 2005-08-19T09:55:16.000Z |
| 1           | Comedy        | 5            | 2005-08-22T19:41:37.000Z |
| 1           | Drama         | 4            | 2005-08-18T03:57:29.000Z |
| 1           | Animation     | 2            | 2005-08-22T20:03:46.000Z |
| 1           | Sci-Fi        | 2            | 2005-08-21T23:33:57.000Z |
| 1           | New           | 2            | 2005-08-19T13:56:54.000Z |
| 1           | Action        | 2            | 2005-08-17T12:37:54.000Z |
| 1           | Music         | 2            | 2005-07-09T16:38:01.000Z |
| 1           | Sports        | 2            | 2005-07-08T07:33:56.000Z |
| 1           | Family        | 1            | 2005-08-02T18:01:38.000Z |
| 1           | Documentary   | 1            | 2005-08-01T08:51:04.000Z |
| 1           | Foreign       | 1            | 2005-07-28T16:18:23.000Z |
| 1           | Travel        | 1            | 2005-07-11T10:13:46.000Z |
| 1           | Games         | 1            | 2005-07-08T03:17:05.000Z |

### 4.4.2 Total customer rentals

Now, in order to find the ```category_percentage``` i.e. the total proportion of films watched by the customer in that category , we need the total rental counts for each customer.

```sql
DROP TABLE IF EXISTS customer_total_rentals;
CREATE TEMP TABLE customer_total_rentals AS (
SELECT
  customer_id,
  SUM(rental_count) AS total_rentals
FROM category_rental_count
GROUP BY customer_id
);

-- Display records for the first 5 customers
SELECT *
FROM customer_total_rentals
ORDER BY customer_id
LIMIT 5;
```

*Output:*

| customer_id | total_rentals |
|-------------|---------------|
| 1           | 32            |
| 2           | 27            |
| 3           | 26            |
| 4           | 22            |
| 5           | 38            |

### 4.4.3 Average category rental counts

Finally, we can calculate the ```AVG``` of all rentals across categories for all customers.

```sql
DROP TABLE IF EXISTS average_category_rental_counts;
CREATE TEMP TABLE average_category_rental_counts AS (
SELECT
  category_name,
  ROUND(
  AVG(rental_count),
  2) AS average_rental_value
FROM category_rental_count
GROUP BY category_name
);

-- Display records for the new table
SELECT *
FROM average_category_rental_counts
ORDER BY average_rental_value DESC;
```

*Output:*

| category_name | average_rental_value |
|---------------|----------------------|
| Animation     | 2.33                 |
| Sports        | 2.27                 |
| Family        | 2.19                 |
| Action        | 2.18                 |
| Sci-Fi        | 2.17                 |
| Documentary   | 2.17                 |
| Drama         | 2.12                 |
| Foreign       | 2.10                 |
| Games         | 2.04                 |
| Classics      | 2.01                 |
| New           | 2.01                 |
| Children      | 1.96                 |
| Comedy        | 1.90                 |
| Travel        | 1.89                 |
| Horror        | 1.88                 |
| Music         | 1.86                 |

It will be awkward though to tell our customers that your average is 6.27 more than the dvd rental co average in this category. So, let's just floor these values and we can do that by updating the table.

```sql
UPDATE average_category_rental_counts
SET average_rental_value = FLOOR(average_rental_value)
RETURNING *;
```

*Output:*

| category_name | average_rental_value |
|---------------|----------------------|
| Sports        | 2                    |
| Classics      | 2                    |
| New           | 2                    |
| Family        | 2                    |
| Comedy        | 1                    |
| Animation     | 2                    |
| Travel        | 1                    |
| Music         | 1                    |
| Horror        | 1                    |
| Drama         | 2                    |
| Sci-Fi        | 2                    |
| Games         | 2                    |
| Documentary   | 2                    |
| Foreign       | 2                    |
| Action        | 2                    |
| Children      | 1                    |

We can check out the new updated table to confirm if our update was successful.

```sql
SELECT *
FROM average_category_rental_counts;
```

*Output:*

Same as above!

### 4.4.4 Percentile rank

We need to display the percentile rank of the customer in terms of top X% based on that particular category. We can implement this by using the ```PERCENT_RANK``` window function. 

```sql
SELECT 
  customer_id,
  category_name,
  rental_count,
  PERCENT_RANK() OVER (
    PARTITION BY category_name
    ORDER BY rental_count DESC
  ) AS percentile
FROM category_rental_count
ORDER BY 
  customer_id,
  rental_count DESC
LIMIT 10;
```

*Output:*

| customer_id | category_name | rental_count | percentile            |
|-------------|---------------|--------------|-----------------------|
| 1           | Classics      | 6            | 0.0021413276231263384 |
| 1           | Comedy        | 5            | 0.006072874493927126  |
| 1           | Drama         | 4            | 0.03                  |
| 1           | Sports        | 2            | 0.34555984555984554   |
| 1           | Sci-Fi        | 2            | 0.30039525691699603   |
| 1           | Music         | 2            | 0.2040358744394619    |
| 1           | Animation     | 2            | 0.38877755511022044   |
| 1           | New           | 2            | 0.2676659528907923    |
| 1           | Action        | 2            | 0.33398821218074654   |
| 1           | Foreign       | 1            | 0.6178861788617886    |

Here, the percentile values are shown from range 0 to 1 which will not be useful for us so lets multiply it by 100 and take the ceiling value of it.

```sql
SELECT 
  customer_id,
  category_name,
  rental_count,
  CEILING(
      100 * PERCENT_RANK() OVER (
        PARTITION BY category_name
        ORDER BY rental_count DESC
    )
  ) AS percentile
FROM category_rental_count
ORDER BY 
  customer_id,
  rental_count DESC
LIMIT 10;
```

*Output:*

| customer_id | category_name | rental_count | percentile |
|-------------|---------------|--------------|------------|
| 1           | Classics      | 6            | 1          |
| 1           | Comedy        | 5            | 1          |
| 1           | Drama         | 4            | 3          |
| 1           | Sports        | 2            | 35         |
| 1           | Sci-Fi        | 2            | 31         |
| 1           | Music         | 2            | 21         |
| 1           | Animation     | 2            | 39         |
| 1           | New           | 2            | 27         |
| 1           | Action        | 2            | 34         |
| 1           | Foreign       | 1            | 62         |

Now, these percentile values look reasonable. Lets store these values in another temp table.

```sql
DROP TABLE IF EXISTS customer_category_percentiles;
CREATE TEMP TABLE customer_category_percentiles AS (
SELECT 
  customer_id,
  category_name,
  rental_count,
  CEILING(
      100 * PERCENT_RANK() OVER (
        PARTITION BY category_name
        ORDER BY rental_count DESC
    )
  ) AS percentile
FROM category_rental_count
);

SELECT *
FROM customer_category_percentiles
ORDER BY 
  customer_id,
  rental_count DESC
LIMIT 2;
```

*Output:*

| customer_id | category_name | rental_count | percentile |
|-------------|---------------|--------------|------------|
| 1           | Classics      | 6            | 1          |
| 1           | Comedy        | 5            | 1          |

## 4.5 Joining temporary tables

So, now that we have created multiple temporary tables for different aggregations, we can join them in a same as before using ```INNER JOIN```. 

```sql
DROP TABLE IF EXISTS customer_category_join_table;
CREATE TEMP TABLE customer_category_join_table AS (
SELECT
  t1.customer_id,
  t1.category_name,
  t1.rental_count,
  t2.total_rentals,
  t3.average_rental_value,
  t4.percentile
FROM category_rental_count AS t1
INNER JOIN customer_total_rentals AS t2
  ON t1.customer_id = t2.customer_id
INNER JOIN average_category_rental_counts as t3
  ON t1.category_name = t3.category_name
INNER JOIN customer_category_percentiles AS t4
  ON t1.customer_id = t4.customer_id
  AND t1.category_name = t4.category_name
);

SELECT *
FROM customer_category_join_table
WHERE customer_id = 1
ORDER BY percentile;
```

*Output:*

| customer_id | category_name | rental_count | total_rentals | average_rental_value | percentile |
|-------------|---------------|--------------|---------------|----------------------|------------|
| 1           | Classics      | 6            | 32            | 2                    | 1          |
| 1           | Comedy        | 5            | 32            | 1                    | 1          |
| 1           | Drama         | 4            | 32            | 2                    | 3          |
| 1           | Music         | 2            | 32            | 1                    | 21         |
| 1           | New           | 2            | 32            | 2                    | 27         |
| 1           | Sci-Fi        | 2            | 32            | 2                    | 31         |
| 1           | Action        | 2            | 32            | 2                    | 34         |
| 1           | Sports        | 2            | 32            | 2                    | 35         |
| 1           | Animation     | 2            | 32            | 2                    | 39         |
| 1           | Travel        | 1            | 32            | 1                    | 58         |
| 1           | Games         | 1            | 32            | 2                    | 61         |
| 1           | Foreign       | 1            | 32            | 2                    | 62         |
| 1           | Documentary   | 1            | 32            | 2                    | 65         |
| 1           | Family        | 1            | 32            | 2                    | 66         |

