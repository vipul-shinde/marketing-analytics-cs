[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)]()
[![forthebadge](images/badges/uses-postgresql.svg)]()
[![forthebadge](https://forthebadge.com/images/badges/made-with-markdown.svg)]()

<p align="center">
    <img src="images\Marketing_Analytics.png" alt="marketing-analytics">
</p>

<h1 align="center">Marketing Analytics Case Study - Serious SQL</h1>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]()
  [![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)]() 
  [![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)]()
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> This is a tutorial guided marketing analytics case study from the <a href="www.datawithdanny.com">Serious SQL</a> course by Danny Ma. The marketing team have shared with us a draft of the email they wish to send to their customers.
    <br> 
</p>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
  - [Requirement #1](#requirement_1)
  - [Requirement #2](#requirement_2)
  - [Requirement #3&4](#requirement_3&4)
  - [Requirement #5](#requirement_5)
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [TODO](../TODO.md)
- [Contributing](../CONTRIBUTING.md)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

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

