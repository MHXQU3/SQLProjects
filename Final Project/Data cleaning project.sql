-- Data Cleaning

SELECT *
FROM layoffs;

-- 1st Step: Remove Duplicates
-- 2nd Step: Standardize Data
-- 3rd Step: Remove NULLs 
-- 4th Step: Remove Any Columns

-- Staging table created so raw data still present 

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Removing Duplicates
-- hard to do dupes without row id

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- creating a CTE
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1;

-- had to delete my rows as i had entered dupes
TRUNCATE TABLE layoffs_staging;

-- need to create another table to delete values from on MySQL


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1
LIMIT 5; -- needed to bypass some dodgy mysql warning

SELECT *
FROM layoffs_staging2; -- Check to see if the rows were deleted

-- Standardizing data

SELECT company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company); -- trim removes the leading and removing white spaces

SELECT INDUSTRY
FROM layoffs_staging2
WHERE industry LIKE ('%crypto%')
ORDER BY industry; -- crypto has 3 varying entries (Crypto, Crypto Currency, CryptoCurrency

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%crypto%'; -- Sets every ind. that contains crypto to Crypto

SELECT DISTINCT INDUSTRY
FROM layoffs_staging2;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE '%States%'
ORDER BY 1; -- First column -- florianapolis, malma


UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE '%States%'; -- Did this myself but the better version is down below

-- Alex' Better version -----------------------------------------
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE ('United States%');
-- End Alex' Better version -----------------------------------------

SELECT *
FROM layoffs_staging2;

-- Changing date format
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y') -- Y in caps as that is the 4 digit long yr
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2; -- will still show as a text col, but now you can change to a date col

ALTER TABLE layoffs_staging2 -- only do this on a staging table 
MODIFY COLUMN `date` DATE; -- changed dtype to DATE

-- end of change date format

-- Working with the nulls

UPDATE layoffs_staging2
SET industry = null
WHERE industry = ''; -- Done to change all the blanks into nulls for easier conversion

-- GETTING RID OF INDUSTRY NULLS -------------------------------
SELECT *
FROM layoffs_staging2
WHERE industry = '' OR industry IS NULL;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'; -- after completing 180-185, this was the only blank remaining
-- this did not have any second row, so did not do any second rows, so nothing to set it to

UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE company = 'Airbnb' ; -- Sooooo not the way Alex did it

SELECT t1.industry, t2.industry -- this query is just for a check to see if there are entries where the industry is populated
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company -- if the company matches
    AND t1.location = t2.location -- and the location matches (could be an airbnb in SF and Africa??
WHERE (t1.industry IS NULL OR t1.industry = '' )-- only joins if industry is null or blank for t1
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company -- joins the identical tables
SET t1.industry = t2.industry -- sets t1 values to = t2 values
WHERE (t1.industry IS NULL OR t1.industry = '') -- as long as t1 values are null or blank
AND t2.industry IS NOT NULL; -- and t2 has some values in it

SELECT * 
FROM layoffs_staging2;

-- DATA CLEANING COMPLETE -------------------------------------

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; -- can't do anything with this data as very limited useful info

DELETE -- ONLY DELETE DATA IF YOU'RE CONFIDENT YOU WON'T NEED IT 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;  -- Getting rid of those entries where both these columns are NULL

-- REMOVING UNNECESSARY COLUMNS
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;




