--Viewing the entire table

SELECT * FROM "COVID_Deaths"
WHERE continent IS NOT null -- This is to get rid of location being a continent
order by 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM "COVID_Deaths"
WHERE continent IS NOT NULL
ORDER BY 1,2 ; -- Ordering by Location and Date.

-- Comparing the Amount of deaths per total cases
-- Shows the probability of dying if you get COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM "COVID_Deaths"
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2 ; 

-- Comparing the total cases vs population
-- Shows the percentage of population that has COVID.
SELECT location, date, population total_cases, (total_cases/population)* 100 as PopInfectedPercentage
FROM "COVID_Deaths"
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2 ; 

-- Looking at the countries that have the highest rate of infection w.r.t population
-- USED FOR SHEET 4 in TABLEAU (PERCENT POPULATED INFECTED)
SELECT location, population, date, MAX (total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))* 100 AS PopinfectedPercentage
FROM "COVID_Deaths"
WHERE continent IS NOT NULL
GROUP BY location, population,date
ORDER BY PopinfectedPercentage DESC ; --Ordering by greatest number of population infected.

-- USED FOR SHEET 3 in TABLEAU (PERCENT POPULATION INFECTED PER COUNTRY TO CREATE MAP)
SELECT location, population, MAX (total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))* 100 AS PopinfectedPercentage
FROM "COVID_Deaths"
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopinfectedPercentage DESC

-- Looking at the countries that have the highest Death counts per population

-- USED FOR SHEET 2 in TABLEAU (TOTAL DEATH COUNT)
SELECT location, MAX (Cast(total_deaths AS int)) AS TotalDeathCount 
FROM "COVID_Deaths"
WHERE continent IS NULL -- Where continents is NULL you have the location being the continent.
and location not in ('World','Upper middle income', 'High income', 'Lower middle income',
					 'Low inocome', 'European Union', 'Low income', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC; -- Ordering by highest number of deaths.

-- Looking at the continents with the highest death counts.

SELECT continent, MAX (Cast(total_deaths AS int)) AS TotalDeathCount 
FROM "COVID_Deaths"
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC; 

-- Global Numbers

-- Total number of deaths per day globally

SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS total_deaths, 
SUM(New_deaths)/SUM(new_cases) *100 AS GlobalDeathPercentage
FROM "COVID_Deaths"
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 ; 

-- Total World death percentage (no longer grouping by date)
-- USED FOR SHEET 1 IN TABLEAU (GLOBAL STATISTICS)
SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS total_deaths, 
SUM(New_deaths)/SUM(new_cases) *100 as GlobalDeathPercentage
FROM "COVID_Deaths"
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 ; 

-- Comparing the Total population vs new vaccinations
-- Using a CTE to calculate the % of people vaccinated as the days go on.

With PopvsVax (Continent, Location, Date, Population, New_vaccinations, RollingpeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION deaths.location ORDER BY deaths.location, deaths.date)
AS Rollingpeoplevaccinated
from "COVID_Deaths" AS Deaths
JOIN "COVID_Vaccinations" AS Vax
On deaths.location = vax.location 
and deaths.date = vax.date
WHERE deaths.continent IS NOT NULL

)
SELECT *, (Rollingpeoplevaccinated/population)* 100
as PercentageofPopVaccinated from PopvsVax;

-- Do this using a TEMP Table
DROP TABLE IF EXISTS PercentPopVaccinated;

CREATE TABLE PercentPopVaccinated

(Continent varchar(300), 
 location varchar(300),
 Date timestamp,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated Numeric);
 
INSERT INTO PercentPopVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
AS Rollingpeoplevaccinated
FROM "COVID_Deaths" AS Deaths
JOIN "COVID_Vaccinations" AS Vax
ON deaths.location = vax.location 
AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL ;


SELECT *, (Rollingpeoplevaccinated/population)* 100
AS PercentageofPopVaccinated FROM PercentPopVaccinated ;

-- Creating a View to Store data for visualizations. 

CREATE VIEW PercentofPopVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
AS Rollingpeoplevaccinated
FROM "COVID_Deaths" AS Deaths
JOIN "COVID_Vaccinations" AS Vax
ON deaths.location = vax.location 
AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL ;

SELECT * FROM PercentofPopVaccinated