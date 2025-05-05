use sakila;

DROP VIEW IF EXISTS Customer_Summary_Report;
DROP TABLE IF EXISTS total_amount_paid;

-- Step 1: Create a View with a non-reserved alias
CREATE VIEW Customer_Summary_Report AS
SELECT 
    c.customer_id, 
    first_name, 
    last_name, 
    email, 
    COUNT(DISTINCT rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, first_name, last_name, email;

-- Step 2: Create temporary table
CREATE TEMPORARY TABLE total_amount_paid AS
SELECT 
    csr.*, 
    SUM(p.amount) AS total_amount
FROM Customer_Summary_Report csr
JOIN payment p ON p.customer_id = csr.customer_id
GROUP BY csr.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report
WITH CTE_NAME_customer AS (
    SELECT 
        csr.customer_id,
        csr.first_name,
        csr.last_name,
        csr.email,
        csr.rental_count AS rental_count,
        t.total_amount AS total_paid
    FROM Customer_Summary_Report csr
    JOIN total_amount_paid t
      ON csr.customer_id = t.customer_id
)
SELECT 
	CONCAT(first_name,last_name) AS customer_name,
    email,
    rental_count,
    total_paid,
    (total_paid / NULLIF(rental_count, 0)) AS average_payment_per_rental
FROM CTE_NAME_customer;







