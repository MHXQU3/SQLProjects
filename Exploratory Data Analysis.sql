-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2; 

SELECT MAX(total_laid_off)
FROM layoffs_staging2; -- returns 12000

SELECT *
FROM layoffs_staging2
WHERE total_laid_off = 12000; -- checking which company this is 

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; 

SELECT industry, COUNT(*) AS Number
FROM layoffs_staging2
GROUP BY industry; -- checking to see how many companies per industry

SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC; -- order by 2 desc also does the same as its the second column 

SELECT MIN(`DATE`), MAX(`DATE`)
FROM layoffs_staging2; -- check the earliest and latest layoffs

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC; -- total layoffs per industry

SELECT industry, ROUND(AVG(percentage_laid_off),2) as average_pct
FROM layoffs_staging2
GROUP BY industry
ORDER BY average_pct DESC; -- average percentage layoffs per industry

SELECT country, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY country
ORDER BY total DESC; -- total layoffs per  country

SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY year
ORDER BY total DESC; -- total layoffs per year

SELECT stage, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY stage
ORDER BY total DESC; -- total layoffs per stage 

SELECT DISTINCT SUBSTRING(`date`, 6,2) AS month
FROM layoffs_staging2
ORDER BY month; -- extracts the month portion from the date, starts from the 6th, and is 2 digits long

SELECT SUBSTRING(`date`, 1,7) AS month, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL -- have to incude column not alias
GROUP BY month
ORDER BY month ASC; -- showcase of total amount of layoffs through the months and years in chron order

SELECT *
FROM layoffs_staging2;

WITH Running_Total AS 
(
SELECT SUBSTRING(`date`, 1,7) AS month, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY month
ORDER BY month ASC
)
SELECT month, total, SUM(total) OVER(ORDER BY month) AS running_total
FROM Running_Total; 
-- over function with the sum function creates this running total
-- over specifies that it should calculate the sum of the totals by ordering the rows according to the month col
-- over tells sql to calculate a cumulative sum for each row up to and including that row by the month col
-- this is essentially a cumulative frequency table 

SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, year
ORDER BY total_layoffs DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, year
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS rank_col
FROM Company_Year
WHERE years IS NOT NULL AND DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) <= 5
ORDER BY rank_col ASC;
-- dense rank assigns a rank to each row within the partition of the dataset, 
-- rows with equal values in the ranking criteria recieve the same rank, with no gaps in the ranking sequence
-- partition by year divides the results set into partitions based on the year column
-- -- -- each partition has its own ranking sequence
-- order by total layoffs ranks the rows within each partition by that in desc order
-- -- -- highest total layoffs gets the rank of 1
-- simply put, divides results into year divisions and ranks each results per year based on total layoffs with highest getting a 1 due to the DESC factor

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, year
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS rank_col
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE rank_col <= 5;
-- a new cte has to be created as you can't use an alias in the where clause
-- neither can you use the dense rank function within the where clause
-- so we set it as its own table and then called its column alias in this where clause 