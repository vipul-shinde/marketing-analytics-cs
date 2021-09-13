[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)]()
[![forthebadge](images/badges/uses-postgresql.svg)]()
[![forthebadge](https://forthebadge.com/images/badges/made-with-markdown.svg)]()

<p align="center">
    <img src="images\Marketing_Analytics.png" alt="marketing-analytics">
</p>

<h1 align="center">Marketing Analytics Case Study - Serious SQL 🚀</h1>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]()
  [![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)]() 
  [![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)]()
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

</div>

---

<p align="center"> This is a tutorial guided marketing analytics case study from the <a href="www.datawithdanny.com">Serious SQL</a> course by Danny Ma. The marketing team have shared with us a draft of the email they wish to send to their customers.
    <br> 
</p>

## 📝 Table of Contents

- [🧐 About](#about)
- [🎯 Getting Started](#getting_started)
  - [Requirement #1](#requirement_1)
  - [Requirement #2](#requirement_2)
  - [Requirement #3&4](#requirement_3&4)
  - [Requirement #5](#requirement_5)
- [📊 Data Exploration](#data-exploration)
- [📌 Data Analysis](#data-analysis)
- [🧲 Join Implementation](#join-implementation)
- [💥 Problem Solving](#problem-solving)
- [✨ Final Solution](#final-solution)
- [🙏 Acknowledgments](#acknowledgement)
- [🎨 Contributing](#contributing)
- [🌟 Support](#support)

## 🧐 About <a name = "about"></a>

Personalized customer emails based off marketing analytics is a winning formula for many digital companies, and this is exactly the         initiative that the leadership team at DVD Rental Co has decided to tackle!

We have been asked to support the customer analytics team at DVD Rental Co who have been tasked with generating the necessary data points required to populate specific parts of this first-ever customer email campaign.

We will be using SQL to solve the problems faced by the analytics team and fullfill the requirements for the email marketing template.

## 🎯 Getting Started <a name = "getting_started"></a>

The following email template has been shared to us by the marketing team at DVD Rental Co. They need our help in order to start a personalized marketing campaign. 

<br>

<p align="center">
    <img src="images\dvd-rental-co.png" alt="email-template" width="500px">
</p>

### Requirement 1️⃣ <a name = "requirement_1"></a>

<hr>

For each customer, we need to find the top 2 categories based on their past rental history.

<br>

<p align="center">
    <img src="images\requirement_1.png" alt="email-template" width="500px">
</p>

### Requirement 2️⃣ <a name = "requirement_2"></a>

<hr>

Next, for each of the top 2 categories, we need to recommend 3 popular films which the customer hasn't watched. Even if there is atleast 1 film that can be recommended, it's fine with the marketing team.

<br>

<p align="center">
    <img src="images\requirement_2.png" alt="email-template" width="500px">
</p>

### Requirement 3️⃣ & 4️⃣ <a name = "requirement_3&4"></a>

<hr>

Lastly, for the top 2 categories, we need to provide some individual customer insights. 

> For the 1st category, the marketing requires the following insights (requirement 3):

1. How many total films have they watched in their top category?
2. How many more films has the customer watched compared to the average DVD Rental Co customer?
3. How does the customer rank in terms of the top X% compared to all other customers in this film category?

> For the second ranking category (requirement 4):

1. How many total films has the customer watched in this category?
2. What proportion of each customer’s total films watched does this count make?

<br>

<p align="center">
    <img src="images\requirement_3&4.png" alt="email-template" width="500px">
</p>

### Requirement 5️⃣ <a name = "requirement_5"></a>

<hr>

Lastly, we need to identify the favourite actor of the customer along with the total films they have watched in which their favourite actor has starred. Also, we need to recommend upto 3 films that the customer hasn't watched so far and make sure to exclude the films that we have already recommended in the above sections.

<br>

<p align="center">
    <img src="images\requirement_5.png" alt="email-template" width="500px">
</p>

## 📊 Data Exploration <a name = "data-exploration"></a>

First, we start with the data exploration. There are 7 tables in total viz ```rental```, ```inventory```, ```film```, ```film_category```, ```category```, ```film_actor``` and ```actor```. The Entity Relationship diagram can be seen as below.

<p align="center">
    <img src="images\erd.png" alt="erd">
</p>

### Click to view 👇:

[![forthebadge](images/badges/solution-data-exploration.svg)](https://github.com/vipul-shinde/marketing-analytics-cs/tree/main/01-Data-Exploration)

## 📌 Data Analysis <a name = "data-analysis"></a>

After exploring the dataset, we start analysing the key columns and come up with a few hypotheses to understand the data in depth. After running the analysis, we come to a conclusion that for our example, it doesn't matter if we use a ```INNER JOIN``` or ```LEFT JOIN``` since all the values in our left table are present in the target table.

### Click to view 👇:

[![forthebadge](images/badges/solution-data-analysis.svg)](https://github.com/vipul-shinde/marketing-analytics-cs/tree/main/02-Data-Analysis)

## 🧲 Join Implementation <a name = "join-implementation"></a>

Next, we start implementing the table joins which will then help us to start the problem solving. From the analysis section, we have come to conclusion to the following join table sequence.

| Join Journey Part | Start               |  End                |  Foreign Key       |
|-------------------|---------------------|---------------------|--------------------|
| Part 1            | ```rental```        | ```inventory```     | ```inventory_id``` |
| Part 2            | ```inventory```     | ```film```          | ```film_id```      |
| Part 3            | ```film```          | ```film_category``` | ```film_id```      |
| Part 4            | ```film_category``` | ```category```      | ```category_id```  |

### Click to view 👇:

[![forthebadge](images/badges/solution-join-implementation.svg)](https://github.com/vipul-shinde/marketing-analytics-cs/tree/main/03-Join-Implementation)

## 💥 Problem Solving <a name = "problem-solving"></a>

Now that we have our base table after joining all the tables, we start solving for requirements 1 - 4. The final output after this section is as below. As we can see, this is what we want to fill in few of our business requirements from the email template.

| customer_id | category_rank | rental_count | average_comparison | percentile | category_percentage |
|-------------|---------------|--------------|--------------------|------------|---------------------|
| 1           | 1             | 6            | 4                  | 1          | 19                  |
| 1           | 2             | 5            | 4                  | 1          | 16                  |
| 2           | 1             | 5            | 3                  | 3          | 19                  |
| 2           | 2             | 4            | 2                  | 2          | 15                  |
| 3           | 1             | 4            | 2                  | 5          | 15                  |
| 3           | 2             | 3            | 1                  | 15         | 12                  |

### Click to view 👇:

[![forthebadge](images/badges/solution-join-implementation.svg)](https://github.com/vipul-shinde/marketing-analytics-cs/tree/main/04-Problem-Solving)

## ✨ Final Solution <a name = "final-solution"></a>

Lastly, we started implemnting the final solutions for each of the requirements. Let's take a quick look at the outputs of our tables.

### 👉 Requirement #1

<hr>

The top two categories for each customer are shown as below: (We'll only take a look at the output for customer_id =1,2)

| customer_id | category_name | rental_count | category_rank |
|-------------|---------------|--------------|---------------|
| 1           | Classics      | 6            | 1             |
| 1           | Comedy        | 5            | 2             |
| 2           | Sports        | 5            | 1             |
| 2           | Classics      | 4            | 2             |

### 👉 Requirement #2

<hr>

The film recommendations for ```customer_id = 1``` are as follows:

| customer_id | category_name | category_rank | film_id | title               | rental_count | reco_rank |
|-------------|---------------|---------------|---------|---------------------|--------------|-----------|
| 1           | Classics      | 1             | 891     | TIMBERLAND SKY      | 31           | 1         |
| 1           | Classics      | 1             | 358     | GILMORE BOILED      | 28           | 2         |
| 1           | Classics      | 1             | 951     | VOYAGE LEGALLY      | 28           | 3         |
| 1           | Comedy        | 2             | 1000    | ZORRO ARK           | 31           | 1         |
| 1           | Comedy        | 2             | 127     | CAT CONEHEADS       | 30           | 2         |
| 1           | Comedy        | 2             | 638     | OPERATION OPERATION | 27           | 3         |

### 👉 Requirement #3&4

<hr>

For the top first category, here is how the insights look like:

| customer_id | category_name | rental_count | average_comparison | percentile |
|-------------|---------------|--------------|--------------------|------------|
| 323         | Action        | 7            | 5                  | 1          |
| 506         | Action        | 7            | 5                  | 1          |
| 151         | Action        | 6            | 4                  | 1          |
| 410         | Action        | 6            | 4                  | 1          |
| 126         | Action        | 6            | 4                  | 1          |

And, for the second top category, the output table is:

| customer_id | category_name | rental_count | total_percentage |
|-------------|---------------|--------------|------------------|
| 184         | Drama         | 3            | 13               |
| 87          | Sci-Fi        | 3            | 10               |
| 477         | Travel        | 3            | 14               |
| 273         | New           | 4            | 11               |
| 550         | Drama         | 4            | 13               |

### 👉 Requirement #5

<hr>

The favorite actor for each customer can be found in the temp table ```top_actor_counts```:

| customer_id | actor_id | first_name | last_name | rental_count |
|-------------|----------|------------|-----------|--------------|
| 1           | 37       | VAL        | BOLGER    | 6            |
| 2           | 107      | GINA       | DEGENERES | 5            |
| 3           | 150      | JAYNE      | NOLTE     | 4            |
| 4           | 102      | WALTER     | TORN      | 4            |
| 5           | 12       | KARL       | BERRY     | 4            |

And, the recommendations based on their favorite actor for ```customer_id = 1``` are:

| customer_id | first_name | last_name | rental_count | title           | film_id | actor_id | reco_rank |
|-------------|------------|-----------|--------------|-----------------|---------|----------|-----------|
| 1           | VAL        | BOLGER    | 6            | PRIMARY GLASS   | 697     | 37       | 1         |
| 1           | VAL        | BOLGER    | 6            | ALASKA PHANTOM  | 12      | 37       | 2         |
| 1           | VAL        | BOLGER    | 6            | METROPOLIS COMA | 572     | 37       | 3         |

### Click to view 👇:

[![forthebadge](images/badges/solution-final-solution.svg)](https://github.com/vipul-shinde/marketing-analytics-cs/tree/main/05-Final-Solution)

