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
  category.name AS category_name
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

