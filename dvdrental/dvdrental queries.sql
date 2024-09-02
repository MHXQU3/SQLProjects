-- 1. List all actors with their first and last names.
SELECT first_name, last_name FROM actor
ORDER BY first_name;

-- 2. Retrieve the titles of all films in the inventory.
SELECT DISTINCT(f.title) FROM film f
JOIN inventory i
ON f.film_id = i.film_id
ORDER BY title;

-- 3. Find the name and email of all customers.
SELECT CONCAT(first_name,' ', last_name) AS name, email FROM customer;

-- 4. List all the cities available in the `City` table.
SELECT city FROM city;

-- 5. Show the first and last names of the staff members.
SELECT CONCAT(first_name,' ', last_name) AS name, email FROM staff;

-- 6. Retrieve all films released in the year 2006.
SELECT title, release_year FROM film
WHERE release_year = 2006;

-- 7. Find all customers who are currently active.
SELECT CONCAT(first_name,' ', last_name) AS name, activebool AS active FROM customer
WHERE activebool = TRUE;

-- 8. List the distinct film categories from the `Category` table.
SELECT DISTINCT(name) FROM category
ORDER BY name ASC;

-- 9. Retrieve the name of the country where the city "Mannheim" is located.
SELECT ci.city, co.country FROM city ci
JOIN country co
ON ci.country_id = co.country_id
WHERE city = 'Mannheim';

-- 10. Show all films with an MPAA rating of "PG-13".
SELECT title FROM film
WHERE rating = 'PG-13';


-- INTERMEDIATE DIFFICULTY
-- 11. Find all films and their corresponding rental rates.
SELECT title, rental_rate FROM film;

-- 12. Show the first and last names of actors who have appeared in the film titled "Panic Club".
SELECT CONCAT(a.first_name, ' ', a.last_name) AS name, f.title FROM film f
JOIN film_actor fa
ON fa.film_id = f.film_id
JOIN actor a
ON fa.actor_id = a.actor_id
WHERE title = 'Panic Club';

-- 13. List the first and last names of customers who rented a film in February 2006.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS name, r.rental_date FROM rental r
JOIN customer c
ON r.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM rental_date) = 2006 AND EXTRACT(MONTH FROM rental_date) = 02;

-- 14. Display the total number of films available in each store.
SELECT s.store_id, COUNT(i.film_id) as films_stored FROM store s
JOIN inventory i
ON s.store_id = i.store_id
GROUP BY s.store_id
ORDER BY films_stored DESC;

-- 15. Retrieve the films that are in the category "Action".
SELECT f.title FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
WHERE c.name = 'Action';

-- 16. Show the email addresses of customers who rented a film from staff ID 2.
SELECT c.email, r.staff_id FROM rental r
JOIN customer c
ON r.staff_id = c.store_id
WHERE r.staff_id = 2 AND c.customer_id IN (SELECT r.customer_id FROM rental r);

-- 17. List all staff members and the stores they work in, along with the city and country of the store.
-- Nothing that links stores and city -------

-- 18. Find the films that have a rental rate greater than $3.
SELECT title, rental_rate FROM film
WHERE rental_rate > 3;

-- 19. Retrieve the title of the most expensive film replacement cost.
SELECT title, replacement_cost FROM film
ORDER BY replacement_cost DESC
LIMIT 1;
-- 20. Show the number of films in each category.
SELECT c.name, COUNT(f.title) FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY c.name;



--ADVANCED DIFFICULTY
-- 21. Retrieve the total number of rentals for each customer along with their names.
SELECT CONCAT(c.first_name,' ', c.last_name) AS name, COUNT(r.rental_id) FROM customer c
JOIN rental r
ON r.customer_id = c.customer_id
GROUP BY name;

-- 22. Find the top 3 customers who have spent the most money on rentals.
with sum_costs AS(
	SELECT customer_id, SUM(amount) AS total FROM payment
	GROUP BY customer_id)
SELECT CONCAT(c.first_name,' ', c.last_name) AS name, sc.total FROM customer c
JOIN sum_costs sc
ON sc.customer_id = c.customer_id
ORDER BY total DESC
LIMIT 3;

-- 23. Calculate the average rental rate for films in each category.
SELECT c.name, ROUND(AVG(f.rental_rate), 2) AS avg_rate FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
GROUP BY name
ORDER BY avg_rate DESC;

-- 24. Find the last 7 rentals along with the customer who rented them and the store where they were rented.
SELECT CONCAT(c.first_name,' ', c.last_name) AS name, f.title, DATE(r.rental_date), i.store_id FROM rental r
JOIN inventory i
ON i.inventory_id = r.inventory_id
JOIN customer c
ON r.customer_id = c.customer_id
JOIN film f
ON i.film_id = f.film_id
ORDER BY r.rental_date DESC
LIMIT 7;

-- 25. Retrieve the total payment amount received by each staff member.
SELECT staff_id, SUM(amount) AS total FROM payment
GROUP BY staff_id
ORDER BY total DESC;

-- 26. Find all actors who appeared in more than 25 films.
with count_25 AS(
	SELECT actor_id, COUNT(film_id) AS film_count FROM film_actor
	GROUP BY actor_id
	HAVING COUNT(film_id) > 25
	ORDER BY actor_id)

SELECT CONCAT(a.first_name,' ', a.last_name) AS name, c.film_count FROM actor a
JOIN count_25 c
ON a.actor_id = c.actor_id
ORDER BY film_count DESC;

-- 27. List the films that were rented only once.
SELECT inventory_id, COUNT(rental_id) AS count FROM rental
GROUP BY inventory_id
HAVING COUNT(rental_id) = 1
ORDER BY count; 

-- 28. Retrieve the number of films rented by each customer and the total amount they paid.
SELECT CONCAT(c.first_name,' ', c.last_name) AS name, COUNT(p.rental_id), SUM(p.amount) FROM payment p
JOIN customer c
ON c.customer_id = p.customer_id
GROUP BY name;

-- 29. Find the most rented film and the total number of rentals for that film.
SELECT f.title, COUNT(r.rental_id) AS rentals FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY rentals DESC
LIMIT 1;

-- 30. Retrieve the titles of films rented by customers in "London", along with the date of rental and the staff member who handled the transaction.
SELECT f.title, r.rental_date, r.staff_id FROM rental r
JOIN inventory i
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id
JOIN customer c
ON r.customer_id = c.customer_id
JOIN address a 
ON c.address_id = a.address_id
JOIN city ci
ON a.city_id = ci.city_id
WHERE ci.city = 'London'