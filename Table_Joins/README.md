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

