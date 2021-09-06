# Window Functions

Window functions are operations or calculations performed on “window frames” or put simply, groups of rows in a dataset.

## 1. Window Function Components

Let's write down a simple window function syntax and then elaborate it further. There are basically 4 main components viz. ```CALCULATION```, ```PARTITION BY```, ```ORDER BY``` & ```FRAME CLAUSE```.

## 2. Understanding Partition by

We can understand the ```Partition BY``` easily when comparing to the ```GROUP BY``` clause.

Before that let's create a basic temp table and then further dig in with our window functions. 

```sql
DROP TABLE IF EXISTS customer_sales;
CREATE TEMP TABLE customer_sales AS
WITH input_data (customer_id, sales) AS (
 VALUES
 ('A', 300),
 ('A', 150),
 ('B', 100),
 ('B', 200)
)
SELECT * FROM input_data;
```

Firstly, we'll begin with the use of group by clause.

```sql
-- GROUP BY SUM
SELECT
  customer_id,
  SUM(sales) AS total_sales
FROM customer_sales
GROUP BY customer_id;
```

*Output:*

| customer_id | total_sales |
|-------------|-------------|
| B           | 300         |
| A           | 450         |

And now, we use the partition by clause.

```sql
-- SUM WINDOW FUNCTION
SELECT
  customer_id,
  sales,
  SUM(sales) OVER (
    PARTITION BY customer_id
  ) AS total_sales
FROM customer_sales;
```

*Output:*

| customer_id | sales | total_sales |
|-------------|-------|-------------|
| A           | 300   | 450         |
| A           | 150   | 450         |
| B           | 100   | 300         |
| B           | 200   | 300         |

### 2.1 Partition by 2 columns

Now, we'll see how partition by 2 columns works when used with a window function.

We create a new temp table for this with a few changes.

```sql
DROP TABLE IF EXISTS customer_sales;
CREATE TEMP TABLE customer_sales AS
WITH input_data (customer_id, sale_id, sales) AS (
 VALUES
 ('A', 1, 300),
 ('A', 1, 150),
 ('A', 2, 100),
 ('B', 3, 200)
)
SELECT * FROM input_data;
```

*Output:*

| customer_id | sale_id | sales |
|-------------|---------|-------|
| A           | 1       | 300   |
| A           | 1       | 150   |
| A           | 2       | 100   |
| B           | 3       | 200   |

Now, lets partition by ```customer_id``` & ```sale_id```.

```sql
-- SUM Window Function with 2 columns in PARTITION BY
SELECT 
  customer_id,
  sale_id,
  SUM(sales) OVER (
    PARTITION BY customer_id, sale_id
  ) AS total_sales
FROM customer_sales;
```

*Output:*

| customer_id | sale_id | total_sales |
|-------------|---------|-------------|
| A           | 1       | 450         |
| A           | 1       | 450         |
| A           | 2       | 100         |
| B           | 3       | 200         |

### 2.2 Multiple level partition

We can also have different level of partition for different or same window functions in a single query. Lets take a look at an example.

```sql
SELECT 
  customer_id,
  sale_id,
  SUM(sales) OVER (
    PARTITION BY customer_id, sale_id
  ) AS sum_sales,
  SUM(sales) OVER (
    PARTITION BY customer_id
  ) AS customer_sales,
  SUM(sales) OVER () AS total_sales
FROM customer_sales;
```

*Output:*

| customer_id | sale_id | sum_sales | customer_sales | total_sales |
|-------------|---------|-----------|----------------|-------------|
| A           | 1       | 450       | 550            | 750         |
| A           | 1       | 450       | 550            | 750         |
| A           | 2       | 100       | 550            | 750         |
| B           | 3       | 200       | 200            | 750         |

Lets also try another query containing two different window functions.

```sql
SELECT 
  customer_id,
  sale_id,
  SUM(sales) OVER (
    PARTITION BY 
      customer_id, 
      sale_id
  ) AS customer_sales,
  ROUND(
    AVG(sales) OVER (
    PARTITION BY customer_id
    ), 
    2
  ) AS avg_customer_sales,
  MAX(sales) OVER () AS max_sales
FROM customer_sales;
```

*Output:*

| customer_id | sale_id | customer_sales | avg_customer_sales | max_sales |
|-------------|---------|----------------|--------------------|-----------|
| A           | 1       | 450            | 183.33             | 300       |
| A           | 1       | 450            | 183.33             | 300       |
| A           | 2       | 100            | 183.33             | 300       |
| B           | 3       | 200            | 200.00             | 300       |

## 3. Limit implications and RANDOM() function

We will be using hour ```health.user_logs``` dataset from our health analytics mini case study here as shown below.

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*)/SUM(COUNT(*)) OVER (),
    2
  ) AS percentage,
  SUM(COUNT(*)) OVER() AS total
FROM health.user_logs
GROUP BY measure;
```

*Output:*

| measure        | frequency | percentage | total |
|----------------|-----------|------------|-------|
| blood_glucose  | 38692     | 88.15      | 43891 |
| blood_pressure | 2417      | 5.51       | 43891 |
| weight         | 2782      | 6.34       | 43891 |

Sometimes you want to run a query on a subset of the given dataset to quickly look on something. You can use a CTE with a ```LIMIT``` keyword and then run your query on it as shown below.

```sql
WITH summarized_data AS (
SELECT 
  measure
FROM health.user_logs
LIMIT 1000
)

SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM summarized_data
GROUP BY measure;
```

*Output:*

| measure        | frequency | total |
|----------------|-----------|-------|
| blood_glucose  | 853       | 1000  |
| blood_pressure | 68        | 1000  |
| weight         | 79        | 1000  |

But, the problem with this subset is that most of the times it may not contain data from all the given categories and our analysis can be skewed because of that. In order to solve that, we will use a window function called ```RANDOM()``` along with a ```WHERE``` clause whose values ranges from 0 to 1. Let's use this ```RANDOM()``` to subset 10% of our data.

```sql
WITH summarized_data AS (
SELECT 
  measure
FROM health.user_logs
-- Using RANDOM() window function to keep 10% of data
WHERE RANDOM() <=0.1
)

SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM summarized_data
GROUP BY measure;
```

*Output:*

| measure        | frequency | total |
|----------------|-----------|-------|
| blood_pressure | 240       | 4457  |
| blood_glucose  | 3933      | 4457  |
| weight         | 284       | 4457  |
