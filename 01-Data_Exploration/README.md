# 1. Data Exploration

## 1.1 rental table

The first table in our database schema is the rental table. Let's take a look at all the columns in the table. We'll limit the output to 10 rows.

```sql
SELECT * 
FROM dvd_rentals.rental
LIMIT 10;
```

*Output:*

| rental_id | rental_date              | inventory_id | customer_id | return_date              | staff_id | last_update              |
|-----------|--------------------------|--------------|-------------|--------------------------|----------|--------------------------|
| 1         | 2005-05-24T22:53:30.000Z | 367          | 130         | 2005-05-26T22:04:30.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 2         | 2005-05-24T22:54:33.000Z | 1525         | 459         | 2005-05-28T19:40:33.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 3         | 2005-05-24T23:03:39.000Z | 1711         | 408         | 2005-06-01T22:12:39.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 4         | 2005-05-24T23:04:41.000Z | 2452         | 333         | 2005-06-03T01:43:41.000Z | 2        | 2006-02-15T21:30:53.000Z |
| 5         | 2005-05-24T23:05:21.000Z | 2079         | 222         | 2005-06-02T04:33:21.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 6         | 2005-05-24T23:08:07.000Z | 2792         | 549         | 2005-05-27T01:32:07.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 7         | 2005-05-24T23:11:53.000Z | 3995         | 269         | 2005-05-29T20:34:53.000Z | 2        | 2006-02-15T21:30:53.000Z |
| 8         | 2005-05-24T23:31:46.000Z | 2346         | 239         | 2005-05-27T23:33:46.000Z | 2        | 2006-02-15T21:30:53.000Z |
| 9         | 2005-05-25T00:00:40.000Z | 2580         | 126         | 2005-05-28T00:22:40.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 10        | 2005-05-25T00:02:21.000Z | 1824         | 399         | 2005-05-31T22:44:21.000Z | 2        | 2006-02-15T21:30:53.000Z |

So, the rental table contains all the details of the films that were rented along with other details such as ```inventory_id```, ```customer_id``` along with ```rental & return date```. So, one customer can rent multiple films from different inventories for an amount of time. Let's explore this table more.

```sql
SELECT 
  COUNT(*) 
FROM dvd_rentals.rental;
```

*Output:*

| count |
|-------|
| 16044 |

Let's see all the records for one customer.

```sql
SELECT *
FROM dvd_rentals.rental
WHERE customer_id = 5
LIMIT 5;
```

*Output:*

| rental_id | rental_date              | inventory_id | customer_id | return_date              | staff_id | last_update              |
|-----------|--------------------------|--------------|-------------|--------------------------|----------|--------------------------|
| 731       | 2005-05-29T07:25:16.000Z | 4124         | 5           | 2005-05-30T05:21:16.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 1085      | 2005-05-31T11:15:43.000Z | 301          | 5           | 2005-06-07T12:02:43.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 1142      | 2005-05-31T19:46:38.000Z | 3998         | 5           | 2005-06-05T14:03:38.000Z | 1        | 2006-02-15T21:30:53.000Z |
| 1502      | 2005-06-15T22:03:14.000Z | 3277         | 5           | 2005-06-23T18:42:14.000Z | 2        | 2006-02-15T21:30:53.000Z |
| 1631      | 2005-06-16T08:01:02.000Z | 2466         | 5           | 2005-06-19T09:04:02.000Z | 1        | 2006-02-15T21:30:53.000Z |


## 1.2 inventory table

The inventory table consists of all the records of avalaible film copies and the store which they belong to.

```sql
SELECT *
FROM dvd_rentals.inventory
LIMIT 10;
```

*Output:*

| inventory_id | film_id | store_id | last_update              |
|--------------|---------|----------|--------------------------|
| 1            | 1       | 1        | 2006-02-15T05:09:17.000Z |
| 2            | 1       | 1        | 2006-02-15T05:09:17.000Z |
| 3            | 1       | 1        | 2006-02-15T05:09:17.000Z |
| 4            | 1       | 1        | 2006-02-15T05:09:17.000Z |
| 5            | 1       | 2        | 2006-02-15T05:09:17.000Z |
| 6            | 1       | 2        | 2006-02-15T05:09:17.000Z |
| 7            | 1       | 2        | 2006-02-15T05:09:17.000Z |
| 8            | 1       | 2        | 2006-02-15T05:09:17.000Z |
| 9            | 2       | 2        | 2006-02-15T05:09:17.000Z |
| 10           | 2       | 2        | 2006-02-15T05:09:17.000Z |

One film can have multiple copies across store. Let's take a look at total number of inventories.

```sql
SELECT 
  COUNT(*)
FROM dvd_rentals.inventory;
```

*Output:*

| count |
|-------|
| 4581  |

Also, let's take a look at inventory records for one particular ```film_id```.

```sql
SELECT *
FROM dvd_rentals.inventory
WHERE film_id = 10;
```

*Output:*

| inventory_id | film_id | store_id | last_update              |
|--------------|---------|----------|--------------------------|
| 46           | 10      | 1        | 2006-02-15T05:09:17.000Z |
| 47           | 10      | 1        | 2006-02-15T05:09:17.000Z |
| 48           | 10      | 1        | 2006-02-15T05:09:17.000Z |
| 49           | 10      | 1        | 2006-02-15T05:09:17.000Z |
| 50           | 10      | 2        | 2006-02-15T05:09:17.000Z |
| 51           | 10      | 2        | 2006-02-15T05:09:17.000Z |
| 52           | 10      | 2        | 2006-02-15T05:09:17.000Z |

## 1.3 film table

This is the main table containing all the details about the films available.

```sql
SELECT 
  film_id,
  title,
  description,
  release_year,
  language_id,
  rental_duration,
  rental_rate,
  length,
  replacement_cost,
  rating,
  last_update
FROM dvd_rentals.film
LIMIT 10;
```

*Output:*

| film_id | title            | description                                                                                                           | release_year | language_id | rental_duration | rental_rate | length | replacement_cost | rating | last_update              |
|---------|------------------|-----------------------------------------------------------------------------------------------------------------------|--------------|-------------|-----------------|-------------|--------|------------------|--------|--------------------------|
| 1       | ACADEMY DINOSAUR | A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies                      | 2006         | 1           | 6               | 0.99        | 86     | 20.99            | PG     | 2006-02-15T05:03:42.000Z |
| 2       | ACE GOLDFINGER   | A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China                  | 2006         | 1           | 3               | 4.99        | 48     | 12.99            | G      | 2006-02-15T05:03:42.000Z |
| 3       | ADAPTATION HOLES | A Astounding Reflection of a Lumberjack And a Car who must Sink a Lumberjack in A Baloon Factory                      | 2006         | 1           | 7               | 2.99        | 50     | 18.99            | NC-17  | 2006-02-15T05:03:42.000Z |
| 4       | AFFAIR PREJUDICE | A Fanciful Documentary of a Frisbee And a Lumberjack who must Chase a Monkey in A Shark Tank                          | 2006         | 1           | 5               | 2.99        | 117    | 26.99            | G      | 2006-02-15T05:03:42.000Z |
| 5       | AFRICAN EGG      | A Fast-Paced Documentary of a Pastry Chef And a Dentist who must Pursue a Forensic Psychologist in The Gulf of Mexico | 2006         | 1           | 6               | 2.99        | 130    | 22.99            | G      | 2006-02-15T05:03:42.000Z |


Let's also take a look at the total number of unique film id we got in the table.

```sql
SELECT 
  COUNT(DISTINCT film_id)
FROM dvd_rentals.film;
```

*Output:*

| count |
|-------|
| 1000  |

