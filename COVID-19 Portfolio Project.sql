/* 
COVID-19 Data Exploration
Skills used: Aggregate Functions, Converting Data Types, Joins, CTE's, Temp Table, Window Functions

*/

SELECT * 
FROM [Portfolio Project ]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM [Portfolio Project ]..CovidVaccinations
--ORDER BY 3,4
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project ]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract the COVID-19 in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project ]..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percetnage of population got Covid
SELECT Location, date, population,total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
FROM [Portfolio Project ]..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

--Looking at Countires with Highest Infection Rate compared to Population
SELECT Location, population, date,  MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/total_cases))*100 as PercentPopulationInfected
FROM [Portfolio Project ]..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population, Date
ORDER BY PercentPopulationInfected DESC

--Showing contintents with highest death count per population
--Breaking things down by Continent 
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project ]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
and location not in('World', 'Eurropean Union', 'International') 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers 
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project ]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP By date
ORDER BY 1,2

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project ]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Population vs Vaccination 
--Shows Percentage of the population that has recieved at least one Covid-19 Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project ]..CovidDeaths as dea
Join [Portfolio Project ]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE to preform calculations on partition by in pervious query 
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project ]..CovidDeaths as dea
Join [Portfolio Project ]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Using a TEMP Table to preform calculations on partition by in pervious query
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project ]..CovidDeaths AS dea
Join [Portfolio Project ]..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visulizations 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project ]..CovidDeaths as dea 
Join [Portfolio Project ]..CovidVaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


SELECT *
FROM PercentPopulationVaccinated



Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project ]..CovidDeaths as dea 
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


