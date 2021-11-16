USE magist;

#### Expand the database #### 
-- Find online a dataset that contains the abbreviations for the Brazilian states and the full names of the states.
-- It does not need to contain any other information about the states, but it is ok if it does.
-- Import the dataset as an SQL table in the Magist database.
# Create the new table
DROP TABLE IF EXISTS brazil_state;
CREATE TABLE brazil_state (
  Abbreviation char(2),
  State char(200),
  Capital char(200) , 
  primary key (Abbreviation)
) ;

SELECT * FROM brazil_state;

 # change the column names in the new table
ALTER TABLE brazil_state
RENAME COLUMN Abbreviation TO abb;
ALTER TABLE brazil_state
RENAME COLUMN State TO state_name;
ALTER TABLE brazil_state
RENAME COLUMN Capital TO capital;

# here we have to import the data to the brazil_state from a csv file 
SELECT * FROM brazil_state;
SELECT * FROM geo;

## modify the state column from geo, change from text to char(2)
ALTER TABLE geo 
MODIFY COLUMN state CHAR(2);

## add the foriegn key to the new table
SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE geo
ADD FOREIGN KEY (state) REFERENCES brazil_state(Abbreviation);

DESCRIBE geo;


SELECT * FROM brazil_state;

SELECT * FROM geo;

-- Create the appropriate relationships with other tables in the database.

SELECT * 
FROM geo
LEFT JOIN brazil_state 
ON geo.state = brazil_state.abb;
##################################################################################################
#### Analyze customer reviews ####
##################################################################################################
-- Find the average review score by state of the customer.


SELECT state_name, state, AVG(review_score) 
FROM order_reviews
LEFT JOIN orders
ON order_reviews.order_id = orders.order_id
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
LEFT JOIN geo
ON customers.customer_zip_code_prefix = geo.zip_code_prefix
LEFT JOIN brazil_state
ON geo.state = brazil_state.abb
GROUP BY state; 


-- Do reviews containing positive words have a better score? Some Portuguese positive words are: “bom”, “otimo”, “gostei”, “recomendo” and “excelente”.

SELECT state_name, abb,  review_comment_message, AVG(review_score)
FROM order_reviews
LEFT JOIN orders
ON order_reviews.order_id = orders.order_id
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
LEFT JOIN geo
ON customers.customer_zip_code_prefix = geo.zip_code_prefix
LEFT JOIN brazil_state
ON geo.state = brazil_state.abb
WHERE review_comment_message IN ("bom", "otimo", "gostei", "recomendo", "excelente")
GROUP BY abb; # yes

-- Considering only states having at least 30 reviews containing these words, what is the state with the highest score?

SELECT state_name, state, COUNT(review_score), AVG(review_score)  
FROM order_reviews
LEFT JOIN orders
ON order_reviews.order_id = orders.order_id
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
LEFT JOIN geo
ON customers.customer_zip_code_prefix = geo.zip_code_prefix
LEFT JOIN brazil_state
ON geo.state = brazil_state.abb
WHERE review_comment_message IN ("bom", "otimo", "gostei", "recomendo", "excelente")
GROUP BY abb
HAVING COUNT(review_score) > 30
ORDER BY AVG(review_score)DESC; 

-- What is the state where there is a greater score change between all reviews and reviews containing positive words?
DROP TABLE IF EXISTS with_pos;
CREATE TEMPORARY TABLE with_pos
SELECT abb, state_name, AVG(review_score) AS review_score_with 
FROM order_reviews
LEFT JOIN orders
ON order_reviews.order_id = orders.order_id
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
LEFT JOIN geo
ON customers.customer_zip_code_prefix = geo.zip_code_prefix
LEFT JOIN brazil_state
ON geo.state = brazil_state.abb
WHERE review_comment_message IN ("bom", "otimo", "gostei", "recomendo", "excelente")
GROUP BY abb
HAVING COUNT(review_score) > 30
ORDER BY AVG(review_score)DESC; 

SELECT * FROM with_pos;

DROP TABLE IF EXISTS without_pos;
CREATE TEMPORARY TABLE without_pos
SELECT abb, state_name, AVG(review_score) AS review_score_without 
FROM order_reviews
LEFT JOIN orders
ON order_reviews.order_id = orders.order_id
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
LEFT JOIN geo
ON customers.customer_zip_code_prefix = geo.zip_code_prefix
LEFT JOIN brazil_state
ON geo.state = brazil_state.abb
GROUP BY abb
HAVING COUNT(review_score) > 30
ORDER BY AVG(review_score)DESC; 

SELECT * FROM with_pos;
SELECT * FROM without_pos;


SELECT with_pos.abb, with_pos.state_name, review_score_without, review_score_with, (review_score_with  - review_score_without)
FROM with_pos
LEFT JOIN without_pos
ON with_pos.abb = without_pos.abb
ORDER BY (review_score_with  - review_score_without)DESC;



