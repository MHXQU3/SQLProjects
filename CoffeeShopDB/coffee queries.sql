-- 1. Retrieve all columns for all employees
SELECT * FROM employees;

-- 2. List the first and last names of all employees
SELECT first_name, last_name FROM employees;

-- 3. Find the emails of employees working in Coffeeshop 2.
SELECT email, coffeeshop_id FROM employees
WHERE coffeeshop_id = 2;

-- 4. Display the distinct coffee types available from suppliers.
SELECT DISTINCT(coffee_type) FROM suppliers;

-- 5. Count the number of employees in each coffeeshop.
SELECT COUNT(*), coffeeshop_id FROM employees
GROUP BY coffeeshop_id
ORDER BY coffeeshop_id; 

-- 6. Calculate the average salary of employees, grouped by gender.
SELECT ROUND(AVG(salary),2) AS avg_salary, gender FROM employees
GROUP BY gender
ORDER BY avg_salary DESC;

-- 7. List the names of suppliers that provide 'Robusta' coffee.
SELECT supplier_name, coffee_type FROM suppliers
WHERE coffee_type = 'Robusta';

-- 8. Find the employees hired after January 1, 2017.
SELECT first_name, last_name FROM employees
WHERE hire_date > '2017-01-01';

-- 9. Determine the total salary of employees in Coffeeshop 3.
SELECT SUM(salary) FROM employees
WHERE coffeeshop_id = 3;

-- 10. List all cities and countries where coffee shops are located.
SELECT * FROM locations;

-- 11. Find the number of unique suppliers providing coffee to Coffeeshop 4.
SELECT DISTINCT(supplier_name) FROM suppliers
WHERE coffeeshop_id = 4;

-- 12. Identify the top three highest-paid employees.
SELECT first_name, last_name, salary FROM employees
ORDER BY salary DESC
LIMIT 3;

-- 13. Find the coffeeshops that have more than 200 employees.
SELECT coffeeshop_id, COUNT(employee_id) FROM employees
GROUP BY coffeeshop_id
HAVING COUNT(employee_id) > 200;

-- 14. List the employee names along with their corresponding coffeeshop names.
SELECT first_name, last_name, coffeeshop_name FROM employees
INNER JOIN shops 
ON shops.coffeeshop_id = employees.coffeeshop_id;

-- 15. Determine which country has the most coffee shops.
SELECT COUNT(coffeeshop_id) AS count, country FROM shops
INNER JOIN locations
ON locations.city_id = shops.city_id
GROUP BY country
ORDER BY COUNT DESC;

-- 16. Identify employees whose salary is above the average salary of all employees.
with avg_cte as
	(SELECT AVG(salary) AS avg_salary FROM employees)
SELECT employees.first_name, employees.last_name, employees.salary FROM employees
JOIN avg_cte ON employees.salary > avg_cte.avg_salary;

-- 17. Find employees who share the same last name.
SELECT last_name, STRING_AGG(first_name, ', ') AS first_names FROM employees
GROUP BY last_name  -- always use string agg when splitting a group into many
HAVING COUNT(last_name) >= 2;
-- OR USING A CTE------
WITH last_name_counts AS (
    SELECT last_name, STRING_AGG(first_name, ', ') AS first_names, COUNT(*) AS name_count
    FROM employees
    GROUP BY last_name
)
SELECT last_name, first_names
FROM last_name_counts
WHERE name_count >= 2;

-- 18. Retrieve the supplier names and the number of types of coffee they supply.
SELECT supplier_name, COUNT(coffee_type) FROM suppliers
GROUP BY supplier_name;

-- 19. List the locations where 'Arabica' coffee is supplied.
with shop_suppliers AS (
	SELECT coffee_type, su.coffeeshop_id, sh.city_id FROM suppliers su
	JOIN shops sh
	ON su.coffeeshop_id = sh.coffeeshop_id)
SELECT coffee_type, city FROM shop_suppliers
JOIN locations
ON shop_suppliers.city_id = locations.city_id
WHERE coffee_type = 'Arabica';

-- 20. Find the gender ratio of employees in Coffeeshop 5.
SELECT 
    MaleCount.Total AS MaleCount,
    FemaleCount.Total AS FemaleCount,
    ROUND(((MaleCount.Total * 1.0) / FemaleCount.Total),3) AS MaleToFemaleRatio
FROM 
    (SELECT COUNT(*) AS Total FROM employees WHERE Gender = 'M') AS MaleCount,
    (SELECT COUNT(*) AS Total FROM employees WHERE Gender = 'F') AS FemaleCount;

-- 21. Display the first and last names of employees who work at the same coffeeshop as 'Katharine Sexcey'
with saxey_id AS(
	SELECT first_name, last_name, coffeeshop_id FROM employees
	WHERE first_name LIKE 'Katharine' AND last_name LIKE 'Sexcey')
SELECT e.first_name, e.last_name, e.coffeeshop_id FROM employees e
INNER JOIN saxey_id s
ON e.coffeeshop_id = s.coffeeshop_id;

-- 22. List employees who have been with the company for more than 5 years to the start of 2024.
SELECT first_name, last_name, hire_date FROM employees
WHERE hire_date <= '2024-01-01'::date - INTERVAL '5 years' -- Typecasting to date
ORDER BY hire_date DESC;

-- 23. Find the coffeeshop that has the most diverse coffee types supplied.
SELECT coffeeshop_name, COUNT(coffee_type) AS count FROM shops sh
JOIN suppliers su
ON sh.coffeeshop_id = su.coffeeshop_id
GROUP BY sh.coffeeshop_name
ORDER BY count DESC
LIMIT 1;

-- 24. Display the name of the coffee shop and its corresponding city where the maximum employee salary is highest.
with max_sal AS(
	SELECT MAX(salary) as max FROM employees),
id_sal AS(
	SELECT coffeeshop_id, salary FROM employees e
	INNER JOIN max_sal m
	ON e.salary = m.max),
shop_sal AS(
	SELECT coffeeshop_name, city_id, salary FROM shops s
	INNER JOIN id_sal i
	ON s.coffeeshop_id = i.coffeeshop_id)
SELECT city, coffeeshop_name, salary FROM locations l
INNER JOIN shop_sal s
ON s.city_id = l.city_id;

-- 25. Determine the total number of employees hired in each year.
with yearly_hires AS(
	SELECT EXTRACT(YEAR FROM hire_date) AS year, employee_id FROM employees)
SELECT year, COUNT(employee_id) AS hires FROM yearly_hires
GROUP BY year
ORDER BY year;

-- 26. List the employees who are earning the maximum salary for their coffeeshop.
SELECT DISTINCT ON(coffeeshop_id) coffeeshop_id, first_name, last_name, salary
FROM employees
ORDER BY coffeeshop_id, salary
DESC; -- DISTINCT ON keeps one row per the col name in brackets

-- 27. Identify the coffeeshop that has the highest total salary for its employees.
SELECT s.coffeeshop_name, SUM(e.salary) AS total_salary FROM employees e
JOIN shops s
ON e.coffeeshop_id = s.coffeeshop_id
GROUP BY coffeeshop_name
ORDER BY total_salary DESC
LIMIT 1;
-- 28. Retrieve the first and last names of employees who have worked at multiple coffeeshops (assuming they moved between shops, and this history is tracked in another table)
SELECT first_name, last_name FROM employees
GROUP BY first_name, last_name
HAVING COUNT(*) >= 1;

-- 29. Find all cities where 'Liberica' coffee is available and the total number of employees in those cities.
with liberica_cities AS (
	SELECT su.coffee_type, l.city, su.coffeeshop_id FROM suppliers su
	JOIN shops sh
	ON su.coffeeshop_id = sh.coffeeshop_id
	JOIN locations l
	ON sh.city_id = l.city_id
	WHERE coffee_type = 'Liberica'
)
SELECT lc.city, COUNT(e.employee_id) FROM employees e
JOIN liberica_cities lc
ON e.coffeeshop_id = lc.coffeeshop_id
GROUP BY e.coffeeshop_id, lc.city;

-- 30. Identify the supplier who provides coffee to the most number of unique cities.
SELECT su.supplier_name, COUNT(sh.city_id) AS supplied_to FROM suppliers su
JOIN shops sh
ON sh.coffeeshop_id = su.coffeeshop_id
JOIN locations l
ON l.city_id = sh.city_id
GROUP BY su.supplier_name
ORDER BY supplied_to DESC;

-- 12,21,24,28,30 may require CTEs

