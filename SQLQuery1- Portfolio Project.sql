/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functionts, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM [PortfolioProject ]..CovidDeaths
WHERE Continent is not null 
ORDER BY 3,4

--SELECT *
--FROM [PortfolioProject ]..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be starting with

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject ]..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Dealths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM [PortfolioProject ]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, Date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--LETS BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDealthCount
FROM [PortfolioProject ]..CovidDeaths
WHERE continent is NOT null 
GROUP BY continent
ORDER BY TotalDealthCount desc

--Showing Countries with Highest Death Count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDealthCount
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP BY location, population
ORDER BY TotalDealthCount desc

--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDealthCount
FROM [PortfolioProject ]..CovidDeaths
WHERE continent is NOT null 
GROUP BY continent
ORDER BY TotalDealthCount desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--or

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using the Temp Table to perform calculation on Partition by in above query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentagePopulationVaccinated


