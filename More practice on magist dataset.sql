USE magist;
SELECT * FROM products;
select * from product_category_name_translation;

# Add the translation names to the products
SELECT  *
FROM product_category_name_translation AS pct
INNER JOIN products ON pct.product_category_name = products.product_category_name
where product_category_name_english IN('perfumery'); 

## Create a temporarly table that have the english names
DROP TEMPORARY TABLE IF EXISTS products_english;
CREATE TEMPORARY TABLE products_english
	SELECT  product_category_name_english, products.product_id, orders.order_id,order_item_id,  price, order_status, payment_type, order_purchase_timestamp
	FROM product_category_name_translation AS pct
	INNER JOIN products ON pct.product_category_name = products.product_category_name
    INNER JOIN order_items ON products.product_id = order_items.product_id
    INNER JOIN orders ON order_items.order_id = orders.order_id
    INNER JOIN order_payments ON orders.order_id = order_payments.order_id
	where product_category_name_english IN('health_beauty') 
    AND order_status IN('delivered') 
    AND payment_type IN('credit_card') 
    AND YEAR(order_purchase_timestamp) IN (2018)
    AND order_items.price > 1000;
    
SELECT * FROM products_english;

SELECT *
FROM products AS p
INNER JOIN order_items AS oi ON p.product_id = oi.product_id
INNER JOIN orders AS o ON oi.order_id = o.order_id
INNER JOIN order_payments AS op ON oi.order_id = op.order_id;



## from lina
select  orders.order_delivered_customer_date, orders.order_status ,order_items.price, order_payments.payment_type, product_category_name_translation.product_category_name_english from orders 
left join order_payments
on orders.order_id = order_payments.order_id
left join order_items
on orders.order_id = order_items.order_id 
left join products
on order_items.product_id = products.product_id
left join product_category_name_translation
on products.product_category_name = product_category_name_translation.product_category_name
where product_category_name_translation.product_category_name_english = "health_beauty"
and orders.order_status = "delivered" and order_payments.payment_type = "credit_card" 
and order_items.price >1000
and YEAR(orders.order_delivered_customer_date) = 2018;
###########################################################################################################################
## Select all the products from the health_beauty or perfumery categories that
## have been paid by credit card with a payment amount of more than 1000$,
## from orders that were purchased during 2018 and have a ‘delivered’ status?

USE magist;

-- Step 1: select the perfumaria from products
SELECT p.product_id, p.product_category_name
FROM products AS p
WHERE p.product_category_name IN ('perfumaria');

-- Step 2: selsct the payment with status delivered
SELECT * 
FROM orders AS o
WHERE o.order_status IN ('delivered');

-- Step 3: select payment type with card from order_payments
SELECT *
FROM order_payments AS op
WHERE op.payment_type IN ('credit_card');

-- Step 4: the year 2018 
SELECT *
FROM orders AS o
WHERE YEAR(o.order_purchase_timestamp) IN ('2018');

-- STEP 5: more than 1000
SELECT * 
FROM order_items AS oi
WHERE oi.price > 1000;

 
-- Step 6: find the payment amount for each order_id that has multiple order_items
SELECT o.order_id, o.order_status, o.order_delivered_customer_date, oi.order_item_id, oi.price
FROM orders AS o
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
#WHERE o.order_status IN ('delivered') AND o.order_delivered_customer_date IN (SELECT YEAR('%2018%'));
WHERE o.order_status IN ('delivered') AND (SELECT YEAR(o.order_delivered_customer_date ));



-- Step 3: Inner Join the products with orders by using the order_items table
SELECT *
FROM products AS p
INNER JOIN order_items AS oi ON p.product_id = oi.product_id
INNER JOIN orders AS o ON oi.order_id = o.order_id
INNER JOIN order_payments AS op ON oi.order_id = op.order_id;

# all the above in one table
SELECT * 
FROM (
	SELECT p.product_id, p.product_category_name, o.order_id, oi.order_item_id, oi.price, op.payment_type, o.order_status, o.order_purchase_timestamp
	FROM products AS p
	INNER JOIN order_items AS oi ON p.product_id = oi.product_id
	INNER JOIN orders AS o ON oi.order_id = o.order_id
	INNER JOIN order_payments AS op ON oi.order_id = op.order_id

)t1
	where product_category_name IN('perfumaria') 
    AND order_status IN('delivered') 
    AND payment_type IN('credit_card') 
    AND YEAR(order_purchase_timestamp) IN ('2018')
   # AND price > 1000;
;


####################################
-- step 1 :  the same as above without using subqueries
SELECT  product_category_name_english, products.product_id, orders.order_id,order_item_id,  price, order_status, payment_type, order_purchase_timestamp
	FROM product_category_name_translation AS pct
	INNER JOIN products ON pct.product_category_name = products.product_category_name
    INNER JOIN order_items ON products.product_id = order_items.product_id
    INNER JOIN orders ON order_items.order_id = orders.order_id
    INNER JOIN order_payments ON orders.order_id = order_payments.order_id
	where product_category_name_english IN('health_beauty') 
    AND order_status IN('delivered') 
    AND payment_type IN('credit_card') 
    AND YEAR(order_purchase_timestamp) IN (2018)
    AND order_items.price > 1000;
 
 -- step 2
 -- The average weight of those products
 SELECT AVG(weight)
 FROM (
	SELECT  products.product_weight_g AS weight,product_category_name_english, products.product_id, orders.order_id,order_item_id,  price, order_status, payment_type, order_purchase_timestamp
	FROM product_category_name_translation AS pct
	INNER JOIN products ON pct.product_category_name = products.product_category_name
    INNER JOIN order_items ON products.product_id = order_items.product_id
    INNER JOIN orders ON order_items.order_id = orders.order_id
    INNER JOIN order_payments ON orders.order_id = order_payments.order_id
	where product_category_name_english IN('health_beauty') 
    AND order_status IN('delivered') 
    AND payment_type IN('credit_card') 
    AND YEAR(order_purchase_timestamp) IN (2018)
    AND order_items.price > 1000
 )t1;
 
 -- Step3:
 -- The cities where there are sellers that sell those products

  SELECT DISTINCT cty
 FROM (
	SELECT  geo.city AS cty, products.product_weight_g AS weight,product_category_name_english, products.product_id, orders.order_id,order_item_id,  price, order_status, payment_type, order_purchase_timestamp
	FROM product_category_name_translation AS pct
	INNER JOIN products ON pct.product_category_name = products.product_category_name
    INNER JOIN order_items ON products.product_id = order_items.product_id
    INNER JOIN orders ON order_items.order_id = orders.order_id
    INNER JOIN order_payments ON orders.order_id = order_payments.order_id
    INNER JOIN sellers ON order_items.seller_id = sellers.seller_id
    INNER JOIN geo ON sellers.seller_zip_code_prefix = geo.zip_code_prefix
	where product_category_name_english IN('health_beauty') 
    AND order_status IN('delivered') 
    AND payment_type IN('credit_card') 
    AND YEAR(order_purchase_timestamp) IN (2018)
    AND order_items.price > 1000
 )t1;


-- Step 4:
-- The cities where there are customers who bought products

  SELECT DISTINCT cty
 FROM (
	SELECT  geo.city AS cty, products.product_weight_g AS weight,product_category_name_english, products.product_id, orders.order_id,order_item_id,  price, order_status, payment_type, order_purchase_timestamp
	FROM product_category_name_translation AS pct
	INNER JOIN products ON pct.product_category_name = products.product_category_name
    INNER JOIN order_items ON products.product_id = order_items.product_id
    INNER JOIN orders ON order_items.order_id = orders.order_id
    INNER JOIN order_payments ON orders.order_id = order_payments.order_id
    INNER JOIN sellers ON order_items.seller_id = sellers.seller_id
    INNER JOIN geo ON sellers.seller_zip_code_prefix = geo.zip_code_prefix
    INNER JOIN customers ON geo.zip_code_prefix = customers.customer_zip_code_prefix
    
	WHERE product_category_name_english IN('health_beauty') 
    AND order_status IN('delivered') 
    AND payment_type IN('credit_card') 
    AND YEAR(order_purchase_timestamp) IN (2018)
    AND order_items.price > 1000
 )t1;

## or

select distinct cty
from (
select geo.city as cty  ,   orders.order_delivered_customer_date, orders.order_status ,order_items.price, order_payments.payment_type, product_category_name_translation.product_category_name_english from orders 
left join order_payments
on orders.order_id = order_payments.order_id
left join order_items
on orders.order_id = order_items.order_id 
left join products
on order_items.product_id = products.product_id
left join product_category_name_translation
on products.product_category_name = product_category_name_translation.product_category_name
left join customers
on orders.customer_id = customers.customer_id
left join geo
on customers.customer_zip_code_prefix = geo.zip_code_prefix
where product_category_name_translation.product_category_name_english = "health_beauty"
and orders.order_status = "delivered" and order_payments.payment_type = "credit_card" 
and order_items.price >1000
and YEAR(orders.order_delivered_customer_date) = 2018
) dd;









