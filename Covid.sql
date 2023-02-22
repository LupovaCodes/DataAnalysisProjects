Select * from CovidProject.dbo.CovidDeaths
Where continent is not null
Order by date

Select * from CovidProject.dbo.CovidVaccinations
Order by 3, 4 

--Select Data that we are going to be starting with


Select Location, date, total_cases, new_cases, total_deaths, population 
From CovidProject..CovidDeaths
Where continent is not null
Order by 1, 2 


-- Looking at total cases vs total deaths
-- The likelihood of dying if you have Covid in your country
Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From CovidProject..CovidDeaths
Where continent is not null
Order by 1, 2 

--ALTER TABLE CovidProject..CovidVaccinations
--ALTER column new_vaccinations float

--ALTER TABLE CovidProject..CovidDeaths
--ALTER column new_deaths float

--Total cases vs population
--Shows what percentage of population infected with Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Where continent is not null
Order by 1, 2 


-- Looking at Countries with Highest Infection Rates compared to Population
Select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as  PercentPopulationInfected
From CovidProject..CovidDeaths
Where continent is not null
Group by  population, location
Order by PercentPopulationInfected DESC


-- Looking at Countries with Highest Death Count per Population
Select location, population, max(total_deaths) as TotalDeathsCount
From CovidProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathsCount desc


-- BREAKING THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population
Select continent, max(total_deaths) as ContinentTotalDeaths
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by ContinentTotalDeaths desc


-- Global numbers
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, 
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1, 2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths AS dea
Join CovidProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH popVSvac as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths as Dea
JOIN CovidProject..CovidVaccinations as Vac 
ON Dea.location = Vac.location 
and Dea.date= Vac.date
Where dea.continent is not null)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercentagePeopleVaccinated FROM popVSvac
order by location



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Looking at Max Vaccination rates per Country

WITH TotalPeopleVaccinated AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths AS Dea
JOIN CovidProject..CovidVaccinations AS Vac 
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
)
SELECT location, 
MAX(RollingPeopleVaccinated) AS MaxPeopleVaccinated, 
(MAX(RollingPeopleVaccinated)/MAX(population))*100 AS PercentagePeopleVaccinated
FROM TotalPeopleVaccinated 
GROUP BY location
ORDER BY MaxPeopleVaccinated DESC;



USE CovidProject
GO
Create View TotalPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths AS Dea
JOIN CovidProject..CovidVaccinations AS Vac 
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL






