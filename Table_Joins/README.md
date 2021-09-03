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

