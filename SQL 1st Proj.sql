
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVacinations 
--ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--- Looking at TOTAL CASES VS TOTAL DEATHS
--- Likelyhood of dying if you contact COVID-19

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

--- Looking at Total Cases vs Population
--- Shows what % of population got Covid

SELECT location, date, total_cases, population,(total_cases/population)* 100 AS Percetage_of_population_Infected
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

--- Looking at Countries with highest infection rate

SELECT location,population, MAX(total_cases) AS Highest_Infection_Count,MAX((total_cases/population))* 100 AS Percetage_of_population_Infected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
GROUP BY location, population
ORDER BY Percetage_of_population_Infected DESC;

--- Showing the countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_deathcount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_deathcount DESC;  


--- Breaking by Continent
--- Showing the continents with highest death counts

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_deathcount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_deathcount DESC;

--- Breaking Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--- Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peoplevaccinated
--,(Rolling_peoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_peoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peoplevaccinated
--,(Rolling_peoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_peoplevaccinated/population)*100
FROM PopvsVac;


--- TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_peoplevaccinated numeric
)


INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peoplevaccinated
--,(Rolling_peoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(Rolling_peoplevaccinated/population)*100
FROM #PercentagePopulationVaccinated


-- Creating View 

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_peoplevaccinated
--,(Rolling_peoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentagePopulationVaccinated;