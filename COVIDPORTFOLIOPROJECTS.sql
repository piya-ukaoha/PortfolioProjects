select *
from [Portfolio Projects]..CovidDeaths
order by 3,4

--select *
--from [Portfolio Projects]..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Projects]..CovidDeaths
where continent is not null
order by 1,2 



--Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country.
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 AS Deathpercentage
from [Portfolio Projects]..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Total Cases vs Population
--Shows percentage of population that contracted Covid
Select Location,date,total_cases,population,total_deaths, (total_cases/population)* 100 AS PercentPopulationInfected
from [Portfolio Projects]..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Countries with Highest Infection rate compared to Population
Select Location,population, MAX(total_cases)as HighestinfectionCount, MAX((total_cases/population))* 100 AS 
PercentPopulationInfected
from [Portfolio Projects]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc 


--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc 

--ANALYSIS BY CONTINENT
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from [Portfolio Projects]..CovidDeaths
--where continent is null
--Group by location
--order by TotalDeathCount desc 


--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Looking at Continent with Highest Infection rate compared to Population
Select continent, MAX(total_cases)as HighestinfectionCount, MAX((total_cases/population))* 100 AS 
PercentPopulationInfected
from [Portfolio Projects]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by PercentPopulationInfected desc 

--GLOBAL NUMBERS

Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int)) / SUM(new_cases)* 100 as
DeathPercentage
from [Portfolio Projects]..CovidDeaths
--where location like '%states%' 
where continent is not null
Group by date
order by 1,2 

--Total Cases, Deaths and Death Percentage across the world
Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int)) / SUM(new_cases)* 100 as
DeathPercentage
from [Portfolio Projects]..CovidDeaths 
where continent is not null
order by 1,2 


--ANALYSIS USING VACCINATION TABLE
Select *
From [Portfolio Projects]..CovidVaccinations

--Joining CovidDeaths and CovidVaccinations
--Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date,dea.population, Vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Projects]..CovidDeaths Dea
Join [Portfolio Projects]..CovidVaccinations Vac
On Dea.location = Vac.location 
and Dea.date = Vac.date
where dea.continent is not null
order by 2,3

---USE CTE
With PopvsVac( Continent, Location,Date, Population,Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date,dea.population, Vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Projects]..CovidDeaths Dea
Join [Portfolio Projects]..CovidVaccinations Vac
On Dea.location = Vac.location 
and Dea.date = Vac.date
where dea.continent is not null
---order by 2,3
)

Select *, (RollingPeopleVaccinated / Population) * 100 as PercentageRollingPeopleVaccinated 
From PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date,dea.population, Vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Projects]..CovidDeaths Dea
Join [Portfolio Projects]..CovidVaccinations Vac
On Dea.location = Vac.location 
and Dea.date = Vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)* 100
From #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View 
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population, Vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Projects]..CovidDeaths Dea
Join [Portfolio Projects]..CovidVaccinations Vac
On Dea.location = Vac.location 
and Dea.date = Vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

CREATE VIEW GlobalNumbers as
Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int)) / SUM(new_cases)* 100 as
DeathPercentage
from [Portfolio Projects]..CovidDeaths
--where location like '%states%' 
where continent is not null
Group by date
--order by 1,2 

Select *
from GlobalNumbers

CREATE VIEW ContinentwithHighestInfectionrate_perpopulation as
Select continent, MAX(total_cases)as HighestinfectionCount, MAX((total_cases/population))* 100 AS 
PercentPopulationInfected
from [Portfolio Projects]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent

Select *
From ContinentwithHighestInfectionrate_perpopulation

CREATE VIEW TotalDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..CovidDeaths
where continent is not null
Group by continent

Select *
From TotalDeathCount