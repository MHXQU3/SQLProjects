-- Beginner Queries

-- 1. Select all employees from the employees table.
SELECT * FROM employees;

-- 2. Select the names of all regions.
SELECT region_name FROM regions;

-- 3. Count the total number of countries.
SELECT COUNT(*) AS total_countries FROM countries;

-- 4. Select employees who work in the 'Sales' department.
SELECT * FROM employees WHERE department_id IN (SELECT department_id FROM departments WHERE department_name = 'Sales');

-- 5. List the unique job titles from the jobs table.
SELECT DISTINCT job_title FROM jobs;

-- 6. Find all locations in the city of 'London'.
SELECT * FROM locations WHERE city = 'London';

-- 7. Get the maximum salary offered for jobs.
SELECT MAX(max_salary) AS highest_salary FROM jobs;

-- 8. Retrieve employees with salaries greater than $50,000.
SELECT * FROM employees WHERE salary > 50000;

-- 9. Get the number of employees in each department.
SELECT department_id, COUNT(*) AS employee_count FROM employees GROUP BY department_id;

-- 10. Retrieve all employees ordered by last name.
SELECT * FROM employees ORDER BY last_name;

-- Intermediate Queries

-- 11. Find the average salary of employees in each job title.
SELECT job_id, AVG(salary) AS average_salary FROM employees GROUP BY job_id;

-- 12. List all employees and their corresponding department names.
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- 13. Get the number of locations per country.
SELECT country_id, COUNT(*) AS location_count FROM locations GROUP BY country_id;

-- 14. Find employees who have the same job title as 'John Doe'.
SELECT * FROM employees WHERE job_id IN (
    SELECT job_id FROM employees WHERE first_name = 'John' AND last_name = 'Doe'
);

-- 15. Retrieve departments with more than 5 employees.
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id
HAVING COUNT(e.employee_id) > 5;

-- 16. Get the highest salary for each department.
SELECT d.department_id, MAX(e.salary) AS highest_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id;

-- 17. List the employees who have not been assigned to any department.
SELECT * FROM employees WHERE department_id IS NULL;

-- 18. Find regions that have countries with more than 10 locations.
SELECT r.region_name
FROM regions r
JOIN countries c ON r.region_id = c.region_id
JOIN locations l ON c.country_id = l.country_id
GROUP BY r.region_name
HAVING COUNT(l.location_id) > 10;

-- 19. Retrieve the total salary expense of each department.
SELECT d.department_name, SUM(e.salary) AS total_salary_expense
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- 20. Find the employees who earn more than the average salary.
SELECT * FROM employees WHERE salary > (SELECT AVG(salary) FROM employees);

-- Advanced Queries

-- 21. Retrieve the top 5 highest-paid employees.
SELECT * FROM employees ORDER BY salary DESC LIMIT 5;

-- 22. Get the number of employees hired each year.
SELECT EXTRACT(YEAR FROM hire_date) AS hire_year, COUNT(*) AS employee_count
FROM employees
GROUP BY hire_year
ORDER BY hire_year;

-- 23. Find the job title that has the highest minimum salary.
SELECT job_title FROM jobs WHERE min_salary = (SELECT MAX(min_salary) FROM jobs);

-- 24. Get the total number of employees in each region.
SELECT r.region_name, COUNT(e.employee_id) AS employee_count
FROM regions r
JOIN countries c ON r.region_id = c.region_id
JOIN locations l ON c.country_id = l.country_id
JOIN departments d ON l.location_id = d.location_id
JOIN employees e ON d.department_id = e.department_id
GROUP BY r.region_name;

-- 25. List employees and their corresponding location details.
SELECT e.first_name, e.last_name, l.city, l.country_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id;

-- 26. Find the regions with no countries.
SELECT r.region_name
FROM regions r
LEFT JOIN countries c ON r.region_id = c.region_id
WHERE c.country_id IS NULL;

-- 27. Retrieve the average salary by job title and order by average salary.
SELECT j.job_title, AVG(e.salary) AS average_salary
FROM jobs j
JOIN employees e ON j.job_id = e.job_id
GROUP BY j.job_title
ORDER BY average_salary DESC;

-- 28. Get the number of employees hired in each department.
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- 29. Find the country with the highest number of employees.
SELECT c.country_name, COUNT(e.employee_id) AS employee_count
FROM countries c
LEFT JOIN locations l ON c.country_id = l.country_id
LEFT JOIN departments d ON l.location_id = d.location_id
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY c.country_name
ORDER BY employee_count DESC LIMIT 1;

-- 30. Retrieve the average salary for employees in regions that have at least 2 departments.
SELECT r.region_name, AVG(e.salary) AS average_salary
FROM regions r
JOIN countries c ON r.region_id = c.region_id
JOIN locations l ON c.country_id = l.country_id
JOIN departments d ON l.location_id = d.location_id
JOIN employees e ON d.department_id = e.department_id
GROUP BY r.region_name
HAVING COUNT(DISTINCT d.department_id) >= 2;
