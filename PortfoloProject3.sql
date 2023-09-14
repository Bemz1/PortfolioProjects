Select *
from CovidDeaths1$
where location is not null


-- Select data that we are using 

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths1$
order by 1,2

-- Looking at Total Cases Vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
from CovidDeaths1$
where location like '%states%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what Population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 As PercentageofPopulationInfected
, max(new_cases) over (partition by population order by date, location) As RollingCases
from CovidDeaths1$
where location like '%Nigeria%'
order by 1,2

-- Using CTE's
with PopvsCases (Location, date, Population, new_cases, total_cases, PercentageofPopulationInfected, RollingCases)
As
(
Select Location, date, Population, new_cases, total_cases, (total_cases/population)*100 As PercentageofPopulationInfected
, sum(new_cases) over (partition by population order by date, location) As RollingCases
from CovidDeaths1$
where location like '%Canada%'
--order by 1,2
)

Select *, (RollingCases/Population)*100 As RollingCasesPercent
from PopvsCases

-- Using TempTable 
Drop table if exists #RollingCasePercentage
Create Table #RollingCasePercentage
(
Location nvarchar(255)
, date datetime
, population numeric
, total_cases numeric
, PercentageofPopulationInfected numeric
, RollingCases numeric
)

Insert into #RollingCasePercentage
Select Location, date, Population, total_cases, (total_cases/population)*100 As PercentageofPopulationInfected
, sum(new_cases) over (partition by population order by date, location) As RollingCases
from CovidDeaths1$
--order by 1,2

Select *, (RollingCases/population)*100 RollingPercentageCases
From #RollingCasePercentage


-- Looking at Countries with Highest Infection Rate Compared to Population
Select Location, Population, Max(total_cases) As HighestInfectionCount, (total_cases/population)*100 As PercentagePopulationInfected
from CovidDeaths1$
Group by location, population, total_cases
order by PercentagePopulationInfected Desc


-- Let's break things down by continent
-- Showing continents with the highest death count per population

Select continent, Max(Cast(total_deaths as int)) As TotalDeathCount
from CovidDeaths1$
where continent is not null
Group by continent
order by TotalDeathCount Desc

-- Global Numbers

Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 As DeathPercentage
from CovidDeaths1$
order by 1,2

-- Looking at total population vs Vaccination

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.population order by dea.location, dea.date) As RollingPeopleVaccinated
from CovidDeaths1$ dea
join Vaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Alter table Vaccinations1$
alter column new_vaccinations float

-- Using CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.population order by dea.location, dea.date) As RollingPeopleVaccinated
from CovidDeaths1$ dea
join Vaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 As RollingPercentagePV
from PopVsVac

--Using TempTables
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255)
, Location nvarchar(255)
, date datetime
, population numeric
, new_vaccinations numeric
, RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.population order by dea.location, dea.date) As RollingPeopleVaccinated
from CovidDeaths1$ dea
join Vaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 As RollingPercentagePV
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization

Create view PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.population order by dea.location, dea.date) As RollingPeopleVaccinated
from CovidDeaths1$ dea
join Vaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3