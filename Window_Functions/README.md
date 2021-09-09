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

Here, every time you try to run the RANDOM() function, it'll give you a different output. Therefore, in order to get the same output every time you run the query with random function, you can ```SETSEED(.)``` select whose values range from -1 to 1.

```sql
SELECT SETSEED(0.8);

-- CTE method
WITH summarized_data AS (
SELECT
  measure
FROM health.user_logs
-- RANDOM() returns 0 <= value < 1 when there are no argument inputs!
WHERE RANDOM() <= 0.1
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
| blood_pressure | 261       | 4239  |
| blood_glucose  | 3717      | 4239  |
| weight         | 261       | 4239  |

## 4. Ordered Window Functions

We have already used the ```PARTITION BY``` clause before to divide the data based on the column. Now, we will use the ```ORDER BY``` clause with window functions which works same as it would in a regular SQL query.

Let's create a new sample dataset with a little bit changes from above.

```sql
DROP TABLE IF EXISTS customer_sales;
CREATE TEMP TABLE customer_sales AS
WITH input_data (customer_id, sales_date, sales) AS (
 VALUES
 ('A', '2021-01-01'::DATE, 300),
 ('A', '2021-01-02'::DATE, 150),
 ('B', '2021-01-03'::DATE, 100),
 ('B', '2021-01-02'::DATE, 200)
)
SELECT * FROM input_data;
```

| customer_id | sales_date               | sales |
|-------------|--------------------------|-------|
| A           | 2021-01-01T00:00:00.000Z | 300   |
| A           | 2021-01-02T00:00:00.000Z | 150   |
| B           | 2021-01-03T00:00:00.000Z | 100   |
| B           | 2021-01-02T00:00:00.000Z | 200   |

Let's use the ```RANK()``` window function which ranks your output based on their order in the table. Here, we might want to ```ORDER BY``` the rows based on a column so the ranks are correct.

```sql
SELECT 
  customer_id,
  sales_date,
  sales,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY sales_date DESC
  ) AS sales_date_rank
FROM customer_sales;
```

*Output:*

| customer_id | sales_date               | sales | sales_date_rank |
|-------------|--------------------------|-------|-----------------|
| A           | 2021-01-02T00:00:00.000Z | 150   | 1               |
| A           | 2021-01-01T00:00:00.000Z | 300   | 2               |
| B           | 2021-01-03T00:00:00.000Z | 100   | 1               |
| B           | 2021-01-02T00:00:00.000Z | 200   | 2               |

If we remove the partition by clause from the rank function, it will run but on all the rows.

```sql
SELECT 
  customer_id,
  sales_date,
  sales,
  RANK() OVER (
    ORDER BY sales_date DESC
  ) AS sales_date_rank
FROM customer_sales;
```

*Output:*

| customer_id | sales_date               | sales | sales_date_rank |
|-------------|--------------------------|-------|-----------------|
| B           | 2021-01-03T00:00:00.000Z | 100   | 1               |
| A           | 2021-01-02T00:00:00.000Z | 150   | 2               |
| B           | 2021-01-02T00:00:00.000Z | 200   | 2               |
| A           | 2021-01-01T00:00:00.000Z | 300   | 4               |

### 4.1 Different ordering window functions

The most popular ordered window function calculations are the following - note that all of them do not need any inputs:

These function return integers:

- ```ROW_NUMBER()```
- ```RANK()```
- ```DENSE_RANK()```

These functions return outputs between 0 and 1:

- ```PERCENT_RANK()```
- ```CUME_DIST()```

There is also a function called ```NTILE(100)```, but the only difference is you need to pass an input from 1 to 100 to divide the input into n percentiles.

### 4.2 Ascending By

```sql
DROP TABLE IF EXISTS ordered_window_metrics;
CREATE TABLE ordered_window_metrics AS (
SELECT 
  measure_value,
  ROW_NUMBER() OVER (ORDER BY measure_value) AS row_number,
  RANK() OVER (ORDER BY measure_value) AS rank,
  DENSE_RANK() OVER (ORDER BY measure_value) AS dense_rank,
  ROUND(
    PERCENT_RANK() OVER (ORDER BY measure_value)::NUMERIC,
    5
  ) AS percent_rank,
  ROUND(
    CUME_DIST() OVER (ORDER BY measure_value)::NUMERIC,
    5
  ) AS cume_dist,
  NTILE(100) OVER (ORDER BY measure_value) AS ntile
FROM health.user_logs
WHERE measure = 'weight'
);
```

*Output:*

None

Top 10 largest values of our new table with all the ordered rank window functions implemented:

```sql
SELECT *
FROM ordered_window_metrics
ORDER BY measure_value DESC
LIMIT 10;
```

*Output:*

| measure_value | row_number | rank | dense_rank | percent_rank | cume_dist | ntile |
|---------------|------------|------|------------|--------------|-----------|-------|
| 39642120      | 2781       | 2781 | 982        | 0.99964      | 1.00000   | 100   |
| 39642120      | 2782       | 2781 | 982        | 0.99964      | 1.00000   | 100   |
| 576484        | 2780       | 2780 | 981        | 0.99928      | 0.99928   | 100   |
| 200.487664    | 2779       | 2779 | 980        | 0.99892      | 0.99892   | 100   |
| 190.4         | 2778       | 2778 | 979        | 0.99856      | 0.99856   | 100   |
| 188.69427     | 2777       | 2777 | 978        | 0.99820      | 0.99820   | 100   |
| 186.8799      | 2776       | 2776 | 977        | 0.99784      | 0.99784   | 100   |
| 185.51913     | 2775       | 2775 | 976        | 0.99748      | 0.99748   | 100   |
| 175.086512    | 2774       | 2774 | 975        | 0.99712      | 0.99712   | 100   |
| 173.725736    | 2773       | 2773 | 974        | 0.99676      | 0.99676   | 100   |

First 10 smallest values of our new table with all the ordered rank window functions implemented:

```sql
SELECT *
FROM ordered_window_metrics
ORDER BY measure_value
LIMIT 10;
```

*Output:*

| measure_value | row_number | rank | dense_rank | percent_rank | cume_dist | ntile |
|---------------|------------|------|------------|--------------|-----------|-------|
| 0             | 2          | 1    | 1          | 0.00000      | 0.00072   | 1     |
| 0             | 1          | 1    | 1          | 0.00000      | 0.00072   | 1     |
| 1.814368      | 3          | 3    | 2          | 0.00072      | 0.00108   | 1     |
| 2.26796       | 4          | 4    | 3          | 0.00108      | 0.00180   | 1     |
| 2.26796       | 5          | 4    | 3          | 0.00108      | 0.00180   | 1     |
| 8             | 6          | 6    | 4          | 0.00180      | 0.00216   | 1     |
| 10.432616     | 7          | 7    | 5          | 0.00216      | 0.00252   | 1     |
| 11.3398       | 8          | 8    | 6          | 0.00252      | 0.00288   | 1     |
| 12.700576     | 9          | 9    | 7          | 0.00288      | 0.00324   | 1     |
| 15.422128     | 10         | 10   | 8          | 0.00324      | 0.00359   | 1     |

### 4.3 Descending By

We can also implement the above where all the row values are sorted in a descending order based on the ```measure_value``` column. This time, lets remove the ```WHERE``` filter and apply the window functions across all measures.

```sql
DROP TABLE IF EXISTS ordered_window_metrics_desc;
CREATE TABLE ordered_window_metrics_desc AS (
SELECT 
  measure,
  measure_value,
  ROW_NUMBER() OVER (
    PARTITION BY measure
    ORDER BY measure_value DESC
  ) AS row_number,
  RANK() OVER (
    PARTITION BY measure
    ORDER BY measure_value DESC
  ) AS rank,
  DENSE_RANK() OVER (
    PARTITION BY measure
    ORDER BY measure_value DESC
  ) AS dense_rank,
  ROUND(
    PERCENT_RANK() OVER (
      PARTITION BY measure
      ORDER BY measure_value DESC)::NUMERIC,
    5
  ) AS percent_rank,
  ROUND(
    CUME_DIST() OVER (
      PARTITION BY measure
      ORDER BY measure_value DESC)::NUMERIC,
    5
  ) AS cume_dist,
  NTILE(100) OVER (ORDER BY measure_value DESC) AS ntile
FROM health.user_logs
);
```

Now, we check the top 3 values for each ```measure``` value.

```sql
SELECT *
FROM ordered_window_metrics_desc
WHERE row_number <=3
ORDER BY 
  measure,
  measure_value DESC;
```

*Output:*

| measure        | measure_value | row_number | rank | dense_rank | percent_rank | cume_dist | ntile |
|----------------|---------------|------------|------|------------|--------------|-----------|-------|
| blood_glucose  | 227228        | 1          | 1    | 1          | 0.00000      | 0.00003   | 1     |
| blood_glucose  | 5400          | 2          | 2    | 2          | 0.00003      | 0.00005   | 1     |
| blood_glucose  | 4500          | 3          | 3    | 3          | 0.00005      | 0.00008   | 1     |
| blood_pressure | 189           | 1          | 1    | 1          | 0.00000      | 0.00041   | 30    |
| blood_pressure | 184           | 2          | 2    | 2          | 0.00041      | 0.00124   | 32    |
| blood_pressure | 184           | 3          | 2    | 2          | 0.00041      | 0.00124   | 32    |
| weight         | 39642120      | 1          | 1    | 1          | 0.00000      | 0.00072   | 1     |
| weight         | 39642120      | 2          | 1    | 1          | 0.00000      | 0.00072   | 1     |
| weight         | 576484        | 3          | 3    | 2          | 0.00072      | 0.00108   | 1     |

### 4.4 Combining Ascending and Descending by

Let's now create a sql query with only a ```ROW_NUMBER``` function but this time we'll order it in both ascending as well as descending order.

```sql
DROP TABLE IF EXISTS combined_row_numbers;
CREATE TABLE combined_row_numbers AS (
SELECT 
  measure,
  measure_value,
  ROW_NUMBER() OVER (
    PARTITION BY measure
    ORDER BY measure_value
  ) AS ascending,
  ROW_NUMBER() OVER (
    PARTITION BY measure
    ORDER BY measure_value DESC
  ) AS descending
FROM health.user_logs
);
```

Let's go ahead and take first and last 3 rows of each ```measure``` from our newly created table based on ```measure_value``` count.

```sql
SELECT *,
  CASE
    WHEN ascending <= 3 THEN 'Bottom 3'
    WHEN descending <= 3 THEN 'Top 3'
    END AS value_ranking
FROM combined_row_numbers
WHERE 
  ascending <=3 OR
  descending <=3
ORDER BY
  measure,
  measure_value;
```

*Output:*

| measure        | measure_value | ascending | descending | value_ranking |
|----------------|---------------|-----------|------------|---------------|
| blood_glucose  | -1            | 1         | 38692      | Bottom 3      |
| blood_glucose  | 0             | 2         | 38691      | Bottom 3      |
| blood_glucose  | 0             | 3         | 38690      | Bottom 3      |
| blood_glucose  | 4500          | 38690     | 3          | Top 3         |
| blood_glucose  | 5400          | 38691     | 2          | Top 3         |
| blood_glucose  | 227228        | 38692     | 1          | Top 3         |
| blood_pressure | 0             | 1         | 2260       | Bottom 3      |
| blood_pressure | 0             | 2         | 2262       | Bottom 3      |
| blood_pressure | 0             | 3         | 2263       | Bottom 3      |
| blood_pressure | 184           | 2415      | 2          | Top 3         |
| blood_pressure | 184           | 2416      | 3          | Top 3         |
| blood_pressure | 189           | 2417      | 1          | Top 3         |
| weight         | 0             | 1         | 2782       | Bottom 3      |
| weight         | 0             | 2         | 2781       | Bottom 3      |
| weight         | 1.814368      | 3         | 2780       | Bottom 3      |
| weight         | 576484        | 2780      | 3          | Top 3         |
| weight         | 39642120      | 2781      | 2          | Top 3         |
| weight         | 39642120      | 2782      | 1          | Top 3         |

## 5. Advanced Window Functions

We will be using a new dataset which contains the bitcoins trading values for a few days. 

```sql
SELECT *
FROM trading.daily_btc
LIMIT 5;
```

*Output:*

| market_date | open_price | high_price | low_price  | close_price | adjusted_close_price | volume   |
|-------------|------------|------------|------------|-------------|----------------------|----------|
| 2014-09-17  | 465.864014 | 468.174011 | 452.421997 | 457.334015  | 457.334015           | 21056800 |
| 2014-09-18  | 456.859985 | 456.859985 | 413.104004 | 424.440002  | 424.440002           | 34483200 |
| 2014-09-19  | 424.102997 | 427.834991 | 384.532013 | 394.795990  | 394.795990           | 37919700 |
| 2014-09-20  | 394.673004 | 423.295990 | 389.882996 | 408.903992  | 408.903992           | 36863600 |
| 2014-09-21  | 408.084991 | 412.425995 | 393.181000 | 398.821014  | 398.821014           | 26580100 |

### 5.1 Lag & Lead Window Functions

Lag and Lead window functions do not perform calculations on the window frame records - but rather they simply grab the value before or after the current row respectively.

#### 5.1.1 Indentifying null values

There are number of ways where you could get the rows which contain any null values. One way is called propagation of ```NULL``` values where you add ```NULL``` value to a number and it'll simply return a null!

```sql
SELECT *
FROM trading.daily_btc
WHERE (
  open_price+high_price+low_price+
  close_price+adjusted_close_price+volume
) IS NULL;
```

*Output:*

| market_date | open_price | high_price | low_price | close_price | adjusted_close_price | volume |
|--------------------------|------------|------------|-----------|-------------|----------------------|--------|
| 2020-04-17  | null       | null       | null      | null        | null                 | null   |
| 2020-10-09  | null       | null       | null      | null        | null                 | null   |
| 2020-10-12  | null       | null       | null      | null        | null                 | null   |
| 2020-10-13  | null       | null       | null      | null        | null                 | null   |

Let's save this date for future use when we do the lag and lead functions

```sql
WHERE market_date IN (
    '2020-04-17',
    '2020-10-09',
    '2020-10-12',
    '2020-10-13'
)
```

#### 5.1.2 Filling Null values

Let's try to fill in the null value for our first date ```2020-04-17```, which contains all nulls. 

```sql
SELECT *
FROM trading.daily_btc
WHERE market_date BETWEEN ('2020-04-17'::DATE - 1) AND ('2020-04-17'::DATE + 1);
```

*Output:*

| market_date | open_price  | high_price  | low_price   | close_price | adjusted_close_price | volume      |
|-------------|-------------|-------------|-------------|-------------|----------------------|-------------|
| 2020-04-16  | 6640.454102 | 7134.450684 | 6555.504395 | 7116.804199 | 7116.804199          | 46783242377 |
| 2020-04-17  | null        | null        | null        | null        | null                 | null        |
| 2020-04-18  | 7092.291504 | 7269.956543 | 7089.247070 | 7257.665039 | 7257.665039          | 32447188386 |

There are a couple of ways with which we can fill in the ```NULL``` values viz. 1) mean/mode/median of that column, 2) fill it up with 0. But, as these are trade prices we cannot do either of two as it doesn't make any sense. Instead, what we can do is fill it with the previous day value using ```LAG``` window function.

Let's try filling out the ```open_price``` column for the above table. 

```sql
SELECT 
  market_date,
  open_price,
  LAG(open_price, 1) OVER(ORDER BY market_date) AS lag_open_price
FROM trading.daily_btc
WHERE market_date BETWEEN ('2020-04-17'::DATE - 1) AND ('2020-04-17'::DATE + 1);
```

*Output:*

| market_date | open_price  | lag_open_price |
|-------------|-------------|----------------|
| 2020-04-16  | 6640.454102 | null           |
| 2020-04-17  | null        | 6640.454102    |
| 2020-04-18  | 7092.291504 | null           |

Here, we can see that the lag price for the date ```2020-04-16``` is still null mainly because of the WHERE clause we have used. So, to solve this there is a third option in the LAG() function which will fill in the default value we mention.

```sql
SELECT 
  market_date,
  open_price,
  LAG(open_price, 1, 6000::NUMERIC) OVER(ORDER BY market_date) AS lag_open_price
FROM trading.daily_btc
WHERE market_date BETWEEN ('2020-04-17'::DATE - 1) AND ('2020-04-17'::DATE + 1);
```

*Output:*

| market_date | open_price  | lag_open_price |
|-------------|-------------|----------------|
| 2020-04-16  | 6640.454102 | 6000           |
| 2020-04-17  | null        | 6640.454102    |
| 2020-04-18  | 7092.291504 | null           |

Next is the ```LEAD()``` window function which works exactly the same way as lag but instead of looking at the previous row value, it will take in the next row value.

```sql
SELECT 
  market_date,
  open_price,
  LAG(open_price, 1, 6000::NUMERIC) OVER(ORDER BY market_date) AS lag_open_price,
  LEAD(open_price, 1, 7000::NUMERIC) OVER (ORDER BY market_date DESC) AS lead_open_price
FROM trading.daily_btc
WHERE market_date BETWEEN ('2020-04-17'::DATE - 1) AND ('2020-04-17'::DATE + 1);
```

*Output:*

| market_date | open_price  | lag_open_price | lead_open_price |
|-------------|-------------|----------------|-----------------|
| 2020-04-16  | 6640.454102 | 6000           | 7000            |
| 2020-04-17  | null        | 6640.454102    | 6640.454102     |
| 2020-04-18  | 7092.291504 | null           | null            |

#### 5.1.3 Coalesce to update null rows

Now that we have learned the proper use of ```LAG``` & ```LEAD```, lets see how we can use them to update the null row values. 

```sql
WITH april_17_data AS (
SELECT 
  market_date,
  open_price,
  LAG(open_price, 1) OVER (ORDER BY market_date) AS lag_open_price
FROM trading.daily_btc
WHERE market_date BETWEEN ('2020-04-17'::DATE - 1) AND ('2020-04-17'::DATE + 1)
)

SELECT
  market_date,
  open_price,
  lag_open_price,
  COALESCE(open_price, lag_open_price) AS coalesce_open_price
FROM april_17_data;
```

*Output:*

| market_date | open_price  | lag_open_price | coalesce_open_price |
|-------------|-------------|----------------|---------------------|
| 2020-04-16  | 6640.454102 | null           | 6640.454102         |
| 2020-04-17  | null        | 6640.454102    | 6640.454102         |
| 2020-04-18  | 7092.291504 | null           | 7092.291504         |

### 5.2 Update tables

Here, we update our null values in the table using ```LAG``` window function. Let's just create a new temporary table.

```sql
DROP TABLE IF EXISTS updated_daily_btc;
CREATE TEMP TABLE updated_daily_btc AS (
SELECT
  market_date,
  COALESCE(
    open_price,
    LAG(open_price, 1) OVER (ORDER BY market_date)
  ) AS open_price,
  COALESCE(
    high_price,
    LAG(high_price, 1) OVER (ORDER BY market_date)
  ) AS high_price,
  COALESCE(
    low_price,
    LAG(low_price, 1) OVER (ORDER BY market_date)
  ) AS low_price,
  COALESCE(
    close_price,
    LAG(close_price, 1) OVER (ORDER BY market_date)
  ) AS close_price,
    COALESCE(
    adjusted_close_price,
    LAG(adjusted_close_price, 1) OVER (ORDER BY market_date)
  ) AS adjusted_close_price,
    COALESCE(
    volume,
    LAG(volume, 1) OVER (ORDER BY market_date)
  ) AS volume
FROM trading.daily_btc
);
```

Now, we should check the values for the null rows that we previously mentioned. It should be filled up with new values.

```sql
SELECT *
FROM updated_daily_btc
WHERE market_date IN (
    '2020-04-17',
    '2020-10-09',
    '2020-10-12',
    '2020-10-13'
);
```

*Output:*

| market_date | open_price   | high_price   | low_price    | close_price  | adjusted_close_price | volume      |
|-------------|--------------|--------------|--------------|--------------|----------------------|-------------|
| 2020-04-17  | 6640.454102  | 7134.450684  | 6555.504395  | 7116.804199  | 7116.804199          | 46783242377 |
| 2020-10-09  | 10677.625000 | 10939.799805 | 10569.823242 | 10923.627930 | 10923.627930         | 21962121001 |
| 2020-10-12  | 11296.082031 | 11428.813477 | 11288.627930 | 11384.181641 | 11384.181641         | 19968627060 |
| 2020-10-13  | null         | null         | null         | null         | null                 | null        |

Looks like the values are not updated for the date ```2020-10-13```. Lets check it out why that is happening. We can pull up that date from our main table.

```sql
SELECT *
FROM trading.daily_btc
WHERE market_date BETWEEN ('2020-10-10'::DATE) AND ('2020-10-14'::DATE);
```

*Output:*

| market_date | open_price   | high_price   | low_price    | close_price  | adjusted_close_price | volume      |
|-------------|--------------|--------------|--------------|--------------|----------------------|-------------|
| 2020-10-10  | 11059.142578 | 11442.210938 | 11056.940430 | 11296.361328 | 11296.361328         | 22877978588 |
| 2020-10-11  | 11296.082031 | 11428.813477 | 11288.627930 | 11384.181641 | 11384.181641         | 19968627060 |
| 2020-10-12  | null         | null         | null         | null         | null                 | null        |
| 2020-10-13  | null         | null         | null         | null         | null                 | null        |
| 2020-10-14  | 11429.047852 | 11539.977539 | 11307.831055 | 11429.506836 | 11429.506836         | 24103426719 |

So, there is a null value before ```2020-10-13``` as well hence we are getting NULL in LAG function output too. Let's fix that by changing the OFFSET value to 2.

Lets create a copy of our newly created temp table and see how we can update this row value when market_date = ```2020-10-13```.

```sql
DROP TABLE IF EXISTS testing_updated_daily_btc;
CREATE TABLE testing_updated_daily_btc AS (
SELECT * FROM updated_daily_btc
);
```

As we cannot use window functions in an update query, we'll have to delete that row of the columns and then insert it again with the ```LAG``` value and offset = 2.

```sql
DELETE FROM testing_updated_daily_btc
WHERE market_date = '2020-10-13'
RETURNING *;
```

*Output:*

| market_date | open_price | high_price | low_price | close_price | adjusted_close_price | volume |
|-------------|------------|------------|-----------|-------------|----------------------|--------|
| 2020-10-13  | null       | null       | null      | null        | null                 | null   |

Now, let's insert the new values into this table. Since, we already know that we need to fill in the values of ```2020-10-12``` for```2020-10-13``` as well, we can do it directly or use a CTE to insert it.

```sql
INSERT INTO testing_updated_daily_btc
WITH calculated_values AS(
SELECT
  market_date,
  COALESCE(
    open_price,
    LAG(open_price, 1) OVER (ORDER BY market_date),
    LAG(open_price, 2) OVER (ORDER BY market_date)
  ) AS open_price,
  COALESCE(
    high_price,
    LAG(high_price, 1) OVER (ORDER BY market_date),
    LAG(open_price, 2) OVER (ORDER BY market_date)
  ) AS high_price,
  COALESCE(
    low_price,
    LAG(low_price, 1) OVER (ORDER BY market_date),
    LAG(open_price, 2) OVER (ORDER BY market_date)
  ) AS low_price,
  COALESCE(
    close_price,
    LAG(close_price, 1) OVER (ORDER BY market_date),
    LAG(open_price, 2) OVER (ORDER BY market_date)
  ) AS close_price,
    COALESCE(
    adjusted_close_price,
    LAG(adjusted_close_price, 1) OVER (ORDER BY market_date),
    LAG(open_price, 2) OVER (ORDER BY market_date)
  ) AS adjusted_close_price,
    COALESCE(
    volume,
    LAG(volume, 1) OVER (ORDER BY market_date),
    LAG(open_price, 2) OVER (ORDER BY market_date)
  ) AS volume
FROM trading.daily_btc
WHERE market_date BETWEEN ('2020-10-11'::DATE) AND ('2020-10-13'::DATE)
)

SELECT *
FROM calculated_values
WHERE market_date = '2020-10-13'
RETURNING *;
```

*Output:*

| market_date | open_price   | high_price   | low_price    | close_price  | adjusted_close_price | volume       |
|-------------|--------------|--------------|--------------|--------------|----------------------|--------------|
| 2020-10-13  | 11296.082031 | 11296.082031 | 11296.082031 | 11296.082031 | 11296.082031         | 11296.082031 |

Or we could have done it just manually as mentioned above.

```sql
INSERT INTO testing_updated_daily_btc
SELECT
  '2020-10-13'::DATE AS market_date,
  open_price,
  high_price,
  low_price,
  close_price,
  adjusted_close_price,
  volume
FROM testing_updated_daily_btc
WHERE market_date = '2020-10-12'
RETURNING *;
```

*Output:*

| market_date | open_price   | high_price   | low_price    | close_price  | adjusted_close_price | volume       |
|-------------|--------------|--------------|--------------|--------------|----------------------|--------------|
| 2020-10-13  | 11296.082031 | 11296.082031 | 11296.082031 | 11296.082031 | 11296.082031         | 11296.082031 |

### 5.3 Window Clause Simplification

We can try to simplify the OVER() clause used every time the ```LAG``` window function is called by using the ```WINDOW``` clause and assign an alias to it after we do the FROM statement.

```sql
DROP TABLE IF EXISTS updated_daily_btc;
CREATE TABLE updated_daily_btc AS (
SELECT 
  market_date,
  COALESCE(
    open_price,
    LAG(open_price) OVER w
  ) AS open_price,
    COALESCE(
    high_price,
    LAG(high_price) OVER w
  ) AS high_price,
    COALESCE(
    low_price,
    LAG(low_price) OVER w
  ) AS low_price,
    COALESCE(
    close_price,
    LAG(close_price) OVER w
  ) AS close_price,
    COALESCE(
    adjusted_close_price,
    LAG(adjusted_close_price) OVER w
  ) AS adjusted_close_price,
    COALESCE(
    volume,
    LAG(volume) OVER w
  ) AS volume
FROM trading.daily_btc
WINDOW
  w AS (ORDER BY market_date),
  not_w AS (ORDER BY market_date DESC)
);

-- Display some values of our new updated table
SELECT *
FROM updated_daily_btc
WHERE market_date BETWEEN ('2020-10-08'::DATE) AND ('2020-10-12'::DATE);
```

*Output:*

| market_date | open_price   | high_price   | low_price    | close_price  | adjusted_close_price | volume      |
|-------------|--------------|--------------|--------------|--------------|----------------------|-------------|
| 2020-10-08  | 10677.625000 | 10939.799805 | 10569.823242 | 10923.627930 | 10923.627930         | 21962121001 |
| 2020-10-09  | 10677.625000 | 10939.799805 | 10569.823242 | 10923.627930 | 10923.627930         | 21962121001 |
| 2020-10-10  | 11059.142578 | 11442.210938 | 11056.940430 | 11296.361328 | 11296.361328         | 22877978588 |
| 2020-10-11  | 11296.082031 | 11428.813477 | 11288.627930 | 11384.181641 | 11384.181641         | 19968627060 |
| 2020-10-12  | 11296.082031 | 11428.813477 | 11288.627930 | 11384.181641 | 11384.181641         | 19968627060 |

### 5.4 Cumulative Calculations

We can also use Window function to do cumulative calculations based of a column value. For eg, in the above table if we want a cumulative sum of the volume after every day, we can do something as below:

```sql
WITH volume_data AS (
SELECT
  market_date,
  volume
FROM updated_daily_btc
ORDER BY market_date
LIMIT 5
)

SELECT 
  market_date,
  volume,
  SUM(volume) OVER (ORDER BY market_date) AS cumulative_sum
FROM volume_data;
```

*Output:*

| market_date | volume   | cumulative_sum |
|-------------|----------|----------------|
| 2014-09-17  | 21056800 | 21056800       |
| 2014-09-18  | 34483200 | 55540000       |
| 2014-09-19  | 37919700 | 93459700       |
| 2014-09-20  | 36863600 | 130323300      |
| 2014-09-21  | 26580100 | 156903400      |

## 6. Window Frame Clause

The various combinations of window frame options are determined by the intersection of 3 components:

1. Window Frame Modes
    - ```RANGE``` VS ```ROWS``` (VS ```GROUPS```)

2. Start and End Frames
    - ```PRECEDING``` VS ```FOLLOWING```
    - ```UNBOUNDED``` VS ```OFFSET```

3. Frame Exclusions
    - ```CURRENT ROWS``` VS ```TIES``` VS ```NO OTHERS``` (VS ```GROUP```)

```GROUPS``` is only available in few flavors of SQL including PostgreSQL & SQLite.

Let's create a sample dataset and go through all of these components of the window frame clause. The table only contains one column called ```val``` and we use ```ROW_NUMBER()```, ```DENSE_RANK()``` to create additional columns based of the value in ```val```.

```sql
DROP TABLE IF EXISTS frame_example;
CREATE TEMP TABLE frame_example AS
WITH input_data (val) AS (
 VALUES
 (1),
 (1),
 (2),
 (6),
 (9),
 (9),
 (20),
 (20),
 (25)
)
SELECT
  val,
  ROW_NUMBER() OVER w AS _row_number,
  DENSE_RANK() OVER w AS _dense_rank
FROM input_data
WINDOW
  w AS (ORDER BY val);

SELECT * FROM frame_example;
```

*Output:*

| val | _row_number | _dense_rank |
|-----|-------------|-------------|
| 1   | 1           | 1           |
| 1   | 2           | 1           |
| 2   | 3           | 2           |
| 6   | 4           | 3           |
| 9   | 5           | 4           |
| 9   | 6           | 4           |
| 20  | 7           | 5           |
| 20  | 8           | 5           |
| 25  | 9           | 6           |

### 6.1 Default cumulative sum

When we did the cumulative sum earlier for the volume, we used the default window frame clause. Lets try to implement the ```SUM``` but this time on the ```val``` column of our new table.

```sql
SELECT
  val,
  SUM(val) OVER (
    ORDER BY val
    -- Default window frame clause
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cum_sum,
  _row_number,
  _dense_rank
FROM frame_example;
```

*Output:*

| val | cum_sum | _row_number | _dense_rank |
|-----|---------|-------------|-------------|
| 1   | 2       | 1           | 1           |
| 1   | 2       | 2           | 1           |
| 2   | 4       | 3           | 2           |
| 6   | 10      | 4           | 3           |
| 9   | 28      | 5           | 4           |
| 9   | 28      | 6           | 4           |
| 20  | 68      | 7           | 5           |
| 20  | 68      | 8           | 5           |
| 25  | 93      | 9           | 6           |

### 6.2 Window Frame Modes

As mentioned above, there are three different window frame modes that we can use with PostgreSQL viz ```RANGE```, ```ROWS``` & ```GROUPS```.

- ```ROWS```: The row mode instructs the database to treat each input row separately as individual entities.
- ```GROUPS```: Group mode is made exactly for duplicates. While sorting, group mode groups all rows with same 
                value as one entity.
- ```RANGE```: RANGE mode is different from the previous two, because it doesn’t tie the rows together in any way. It
               instructs the database to work on a given range of values instead. Postgres imposes a requirement, that in this mode you can put only one column in the ORDER BY clause.

```sql
SELECT
  val,
  SUM(val) OVER (
    ORDER BY val
    -- Default window frame clause
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS _range,
  SUM(val) OVER (
    ORDER BY val
    -- Default window frame clause
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS _rows,
  SUM(val) OVER (
    ORDER BY val
    -- Default window frame clause
    GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS _groups,
  _row_number,
  _dense_rank
FROM frame_example;
```

*Output:*

| val | _range | _rows | _groups | _row_number | _dense_rank |
|-----|--------|-------|---------|-------------|-------------|
| 1   | 2      | 1     | 2       | 1           | 1           |
| 1   | 2      | 2     | 2       | 2           | 1           |
| 2   | 4      | 4     | 4       | 3           | 2           |
| 6   | 10     | 10    | 10      | 4           | 3           |
| 9   | 28     | 19    | 28      | 5           | 4           |
| 9   | 28     | 28    | 28      | 6           | 4           |
| 20  | 68     | 48    | 68      | 7           | 5           |
| 20  | 68     | 68    | 68      | 8           | 5           |
| 25  | 93     | 93    | 93      | 9           | 6           |

#### 6.2.1 Unbounded Preceding and Current Row

Having a start frame of ```UNBOUNDED PRECEDING``` means to include records from the start of the window frame.

And, An end frame of ```CURRENT ROW``` means to only include up to the current record for the window function calculation.

By default the frame is given as below:

```FRAME MODE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW```

This can be changed. A few other options that can be used are:

- ```UNBOUNDED PRECEDING```: (possible only in frame_start) start with the first row of the partition
- ```UNBOUNDED FOLLOWING```: (possible only as a frame_end) end with the last row of the partition
- ```OFFSET PRECEDING```: start/end with a given number of rows before the current row
- ```OFFSET FOLLOWING```: start/end with a given number of rows after the current row
- ```CURRENT ROW```: start/end with the current row

### 6.2.2 Frame Exclusion

Frame exclusion allows you to exclude some rows from the window frame, even if they are included in the frame_start & frame_end options. The various options that can be used are:

- ```EXCLUDE CURRENT ROW```: exclude the current row
- ```EXCLUDE GROUP```: exclude the current row and all peer rows, i.e rows that have the same value in the sorting column
- ```EXCLUDE TIES```: exclude all peer rows, but not the current row
- ```EXCLUDE NO OTHERS```: exclude nothing. This is the option that is there by default

Lets try out all the above options with an example using ```RANGE``` window function.

```sql
SELECT
  val,
  SUM(val) OVER (
    ORDER BY val
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS default,
  SUM(val) OVER (
    ORDER BY val
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE CURRENT ROW
  ) AS _exclude_current_row,
  SUM(val) OVER (
    ORDER BY val
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE TIES
  ) AS _exclude_ties,
  SUM(val) OVER (
    ORDER BY val
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE GROUP
  ) AS _exclude_group,
  _row_number,
  _dense_rank
FROM frame_example;
```

<details>
<summary>Click here to view output</summary>
<br>

| val | default | _exclude_current_row | _exclude_ties | _exclude_group | _row_number | _dense_rank |
|-----|---------|----------------------|---------------|----------------|-------------|-------------|
| 1   | 2       | 1                    | 1             | null           | 1           | 1           |
| 1   | 2       | 1                    | 1             | null           | 2           | 1           |
| 2   | 4       | 2                    | 4             | 2              | 3           | 2           |
| 6   | 10      | 4                    | 10            | 4              | 4           | 3           |
| 9   | 28      | 19                   | 19            | 10             | 5           | 4           |
| 9   | 28      | 19                   | 19            | 10             | 6           | 4           |
| 20  | 68      | 48                   | 48            | 28             | 7           | 5           |
| 20  | 68      | 48                   | 48            | 28             | 8           | 5           |
| 25  | 93      | 68                   | 93            | 68             | 9           | 6           |

</details>

Now, lets also try this same for the ```ROWS``` and ```GROUP``` function.

For ```ROWS```:

```sql
SELECT
  val,
  SUM(val) OVER (
    ORDER BY val
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS default,
  SUM(val) OVER (
    ORDER BY val
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE CURRENT ROW
  ) AS _exclude_current_row,
  SUM(val) OVER (
    ORDER BY val
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE TIES
  ) AS _exclude_ties,
  SUM(val) OVER (
    ORDER BY val
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE GROUP
  ) AS _exclude_group,
  _row_number,
  _dense_rank
FROM frame_example;
```

<details>
<summary>Click here to view output</summary>
<br>

| val | default | _exclude_current_row | _exclude_ties | _exclude_group | _row_number | _dense_rank |
|-----|---------|----------------------|---------------|----------------|-------------|-------------|
| 1   | 1       | null                 | 1             | null           | 1           | 1           |
| 1   | 2       | 1                    | 1             | null           | 2           | 1           |
| 2   | 4       | 2                    | 4             | 2              | 3           | 2           |
| 6   | 10      | 4                    | 10            | 4              | 4           | 3           |
| 9   | 19      | 10                   | 19            | 10             | 5           | 4           |
| 9   | 28      | 19                   | 19            | 10             | 6           | 4           |
| 20  | 48      | 28                   | 48            | 28             | 7           | 5           |
| 20  | 68      | 48                   | 48            | 28             | 8           | 5           |
| 25  | 93      | 68                   | 93            | 68             | 9           | 6           |

</details>

For ```GROUP```:

```sql
SELECT
  val,
  SUM(val) OVER (
    ORDER BY val
    GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS default,
  SUM(val) OVER (
    ORDER BY val
    GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE CURRENT ROW
  ) AS _exclude_current_row,
  SUM(val) OVER (
    ORDER BY val
    GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE TIES
  ) AS _exclude_ties,
  SUM(val) OVER (
    ORDER BY val
    GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    EXCLUDE GROUP
  ) AS _exclude_groups,
  _row_number,
  _dense_rank
FROM frame_example;
```

<details>
<summary>Click here to view output</summary>
<br>

| val | default | _exclude_current_row | _exclude_ties | _exclude_groups | _row_number | _dense_rank |
|-----|---------|----------------------|---------------|-----------------|-------------|-------------|
| 1   | 2       | 1                    | 1             | null            | 1           | 1           |
| 1   | 2       | 1                    | 1             | null            | 2           | 1           |
| 2   | 4       | 2                    | 4             | 2               | 3           | 2           |
| 6   | 10      | 4                    | 10            | 4               | 4           | 3           |
| 9   | 28      | 19                   | 19            | 10              | 5           | 4           |
| 9   | 28      | 19                   | 19            | 10              | 6           | 4           |
| 20  | 68      | 48                   | 48            | 28              | 7           | 5           |
| 20  | 68      | 48                   | 48            | 28              | 8           | 5           |
| 25  | 93      | 68                   | 93            | 68              | 9           | 6           |

</details>

## 7. Window function Examples

### 7.1 Weekly volume comparison

Lets go back to our bitcoin dataset and use window functions to solve for the following questions.

1. What is the average daily volume of Bitcoin for the last 7 days?
2. Create a 1/0 flag if a specific day is higher than the last 7 days volume average
3. What is the percentage of weeks (starting on a Monday) where there are 4 or more days with increased volume?
4. How many high volume weeks are there broken down by year for the weeks with 5-7 days above the 7 day volume average  excluding 2021?

> What is the average daily volume of Bitcoin for the last 7 days?

> Create a 1/0 flag if a specific day is higher than the last 7 days volume average

We will solve the above questions 1 & 2 from a single query.

```sql
WITH window_calculations AS (
SELECT
  market_date,
  volume,
  AVG(volume) OVER (
    ORDER BY market_date
    RANGE BETWEEN '7 DAYS' PRECEDING and '1 DAY' PRECEDING
  ) AS past_weekly_avg_volume
FROM updated_daily_btc
)

SELECT
  market_date,
  volume,
  CASE
    WHEN volume > past_weekly_avg_volume THEN 1
    ELSE 0
    END AS volume_flag
FROM window_calculations
ORDER BY market_date DESC
LIMIT 10;
```

*Output:*

| market_date | volume       | volume_flag |
|-------------|--------------|-------------|
| 2021-02-24  | 88364793856  | 1           |
| 2021-02-23  | 106102492824 | 1           |
| 2021-02-22  | 92052420332  | 1           |
| 2021-02-21  | 51897585191  | 0           |
| 2021-02-20  | 68145460026  | 0           |
| 2021-02-19  | 63495496918  | 0           |
| 2021-02-18  | 52054723579  | 0           |
| 2021-02-17  | 80820545404  | 1           |
| 2021-02-16  | 77049582886  | 0           |
| 2021-02-15  | 77069903166  | 0           |

> What is the percentage of weeks (starting on a Monday) where there are 4 or more days with increased volume?

```sql
WITH window_calculations AS (
  SELECT
    market_date,
    volume,
    AVG(volume) OVER (
      ORDER BY market_date
      RANGE BETWEEN '7 DAYS' PRECEDING and '1 DAY' PRECEDING
    ) AS past_weekly_avg_volume
  FROM updated_daily_btc
),
-- generate the date
date_calculations AS (
  SELECT
    market_date,
    DATE_TRUNC('week', market_date)::DATE AS start_of_week,
    volume,
    CASE
      WHEN volume > past_weekly_avg_volume THEN 1
      ELSE 0
      END AS volume_flag
  FROM window_calculations
),
-- aggregate the metrics and calculate a percentage
aggregated_weeks AS (
  SELECT
    start_of_week,
    SUM(volume_flag) AS weekly_high_volume_days
  FROM date_calculations
  GROUP BY 1
)
-- finally calculate the percentage
SELECT
  weekly_high_volume_days,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_weeks
FROM aggregated_weeks
GROUP BY 1
ORDER BY 1;
```
*Output:*

| weekly_high_volume_days | percentage_of_weeks |
|-------------------------|---------------------|
| 0                       | 6.23                |
| 1                       | 13.65               |
| 2                       | 20.47               |
| 3                       | 20.47               |
| 4                       | 18.99               |
| 5                       | 11.87               |
| 6                       | 6.23                |
| 7                       | 2.08                |

> How many high volume weeks are there broken down by year for the weeks with 5-7 days above the 7 day volume average  excluding 2021?

```sql
WITH window_calculations AS (
  SELECT
    market_date,
    volume,
    AVG(volume) OVER (
      ORDER BY market_date
      RANGE BETWEEN '7 DAYS' PRECEDING and '1 DAY' PRECEDING
    ) AS past_weekly_avg_volume
  FROM updated_daily_btc
),
-- generate the date
date_calculations AS (
  SELECT
    market_date,
    DATE_TRUNC('week', market_date)::DATE AS start_of_week,
    volume,
    CASE
      WHEN volume > past_weekly_avg_volume THEN 1
      ELSE 0
      END AS volume_flag
  FROM window_calculations
),
-- aggregate the metrics and calculate a percentage
aggregated_weeks AS (
  SELECT
    start_of_week,
    SUM(volume_flag) AS weekly_high_volume_days
  FROM date_calculations
  GROUP BY 1
)
-- finally calculate the percentage by year
SELECT
  -- here we demonstrate how to use EXTRACT as an alternative to DATE_TRUNC
  EXTRACT(YEAR FROM start_of_week) AS market_year,
  COUNT(*) AS high_volume_weeks,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total
FROM aggregated_weeks
WHERE weekly_high_volume_days >= 5
AND start_of_week < '2021-01-01'::DATE
GROUP BY 1
ORDER BY 1;
```

*Output:*

| market_year | high_volume_weeks | percentage_of_total |
|-------------|-------------------|---------------------|
| 2014        | 2                 | 2.99                |
| 2015        | 3                 | 4.48                |
| 2016        | 13                | 19.40               |
| 2017        | 17                | 25.37               |
| 2018        | 8                 | 11.94               |
| 2019        | 11                | 16.42               |
| 2020        | 13                | 19.40               |

### 7.2 Moving Averages

For the following time windows: 14, 28, 60, 150 days - calculate the following metrics for the ```close_price``` column:

1. Moving average
2. Moving standard deviation
3. The maximum and minimum values

```sql
SELECT
  market_date,
  -- Averages
  ROUND(AVG(close_price) OVER w_14, 2) AS avg_14,
  ROUND(AVG(close_price) OVER w_28, 2) AS avg_28,
  ROUND(AVG(close_price) OVER w_60, 2) AS avg_60,
  ROUND(AVG(close_price) OVER w_150, 2) AS avg_150,
  -- Standard Deviation
  ROUND(STDDEV(close_price) OVER w_14, 2) AS std_14,
  ROUND(STDDEV(close_price) OVER w_28, 2) AS std_28,
  ROUND(STDDEV(close_price) OVER w_60, 2) AS std_60,
  ROUND(STDDEV(close_price) OVER w_150, 2) AS std_150,
  -- Max 
  ROUND(MAX(close_price) OVER w_14) AS max_14,
  ROUND(MAX(close_price) OVER w_28) AS max_28,
  ROUND(MAX(close_price) OVER w_60) AS max_60,
  ROUND(MAX(close_price) OVER w_150) AS max_150,
  -- Min
  ROUND(MIN(close_price) OVER w_14) AS min_14,
  ROUND(MIN(close_price) OVER w_28) AS min_28,
  ROUND(MIN(close_price) OVER w_60) AS min_60,
  ROUND(MIN(close_price) OVER w_150) AS min_150
FROM updated_daily_btc
WINDOW
  w_14 AS (ORDER BY market_date RANGE BETWEEN '14 DAYS' PRECEDING AND '1 DAY' PRECEDING),
  w_28 AS (ORDER BY market_date RANGE BETWEEN '28 DAYS' PRECEDING AND '1 DAY' PRECEDING),
  w_60 AS (ORDER BY market_date RANGE BETWEEN '60 DAYS' PRECEDING AND '1 DAY' PRECEDING),
  w_150 AS (ORDER BY market_date RANGE BETWEEN '150 DAYS' PRECEDING AND '1 DAY' PRECEDING)
ORDER BY market_date DESC
LIMIT 10;
```

<details>
<summary>Click to view output</summary>
<br>

| market_date | avg_14   | avg_28   | avg_60   | avg_150  | std_14  | std_28  | std_60  | std_150  | max_14 | max_28 | max_60 | max_150 | min_14 | min_28 | min_60 | min_150 |
|-------------|----------|----------|----------|----------|---------|---------|---------|----------|--------|--------|--------|---------|--------|--------|--------|---------|
| 2021-02-24  | 50692.02 | 43782.42 | 38381.99 | 24867.56 | 3920.87 | 8248.24 | 8118.44 | 12581.79 | 57540  | 57540  | 57540  | 57540   | 44918  | 30433  | 26272  | 10565   |
| 2021-02-23  | 50524.64 | 43201.89 | 37979.32 | 24613.76 | 4054.47 | 8449.78 | 8190.56 | 12478.84 | 57540  | 57540  | 57540  | 57540   | 44918  | 30433  | 24665  | 10565   |
| 2021-02-22  | 49952.43 | 42421.86 | 37471.47 | 24323.73 | 4060.04 | 8404.19 | 8111.59 | 12290.56 | 57540  | 57540  | 57540  | 57540   | 44918  | 30433  | 23736  | 10565   |
| 2021-02-21  | 48621.26 | 41520.06 | 36899.83 | 24011.77 | 4420.16 | 8069.97 | 7878.55 | 12032.98 | 56100  | 56100  | 56100  | 56100   | 38903  | 30433  | 23241  | 10565   |
| 2021-02-20  | 47418.86 | 40661.77 | 36361.22 | 23705.94 | 4517.89 | 7732.86 | 7644.92 | 11792.53 | 55888  | 55888  | 55888  | 55888   | 38903  | 30433  | 23241  | 10226   |
| 2021-02-19  | 46151.45 | 39844.55 | 35809.80 | 23403.61 | 4447.54 | 7258.69 | 7401.92 | 11540.55 | 52149  | 52149  | 52149  | 52149   | 38144  | 30433  | 22803  | 10226   |
| 2021-02-18  | 45097.61 | 39099.76 | 35339.76 | 23128.83 | 4772.88 | 7066.69 | 7271.37 | 11351.93 | 52149  | 52149  | 52149  | 52149   | 36926  | 30433  | 22803  | 10226   |
| 2021-02-17  | 44049.26 | 38506.86 | 34868.44 | 22854.09 | 4716.45 | 6613.17 | 7077.27 | 11141.61 | 49200  | 49200  | 49200  | 49200   | 36926  | 30433  | 22803  | 10226   |
| 2021-02-16  | 43071.43 | 38037.92 | 34434.07 | 22600.05 | 4978.29 | 6284.20 | 6981.90 | 10969.97 | 48717  | 48717  | 48717  | 48717   | 35510  | 30433  | 22803  | 10226   |
| 2021-02-15  | 42042.29 | 37633.82 | 34015.07 | 22353.38 | 5367.32 | 5979.96 | 6911.33 | 10811.09 | 48717  | 48717  | 48717  | 48717   | 33537  | 30433  | 22803  | 10226   |

</details>

### 7.3 Statistical Analysis

