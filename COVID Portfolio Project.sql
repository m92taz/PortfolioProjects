/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (Egypt)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%ypt'
AND continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ypt'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ypt'
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC


-- Looking at Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ypt'
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ypt'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing contintents with the highest death count per population

SELECT continent, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ypt'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Cases,SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ypt'
WHERE continent is not null
-- group by date
ORDER BY 1,2




-- Looking at Total Population vs Vaccinations
-- Show Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- USING CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/Population) * 100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/Population) * 100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
