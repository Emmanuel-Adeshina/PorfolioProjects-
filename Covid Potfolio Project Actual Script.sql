SELECT *
FROM PotfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PotfolioProject..CovidVaccination
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PotfolioProject..CovidDeaths

--Looking at Total_Cases vs Total_Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PotfolioProject..CovidDeaths
WHERE location LIKE 'Ghana%'
And continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
SELECT location, date,population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PotfolioProject..CovidDeaths
--WHERE location LIKE 'Nigeria%'
ORDER BY 1,2

--Looking at Countries with highest Infection Rate Compared to Polpulation 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PotfolioProject..CovidDeaths
--WHERE location LIKE 'Nigeria%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--Showing Highest Death Count Per Population 

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PotfolioProject..CovidDeaths
--WHERE location LIKE 'Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--BREAKING THINGS UP BY CONTINTNET

-- Showing Continent with Highest Death Count Per Population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PotfolioProject..CovidDeaths
--WHERE location LIKE 'Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT SUM(new_cases) as TotalCases,SUM(cast (new_deaths as int)) as TotalDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PotfolioProject..CovidDeaths
--WHERE location LIKE 'Nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at  Total Population vs Vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
--FROM PotfolioProject..CovidDeaths dea
JOIN PotfolioProject..CovidVaccination vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE
WITH PopvsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
FROM PotfolioProject..CovidDeaths dea
JOIN PotfolioProject..CovidVaccination vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT*,(RollingPeoplevaccinated/Population)*100
FROM PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
FROM PotfolioProject..CovidDeaths dea
JOIN PotfolioProject..CovidVaccination vac
   ON dea.location = vac.location
   and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*,(RollingPeoplevaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating views for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
FROM PotfolioProject..CovidDeaths dea
JOIN PotfolioProject..CovidVaccination vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated