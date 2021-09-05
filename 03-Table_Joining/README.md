# 3. Join Implementation

| Join Journey Part | Start               | 	End             | 	Foreign Key      |
|-------------------|---------------------|---------------------|--------------------|
| Part 1            | ```rental```        | ```inventory```     | ```inventory_id``` |
| Part 2            | ```inventory```     | ```film```          | ```film_id```      |
| Part 3            | ```film```          | ```film_category``` | ```film_id```      |
| Part 4            | ```film_category``` | ```category```      | ```category_id```  |

## 3.1 Joins Part 1

After performing the analysis that it won't matter which join we chose to use as it won't make any difference for our example. We can check this ourself by running the following SQL code.

<details>
<summary>Click to see SQL code</summary>
<br>

```sql
DROP TABLE IF EXISTS left_rental_join;
CREATE TEMP TABLE left_rental_join AS
SELECT
  rental.customer_id,
  rental.inventory_id,
  inventory.film_id
FROM dvd_rentals.rental
LEFT JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id;

DROP TABLE IF EXISTS inner_rental_join;
CREATE TEMP TABLE inner_rental_join AS
SELECT
  rental.customer_id,
  rental.inventory_id,
  inventory.film_id
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id;

SELECT
  'left join' AS join_type,
  COUNT(*) AS record_count,
  COUNT(DISTINCT inventory_id) AS unique_key_values
FROM left_rental_join
  
UNION

SELECT
  'inner join' AS join_type,
  COUNT(*) AS record_count,
  COUNT(DISTINCT inventory_id) AS unique_key_values
FROM inner_rental_join;
```
</details>

*Output:*

| join_type  | record_count | unique_key_values |
|------------|--------------|-------------------|
| inner join | 16044        | 4580              |
| left join  | 16044        | 4580              |