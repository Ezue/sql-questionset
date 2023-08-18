/*We want to understand more about the movies that families are watching. The following categories are 
considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.*/

SELECT f.title name,
	   c.name category,
	   COUNT(rental_id)
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1,2
ORDER BY 2;

/*Question 2
Now we need to know how the length of rental duration of these family-friendly movies 
compares to the duration that all movies are rented for. Can you provide a table with 
the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter)
based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories? Make sure to also 
indicate the category that these family-friendly movies fall into.*/


SELECT name,
	   category,
	   duration,
	   NTILE(4) OVER (ORDER BY duration) AS standard_quantile
FROM (
		SELECT f.title name,
			   c.name category,
			   f.rental_duration duration,
			   NTILE(4) OVER (ORDER BY f.rental_duration) AS quantile
		FROM category c
		JOIN film_category fc
		ON c.category_id = fc.category_id
		JOIN film f
		ON fc.film_id = f.film_id
		WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
		ORDER BY 2
	)t1
JOIN film f
ON f.title = t1.name;

/*Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, and the 
corresponding count of movies within each combination of film category for each corresponding 
rental duration category.
The resulting table should have three columns:
Category
Rental length category
Count */


SELECT  category,
  		standard_quartiles,
  		COUNT(category)
FROM (
		SELECT c.name category,
		       NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartiles
		FROM film f
		JOIN film_category fc
		ON f.film_id = fc.film_id
		JOIN category c
		ON c.category_id = fc.category_id
		WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
	 ) t1
GROUP BY 1,2
ORDER BY 1,2;

/*Question Set 2*/
/*Question 1:
We want to find out how the two stores compare in their count of rental orders during every 
month for all the years we have data for. ** Write a query that returns the store ID for the store, the year 
and month and the number of rental orders each store has fulfilled for that month. Your table should include a column 
for each of the following: year, month, store ID and count of rental orders fulfilled during that month. */

SELECT DATE_PART('month', rental_date) AS rental_month,
	   DATE_PART('year', rental_date) AS rental_year,
	   st.store_id,
	   COUNT(r.customer_id) as rental_orders
FROM rental r
JOIN staff s
ON r.staff_id = s.staff_id
JOIN store st
ON st.store_id = s.store_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

/* Question 2
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and 
what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, 
and total payment amount for each month by these top 10 paying customers? */
			
SELECT CONCAT(first_name, ' ', last_name) AS full_name,
   DATE_TRUNC('month', p.payment_date) payment_date,
   COUNT(p.amount) per_countpermon
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE CONCAT(first_name, ' ', last_name) IN
			(
		     SELECT full_name
		 	 FROM (
				    SELECT  CONCAT(first_name, ' ', last_name) AS full_name, 
				            SUM(p.amount) as amount_total
					FROM customer c
					JOIN payment p
					ON p.customer_id = c.customer_id
					GROUP BY 1	
					ORDER BY 2 DESC
					LIMIT 10) t1
			) AND (p.payment_date BETWEEN '2007-01-01' AND '2008-01-01')
GROUP BY 1,2
ORDER BY 1,2


/*Question 3
Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly 
payments during 2007. Please go ahead and ** write a query to compare the payment amounts in each successive month.
** Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the 
customer name who paid the most difference in terms of payments.*/


















