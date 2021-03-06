# 2. Data Analysis

## 2.1 Define the final state

Looking back at the email template that we have to work on using SQL, the key columns that we will need to generate include the following data points at a customer_id level:

- ```category_name```: The name of the top 2 ranking categories
- ```rental_count```: How many total films have they watched in this category
- ```average_comparison```: How many more films has the customer watched compared to the average DVD Rental Co customer
- ```percentile```: How does the customer rank in terms of the top X% compared to all other customers in this film category?
- ```category_percentage```: What proportion of total films watched does this category make up?

And the final output should look something like this.

| customer_id  | category_ranking | category_name | rental_count | average_comparison | percentile | category_percentage |
|--------------|------------------|---------------|--------------|--------------------|------------|---------------------|
| 1            | 1                | Classics      | 6            | 4                  | 1          | 19                  |
| 1            | 2                | Comedy        | 5            | 4                  | 2          | 16                  |
| 2            | 1                | Sports        | 5            | 3                  | 7          | 19                  |
| 2            | 2                | Classics      | 4            | 2                  | 11         | 15                  |
| 3            | 1                | Action        | 4            | 2                  | 14         | 15                  |

And so on.....

## 2.2 Reverse Engineering

As we can see from the above output table, the main thing we need is a ```rental_count``` at the customer_id level. The columns like ```average_comparison```, ```percentile``` and  ```category_percentage``` are all dependent on the rental_count.

Also, we need the top two categories for each customer along with the category name. Something like,

| customer_id  | category_name | rental_count |
|--------------|---------------|--------------|
| 1            | Classics      | 6            |
| 1            | Comedy        | 5            |
| 2            | Sports        | 5            |
| 2            | Action        | 4            |

But, in order to find the average_comparison and percentile, we need to find these values for all the customer watched categories.

## 2.3 Mapping the joining journey

Let's select a few columns that are very important for our project. As we have to find the ```rental_value``` at a customer_id level, we'll need the following two columns for that.

1. ```customer_id```
2. ```category_name```

And the first table we should begin with the ```rental``` table as it contains most of the information we need w.r.t rentals and customers along with inventory_id which we then need to map to the film and then based on the film_id extract it's category from the category table.

Right now we will skip the 6th & 7th table containing the actor details which we'll come back to later on. So, our final version of the joins mapping journey will look something like this.

| Join Journey Part | Start               |  End                |  Foreign Key       |
|-------------------|---------------------|---------------------|--------------------|
| Part 1            | ```rental```        | ```inventory```     | ```inventory_id``` |
| Part 2            | ```inventory```     | ```film```          | ```film_id```      |
| Part 3            | ```film```          | ```film_category``` | ```film_id```      |
| Part 4            | ```film_category``` | ```category```      | ```category_id```  |

## 2.4 Deciding Which Type of Joins to use

We can define our purpose and come up with some questions which will help us in deciding the type of joins we should use. For eg,

> We need to keep all of the customer rental records from ```dvd_rentals.rental``` and match up each record with its equivalent film_id value from the ```dvd_rentals.inventory``` table.

There are two type of joins we can think of viz, Left Join and Inner Join. Let's dig up a bit further to decide which join suits for our problem solving more.

### 2.4.1 Key Analytical Questions

There are a few questions we need to look up at before deciding which join to use.

1. How many records exist per ```inventory_id``` value in ```rental``` or ```inventory``` tables?
2. How many overlapping and missing unique foreign key values are there between the two tables?

Now, here comes the 2 phase approach that we going to use in order to answer the above questions. First, generating some hypotheses about the data and then try to validate it to see if we are correct.

### 2.4.2 Generating some hypotheses looking at the data

We have seen that the rental table has records for all the customer's rental history along with the inventory id of the films. A particular film can have multiple copies tied to a unique customer id. Looking at this and the data exploration, we can generate some hypotheses as follows:

1. The number of unique ```inventory_id``` records will be equal in both ```dvd_rentals.rental``` and ```dvd_rentals.inventory``` tables
2. There will be a multiple records per unique ```inventory_id``` in the ```dvd_rentals.rental``` table
3. There will be multiple ```inventory_id``` records per unique ```film_id``` value in the ```dvd_rentals.inventory``` table

Next, we'll try to validate our hypotheses so far for further analysis.

### 2.4.3 Validating the hypotheses using the given data

We can use SQL to solve for the same.

#### 2.4.3.1 Hypothesis 1

> The number of unique ```inventory_id``` records will be equal in both ```dvd_rentals.rental``` and ```dvd_rentals.inventory``` tables

First, we'll check for the unique number of inventory_id present in the rental table.

```sql
SELECT 
  COUNT(DISTINCT inventory_id)
FROM dvd_rentals.rental;
```

*Output:*

| count |
|-------|
| 4580  |

Let's also take a look at the inventory table for the same. As per our hypotheses, it should be the same as the rental table.

```sql
SELECT 
  COUNT(DISTINCT inventory_id)
FROM dvd_rentals.inventory;
```

*Output:*

| count |
|-------|
| 4581  |

As we can see, our first hyptheses seem to fail as we got 1 more unique ```inventory_id``` in the inventory table when compared to the rental table.

#### 2.4.3.2 Hypotheses 2

> There will be a multiple records per unique ```inventory_id``` in the ```dvd_rentals.rental``` table

```sql
-- first we generate group by counts on the target_column_values
WITH counts_base AS (
SELECT 
  inventory_id AS target_column_values,
  COUNT(*) AS row_count
FROM dvd_rentals.rental
GROUP BY target_column_values
)

-- we then group by again on the row_count to summarize our results
SELECT
  row_count,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_count
ORDER BY row_count;
```

*Output:*

| row_count | count_of_target_values |
|-----------|------------------------|
| 1         | 4                      |
| 2         | 1126                   |
| 3         | 1151                   |
| 4         | 1160                   |
| 5         | 1139                   |

Hence, we can confirm that there are multiple rows per ```inventory_id``` in our rental table.

Let's move on to check our last hypotheses.

### 2.3.4.3 Hypotheses 3

> There will be multiple ```inventory_id``` records per unique ```film_id``` value in the ```dvd_rentals.inventory``` table

We can use the same approach as above.

```sql
-- first we generate group by counts on the target_column_values
WITH counts_base AS (
SELECT 
  film_id AS target_column_values,
  COUNT(*) AS row_count
FROM dvd_rentals.inventory
GROUP BY target_column_values
)

-- we then group by again on the row_count to summarize our results
SELECT
  row_count,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_count
ORDER BY row_count;
```

*Output:*

| row_count | count_of_target_values |
|-----------|------------------------|
| 2         | 133                    |
| 3         | 131                    |
| 4         | 183                    |
| 5         | 136                    |
| 6         | 187                    |
| 7         | 116                    |
| 8         | 72                     |

And we can confirm that our hypotheses 3 is valid and indeed there are multiple ```inventory_id per``` unique ```film_id```.

### 2.3.5 Returning to our 2 key questions

1. How many records exist per ```inventory_id``` value in ```rental``` or ```inventory``` tables?
2. How many overlapping and missing unique foreign key values are there between the two tables?

For the first question, let's check the number of unique number of inventory_id in both the tables.

> How many records exist per ```inventory_id``` value in ```rental``` or ```inventory``` tables?

**rental distribution analysis on ```inventory_id``` foreign key**

```sql
-- first we generate group by counts on the target_column_values
WITH counts_base AS (
SELECT 
  inventory_id AS target_column_values,
  COUNT(*) AS row_count
FROM dvd_rentals.rental
GROUP BY target_column_values
)

-- we then group by again on the row_count to summarize our results
SELECT
  row_count,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_count
ORDER BY row_count;
```

*Output:*

| row_count | count_of_target_values |
|-----------|------------------------|
| 1         | 4                      |
| 2         | 1126                   |
| 3         | 1151                   |
| 4         | 1160                   |
| 5         | 1139                   |

Here, we can see that there are mutiple records present for a unique ```inventory_id``` in the ```rental``` table which shows a one-to-many relationship.

Also, the output shows that there are 4 unique inventory_id with exactly one row record, while there are 1126 ```inventory_id``` with 2 row_counts, etc.

**inventory distribution analysis on ```inventory_id``` foreign key**

```sql
-- first we generate group by counts on the target_column_values
WITH counts_base AS (
SELECT 
  inventory_id AS target_column_values,
  COUNT(*) AS row_count
FROM dvd_rentals.inventory
GROUP BY target_column_values
)

-- we then group by again on the row_count to summarize our results
SELECT
  row_count,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_count
ORDER BY row_count;
```

*Output:*

| row_count | count_of_target_values |
|-----------|------------------------|
| 1         | 4581                   |

As compared to the ```rental``` table, the ```inventory``` table contains only 1 row per unique inventory_id showing a one-to-one relationship.

Now, let's move on to the second question.

> How many overlapping and missing unique foreign key values are there between the two tables?

So, let's first find out the number of foreign keys that exist only in the left table or the ```rental``` table.

```sql
SELECT
  COUNT(DISTINCT inventory_id) 
FROM dvd_rentals.rental
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.inventory
  WHERE rental.inventory_id = inventory.inventory_id
);
```

*Output:*

| count |
|-------|
| 0     |

Now, we can confirm that all the foreign keys that are present in the left table i.e. ```rental``` table are present in the ```inventory``` table as well.

Let's also check if it's the same case with the right table i.e. ```inventory``` table.

```sql
SELECT
  COUNT(DISTINCT inventory_id) 
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);
```

*Output:*

| count |
|-------|
| 1     |

And, we have found one value that only exists in the ```inventory``` table. Let's investigate this further.

```sql
SELECT *
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);
```

*Output:*

| inventory_id | film_id | store_id | last_update              |
|--------------|---------|----------|--------------------------|
| 5            | 1       | 2        | 2006-02-15T05:09:17.000Z |

This is the only record that's odd as compared to the other records. It contains details about an inventory and the film it belongs to. It might be possible that this inventory was never rented out by a customer. The intersection of the foreign keys between the two tables can be found by the following query.

```sql
SELECT
  COUNT(DISTINCT inventory_id) 
FROM dvd_rentals.rental
WHERE EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.inventory
  WHERE rental.inventory_id = inventory.inventory_id
);
```

*Output:*

| count |
|-------|
| 4580  |

Now, that we have analyzed and checked, let's move on to the Table Joining part.
