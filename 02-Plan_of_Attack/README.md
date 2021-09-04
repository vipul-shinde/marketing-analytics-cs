# 1. Define the final state

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

# 2. Reverse Engineering

As we can see from the above output table, the main thing we need is a ```rental_count``` at the customer_id level. The columns like ```average_comparison```, ```percentile``` and  ```category_percentage``` are all dependent on the rental_count.

Also, we need the top two categories for each customer along with the category name. Something like,

| customer_id  | category_name | rental_count |
|--------------|---------------|--------------|
| 1            | Classics      | 6            |
| 1            | Comedy        | 5            |
| 2            | Sports        | 5            |
| 2            | Action        | 4            |

But, in order to find the average_comparison and percentile, we need to find these values for all the customer watched categories.

# 3. Mapping the joining journey


