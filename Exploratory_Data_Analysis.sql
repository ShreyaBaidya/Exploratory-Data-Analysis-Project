-- We are going to do exploratory data analysis on the cleaned data from world_layoffs
-- we are going to find trends and patterns
-- and writing complex queries

-- EXPLORATORY DATA ANALYSIS

SELECT * FROM world_layoffs.layoffs_staging2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging2;



-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1;
-- these are mostly startups it looks like who all went out of business during this time

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, raised like 2 billion dollars but went out of business


-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC;

-- Companies with the most Total Layoffs

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(date), MAX(date)
FROM world_layoffs.layoffs_staging2;

-- by industry
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- by Country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- by year
SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;

-- by stage
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;



-- Rolling Total of Layoffs Per Month

SELECT SUBSTRING(date,1,7) AS dates , SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY dates
ORDER BY 1 ASC;

-- now use it in a CTE so we can query off of it

WITH Rolling_Total AS 
(
SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) AS Total_Laid_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY dates
ORDER BY 1 ASC
)
SELECT 
	dates, 
	Total_Laid_off, 
    SUM(Total_Laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM Rolling_Total
ORDER BY dates ASC;


-- Earlier we looked at Companies with the most Layoffs. 
-- Now let's look at that per year.

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS Total_Laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT 
	company, 
    years, 
    Total_Laid_off, 
    DENSE_RANK() OVER (PARTITION BY years ORDER BY Total_Laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, Total_Laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, Total_Laid_off DESC;



-- Industries with the most Layoffs per year

WITH industry_Year AS 
(
  SELECT industry, YEAR(date) AS years, SUM(total_laid_off) AS Total_Laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY industry, YEAR(date)
)
, industry_Year_Rank AS (
  SELECT 
	industry, 
    years, 
    Total_Laid_off, 
    DENSE_RANK() OVER (PARTITION BY years ORDER BY Total_Laid_off DESC) AS ranking
  FROM industry_Year
)
SELECT industry, years, Total_Laid_off, ranking
FROM industry_Year_Rank
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, Total_Laid_off DESC;



-- Industries with the most Layoffs per month

WITH industry_month AS 
(
  SELECT industry, SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) AS Total_Laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY industry, dates
)
, industry_month_Rank AS (
  SELECT 
	industry, 
    dates, 
    Total_Laid_off, 
    DENSE_RANK() OVER (PARTITION BY dates ORDER BY Total_Laid_off DESC) AS ranking
  FROM industry_month
)
SELECT industry, dates, Total_Laid_off, ranking
FROM industry_month_Rank
WHERE ranking <= 5
AND dates IS NOT NULL
AND Total_Laid_off IS NOT NULL
ORDER BY dates ASC, Total_Laid_off DESC;