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

Let's select a few columns that are very important for our project. As we have to find the ```rental_value``` at a customer_id level, we'll need the following two columns for that.

1. ```customer_id```
2. ```category_name```

And the first table we should begin with the ```rental``` table as it contains most of the information we need w.r.t rentals and customers along with inventory_id which we then need to map to the film and then based on the film_id extract it's category from the category table.

Right now we will skip the 6th & 7th table containing the actor details which we'll come back to later on. So, our final version of the joins mapping journey will look something like this.

| Join Journey Part | Start               | 	End                | 	Foreign Key       |
|-------------------|---------------------|---------------------|--------------------|
| Part 1            | ```rental```        | ```inventory```     | ```inventory_id``` |
| Part 2            | ```inventory```     | ```film```          | ```film_id```      |
| Part 3            | ```film```          | ```film_category``` | ```film_id```      |
| Part 4            | ```film_category``` | ```category```      | ```category_id```  |




