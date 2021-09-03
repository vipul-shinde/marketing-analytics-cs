# Introduction to Table Joins

## 1. Creating sample tables in SQL

For the purpose of learning joins let's create some temp tables with random data.

```sql
DROP TABLE IF EXISTS names;
CREATE TEMP TABLE names AS
WITH input_data (iid, first_name, title) AS (
 VALUES
 (1, 'Kate', 'Datacated Visualizer'),
 (2, 'Eric', 'Captain SQL'),
 (3, 'Danny', 'Data Wizard Of Oz'),
 (4, 'Ben', 'Mad Scientist'),
 (5, 'Dave', 'Analytics Heretic'),
 (6, 'Ken', 'The YouTuber')
)
SELECT * FROM input_data;

DROP TABLE IF EXISTS jobs;
CREATE TEMP TABLE jobs AS
WITH input_data (iid, occupation, salary) AS (
 VALUES
 (1, 'Cleaner', 'High'),
 (2, 'Janitor', 'Medium'),
 (3, 'Monkey', 'Low'),
 (6, 'Plumber', 'Ultra'),
 (7, 'Hero', 'Plus Ultra')
)
SELECT * FROM input_data;
```

*Output:*

None

We can take a look at tables by running the select query. Inspecting the ```names``` table.

```sql
SELECT * FROM names;
```

*Output:*

| iid | first_name | title                |
|-----|------------|----------------------|
| 1   | Kate       | Datacated Visualizer |
| 2   | Eric       | Captain SQL          |
| 3   | Danny      | Data Wizard Of Oz    |
| 4   | Ben        | Mad Scientist        |
| 5   | Dave       | Analytics Heretic    |
| 6   | Ken        | The YouTuber         |

Inspecting the ```jobs``` table.

```sql
SELECT * FROM jobs;
```

*Output:*

| iid | occupation | salary     |
|-----|------------|------------|
| 1   | Cleaner    | High       |
| 2   | Janitor    | Medium     |
| 3   | Monkey     | Low        |
| 6   | Plumber    | Ultra      |
| 7   | Hero       | Plus Ultra |

## 2. Basic Table Joins

### 2.1 Inner Join or Join

An inner join is used to get the intersection between two tables and only get the matching values. Let's take a look

```sql
SELECT 
  names.iid,
  names.first_name,
  names.title,
  jobs.occupation,
  jobs.salary
FROM names
INNER JOIN jobs
  ON names.iid = jobs.iid;
```

*Output:*

| iid | first_name | title                | occupation | salary |
|-----|------------|----------------------|------------|--------|
| 1   | Kate       | Datacated Visualizer | Cleaner    | High   |
| 2   | Eric       | Captain SQL          | Janitor    | Medium |
| 3   | Danny      | Data Wizard Of Oz    | Monkey     | Low    |
| 6   | Ken        | The YouTuber         | Plumber    | Ultra  |

Here, we can see the query only returned the results having iid present in both tables.

### 2.2 Left Join or Left Outer Join

A left join is used when you want to keep all the values from the left table and only return values matching from the right table. The left table is also known as the ```base``` table which you use to get the values of from the ```target``` table which is on the right. 

```sql
SELECT 
  names.iid,
  names.first_name,
  names.title,
  jobs.occupation,
  jobs.salary
FROM names
LEFT JOIN jobs
  ON names.iid = jobs.iid;
```

*Output:*

| iid | first_name | title                | occupation | salary |
|-----|------------|----------------------|------------|--------|
| 1   | Kate       | Datacated Visualizer | Cleaner    | High   |
| 2   | Eric       | Captain SQL          | Janitor    | Medium |
| 3   | Danny      | Data Wizard Of Oz    | Monkey     | Low    |
| 4   | Ben        | Mad Scientist        | null       | null   |
| 5   | Dave       | Analytics Heretic    | null       | null   |
| 6   | Ken        | The YouTuber         | Plumber    | Ultra  |

As we can see, since there is no values for the iid = 4,5 in the target table, it returns null values.

### 2.3 Full Join

A full join is used when you to get a full combination of all the values from both the tables. Let's take a look

```sql
SELECT 
  names.iid AS name_id,
  jobs.iid AS jobs_id,
  names.first_name,
  names.title,
  jobs.occupation,
  jobs.salary
FROM names
FULL JOIN jobs
  ON names.iid = jobs.iid;
```

*Output:*

| name_id | jobs_id | first_name | title                | occupation | salary     |
|---------|---------|------------|----------------------|------------|------------|
| 1       | 1       | Kate       | Datacated Visualizer | Cleaner    | High       |
| 2       | 2       | Eric       | Captain SQL          | Janitor    | Medium     |
| 3       | 3       | Danny      | Data Wizard Of Oz    | Monkey     | Low        |
| 4       | null    | Ben        | Mad Scientist        | null       | null       |
| 5       | null    | Dave       | Analytics Heretic    | null       | null       |
| 6       | 6       | Ken        | The YouTuber         | Plumber    | Ultra      |
| null    | 7       | null       | null                 | Hero       | Plus Ultra |

### 2.4 Cross Join

A cross join is used to create a full combination of all the rows that are being joined. It's more like a cartesian product of two sets. 

```sql
SELECT
  names.iid AS names_id,
  jobs.iid AS jobs_id,
  names.first_name,
  names.title,
  jobs.occupation,
  jobs.salary
FROM names
CROSS JOIN jobs;
```

*Output:*

| names_id | jobs_id | first_name | title                | occupation | salary     |
|----------|---------|------------|----------------------|------------|------------|
| 1        | 1       | Kate       | Datacated Visualizer | Cleaner    | High       |
| 1        | 2       | Kate       | Datacated Visualizer | Janitor    | Medium     |
| 1        | 3       | Kate       | Datacated Visualizer | Monkey     | Low        |
| 1        | 6       | Kate       | Datacated Visualizer | Plumber    | Ultra      |
| 1        | 7       | Kate       | Datacated Visualizer | Hero       | Plus Ultra |
| 2        | 1       | Eric       | Captain SQL          | Cleaner    | High       |
| 2        | 2       | Eric       | Captain SQL          | Janitor    | Medium     |
| 2        | 3       | Eric       | Captain SQL          | Monkey     | Low        |
| 2        | 6       | Eric       | Captain SQL          | Plumber    | Ultra      |
| 2        | 7       | Eric       | Captain SQL          | Hero       | Plus Ultra |
| 3        | 1       | Danny      | Data Wizard Of Oz    | Cleaner    | High       |
| 3        | 2       | Danny      | Data Wizard Of Oz    | Janitor    | Medium     |
| 3        | 3       | Danny      | Data Wizard Of Oz    | Monkey     | Low        |
| 3        | 6       | Danny      | Data Wizard Of Oz    | Plumber    | Ultra      |
| 3        | 7       | Danny      | Data Wizard Of Oz    | Hero       | Plus Ultra |
| 4        | 1       | Ben        | Mad Scientist        | Cleaner    | High       |
| 4        | 2       | Ben        | Mad Scientist        | Janitor    | Medium     |
| 4        | 3       | Ben        | Mad Scientist        | Monkey     | Low        |
| 4        | 6       | Ben        | Mad Scientist        | Plumber    | Ultra      |
| 4        | 7       | Ben        | Mad Scientist        | Hero       | Plus Ultra |
| 5        | 1       | Dave       | Analytics Heretic    | Cleaner    | High       |
| 5        | 2       | Dave       | Analytics Heretic    | Janitor    | Medium     |
| 5        | 3       | Dave       | Analytics Heretic    | Monkey     | Low        |
| 5        | 6       | Dave       | Analytics Heretic    | Plumber    | Ultra      |
| 5        | 7       | Dave       | Analytics Heretic    | Hero       | Plus Ultra |
| 6        | 1       | Ken        | The YouTuber         | Cleaner    | High       |
| 6        | 2       | Ken        | The YouTuber         | Janitor    | Medium     |
| 6        | 3       | Ken        | The YouTuber         | Monkey     | Low        |
| 6        | 6       | Ken        | The YouTuber         | Plumber    | Ultra      |
| 6        | 7       | Ken        | The YouTuber         | Hero       | Plus Ultra |

Alternative syntax for a cross join where you just select all the columns you need and use a comma to seperate two tables when you use FROM. For eg,

```sql
SELECT
  names.iid AS name_iid,
  jobs.iid AS job_iid,
  names.first_name,
  names.title,
  jobs.occupation,
  jobs.salary
FROM names, jobs;
```

### 2.5 Combining manual Input

We can use cross joins to combine various values using the ```||``` symbol to join words as follows.

```sql
WITH favourite_things (animal_name) AS (
VALUES
  ('Purple Elephant'),
  ('Yellow Sea Cucumber'),
  ('Turquoise Gorilla'),
  ('Invisible Unicorn')
)

SELECT 
  first_name || 'Likes' || animal_name || 's!' AS text_output
FROM names, favourite_things
WHERE first_name = 'Eric';
```

*Output:*

| text_output                    |
|--------------------------------|
| EricLikesPurple Elephants!     |
| EricLikesYellow Sea Cucumbers! |
| EricLikesTurquoise Gorillas!   |
| EricLikesInvisible Unicorns!   |



