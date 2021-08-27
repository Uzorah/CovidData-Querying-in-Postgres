SELECT *
FROM coviddeaThs
ORDER BY 3,4

--select data that I will be using
SELECT location, date, total_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2

--Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_deaths
FROM coviddeaths
ORDER BY 1,2

--Total cases vs total deaths in Nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_deaths
FROM coviddeaths
WHERE location = 'Nigeria'
ORDER BY 1,2

--percentage infection in Nigeria
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentage_infections
FROM coviddeaths
WHERE location = 'Nigeria'
ORDER BY 1,2

--percentage infection in the world
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentage_infections
FROM coviddeaths
ORDER BY 1,2

--Countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS HighestCase, 
	   MAX((total_cases/population))*100 AS Highest_infections
FROM coviddeaths
GROUP BY location, population
ORDER BY Highest_infections DESC NULLS last

--Countries with highest death rates per population
SELECT location, MAX(total_deaths) AS HighestDeath
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeath DESC NULLS last

--death rates by continent
SELECT continent, SUM(MaxDeath) AS TotalDeaths
FROM (SELECT continent, location, MAX(total_deaths) AS MaxDeath
	  FROM coviddeaths
	  GROUP BY continent, location
	  ORDER BY 1,2
	 ) AS MaxDeath_per_country
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

--another method, but with a few outliers
SELECT location, MAX(total_deaths) AS HighestDeath
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeath DESC NULLS last

--global numbers
SELECT 
	date, SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, 
	(SUM(new_deaths)/SUM(new_cases))*100 AS percentage_deaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

--vaccinations
SELECT *
FROM covidvaccinations
ORDER BY 3,4

--joining coviddeaths and vaccination tables
SELECT *
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
	
--total population vs vaccination (using CTE)
WITH popvsvac AS (
SELECT 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cd.location, cd.date) AS "Total vaccinated"
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3)

SELECT *, ("Total vaccinated"/population)*100 "% population vaccinated"
FROM popvsvac

--total population vs vaccination (using temp table)
CREATE TEMP TABLE popuvacci
	(continent character varying(255), 
	 location character varying(255), 
	 date date, 
	 population numeric, 
	 new_vaccinations numeric, 
	 totalvaccinated numeric
	)
INSERT INTO popuvacci
SELECT 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cd.location, cd.date) AS totalvaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (totalvaccinated/population)*100 "% population vaccinated"
FROM popuvacci

--Creating view for data to use for visualisation
--view for death rates per continent
CREATE VIEW continental_death_rates AS
SELECT continent, SUM(MaxDeath) AS TotalDeaths
FROM (SELECT continent, location, MAX(total_deaths) AS MaxDeath
	  FROM coviddeaths
	  GROUP BY continent, location
	  ORDER BY 1,2
	 ) AS MaxDeath_per_country
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC



	
	