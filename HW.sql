--1

SELECT *
FROM payment;

SELECT *
FROM rental
WHERE rental_duration IS NULL;

UPDATE rental
SET rental_duration = return_date - rental_date;


CREATE OR REPLACE PROCEDURE lateFee()
	LANGUAGE plpgsql
	AS $$
	BEGIN
		UPDATE payment
		SET amount = amount + 5
		WHERE customer_id IN(
			SELECT customer_id
			FROM rental
			WHERE rental_duration > '7 days');
		COMMIT;
	END;$$

Call lateFee()
	
--2

SELECT *
FROM payment

SELECT *
FROM customer

ALTER TABLE customer
ADD COLUMN platinum_member BOOLEAN;

CREATE OR REPLACE PROCEDURE is_prem_mem()
	LANGUAGE plpgsql
	AS $$
	BEGIN
		UPDATE customer SET platinum_member = true
			WHERE customer_id IN(
				SELECT customer_id
				FROM payment
				GROUP BY customer_id
				HAVING sum(amount)> 200) or customer_id = 10;
			
		UPDATE customer SET platinum_member = false
			WHERE customer_id NOT IN(
				SELECT customer_id
				FROM payment
				GROUP BY customer_id
				HAVING sum(amount)> 200);
				COMMIT;
		END;$$
CALL is_prem_mem();
	
SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id
ORDER BY sum(amount) DESC;