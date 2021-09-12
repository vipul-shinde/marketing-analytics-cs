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

