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

| customer_id | film_id | title           | category_name | rental_date              |
|-------------|---------|-----------------|---------------|--------------------------|
| 130         | 80      | BLANKET BEVERLY | Family        | 2005-05-24T22:53:30.000Z |
| 459         | 333     | FREAKY POCUS    | Music         | 2005-05-24T22:54:33.000Z |
| 408         | 373     | GRADUATE LORD   | Children      | 2005-05-24T23:03:39.000Z |
| 333         | 535     | LOVE SUICIDES   | Horror        | 2005-05-24T23:04:41.000Z |
| 222         | 450     | IDOLS SNATCHERS | Children      | 2005-05-24T23:05:21.000Z |

</details>