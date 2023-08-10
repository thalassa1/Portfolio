-- exploring the data
SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM CovidDeaths
ORDER BY 1, 2;

--Calculating death percentage 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  AS death_percentage
FROM CovidDeaths
WHERE location = 'Ireland'
ORDER BY 1, 2 DESC;

-- changing data type to accomodate with future calculations
ALTER TABLE CovidDeaths
ALTER COLUMN population float;

-- looking at total cases VS population
SELECT location, date, total_cases, population, (total_cases/population)*100  AS infection_rate
FROM CovidDeaths
ORDER BY 1, 2 DESC;

--looking at countries with highest infection rate compared to population according to the latest data
SELECT top 10 location, MAX(total_cases) AS highest_total_cases, population, (MAX(total_cases)/population)*100  AS infection_rate
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

-- infection rate by continent
SELECT location, MAX(total_cases) AS highest_total_cases, population, (MAX(total_cases)/population)*100  AS infection_rate
FROM CovidDeaths
WHERE continent is null AND location NOT LIKE '%income' AND location NOT IN ('European Union', 'World')
GROUP BY location, population
ORDER BY 4 DESC;


--showing countries with highest death count by population
SELECT location, MAX(total_deaths) AS highest_total_deaths, population, (MAX(total_deaths)/population)*100  AS death_rate
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

--showing continents with highest death count by population
SELECT location, MAX(total_deaths) AS highest_total_deaths, population, (MAX(total_deaths)/population)*100  AS deaths_rate
FROM CovidDeaths
WHERE continent is null AND location NOT LIKE '%income' AND location NOT IN ('European Union', 'World')
GROUP BY location, population
ORDER BY 4 DESC;

-- global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/(SUM(new_cases)+0.01))*100 AS death_rate
FROM CovidDeaths
GROUP BY date
ORDER BY 1 DESC;

--joining two tables
SELECT *
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date;

-- looking at total population vs vaccination
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY v.location ORDER BY v.date) AS rolling_people_vaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date
ORDER BY 1, 2 ;


--creatng CTE
WITH PopVsVac (location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY v.location ORDER BY v.date) AS rolling_people_vaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date
)
SELECT *, (rolling_people_vaccinated/population)*100 AS percent_vaccinated
FROM PopVsVac;

-- temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric);

INSERT INTO #PercentPopulationVaccinated
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY v.location ORDER BY v.date) AS rolling_people_vaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date;

SELECT *, (rolling_people_vaccinated/population)*100 AS percent_vaccinated
FROM #PercentPopulationVaccinated;

-- creating view
CREATE VIEW ContinentDeathRate 
AS
SELECT location, MAX(total_deaths) AS highest_total_deaths, population, (MAX(total_deaths)/population)*100  AS deaths_rate
FROM CovidDeaths
WHERE continent is null AND location NOT LIKE '%income' AND location NOT IN ('European Union', 'World')
GROUP BY location, population;

SELECT * FROM ContinentDeathRate;