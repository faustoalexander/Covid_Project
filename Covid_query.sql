
SELECT *
FROM PortafolioProject..CovidDeath$
WHERE continent is not NULL
ORDER BY 3, 4

--SELECT *
--FROM PortafolioProject..CovidVaccinations$
--WHERE continent is not NULL
--ORDER BY 3, 4

--select the data we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject..CovidDeath$
WHERE continent is not NULL
ORDER BY 1, 2;

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contrast covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM PortafolioProject..CovidDeath$
WHERE location like '%dominican%'
and continent is not NULL
ORDER BY 1, 2

--Looking of total cases vs Population in your country
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentpopulation_infected
FROM PortafolioProject..CovidDeath$
WHERE location like '%dominican%'
and continent is not NULL
ORDER BY 1, 2

--Country with Highest infections rate compared to population
SELECT location, population, MAX(total_cases) AS Highestinfections_count, MAX((total_cases/population))*100 AS percentpopulation_infected
FROM PortafolioProject..CovidDeath$
--WHERE location like '%dominican%'
WHERE continent is not NULL
GROUP BY Location, Population
ORDER BY percentpopulation_infected DESC

--showing countries with highest death per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Totaldeath_count 
FROM PortafolioProject..CovidDeath$
--WHERE location like '%dominican%'
WHERE continent is not NULL
GROUP BY Location
ORDER BY Totaldeath_count DESC

--BREAK DOWN BY CONTINENT
--Showing continents with highest death

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Totaldeath_count 
FROM PortafolioProject..CovidDeath$
WHERE continent is not NULL
GROUP BY continent
ORDER BY Totaldeath_count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathpercentage
FROM PortafolioProject..CovidDeath$
--WHERE location like '%dominican%'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1, 2

--total cases and deaths

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathpercentage
FROM PortafolioProject..CovidDeath$
--WHERE location like '%dominican%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1, 2

--Looking at total population vs total vaccinatetions

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.date) AS rollingpeoplevaccinated
FROM PortafolioProject..CovidDeath$ dea
JOIN PortafolioProject..CovidVaccinations$ vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--Use CTE

WITH Popuvsvacc (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) 
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.date)
	AS rollingpeoplevaccinated
FROM PortafolioProject..CovidDeath$ dea
JOIN PortafolioProject..CovidVaccinations$ vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM Popuvsvacc

--TEMP TABLE

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
	(
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinetions NUMERIC,
	rollingpeoplevaccinated NUMERIC
	)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.date)
	AS rollingpeoplevaccinated
FROM PortafolioProject..CovidDeath$ dea
JOIN PortafolioProject..CovidVaccinations$ vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #percent_population_vaccinated

--CREATING VIEW TO STORE DATA FOR LATER

CREATE VIEW percent_population_vaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.date)
	AS rollingpeoplevaccinated
FROM PortafolioProject..CovidDeath$ dea
JOIN PortafolioProject..CovidVaccinations$ vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT * 
FROM percent_population_vaccinated