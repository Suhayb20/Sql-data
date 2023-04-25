Select *
From prorfolio_projecet_2..CovidDeaths$
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From prorfolio_projecet_2..CovidDeaths$
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From prorfolio_projecet_2..CovidDeaths$
order by 1,2

-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From prorfolio_projecet_2..CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date, total_cases,total_deaths, (total_cases/population)*100 as infectedPercentage, population
From prorfolio_projecet_2..CovidDeaths$ 
Where location like '%Bahrain%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, max(total_cases) as highestinfectionrate, MAX((total_cases/population)*100) as infectedPercentage, population
From prorfolio_projecet_2..CovidDeaths$ 
--Where location like '%Bahrain%'
group by location,population
order by infectedPercentage desc

-- Countries with Highest Death Count per Population
select location, population, max(cast(Total_deaths as int)) as totaldeathrate 
From prorfolio_projecet_2..CovidDeaths$ 
--where location like '%Somalia%'
--and continent is not null
group by location, population
order by totaldeathrate desc

-- Showing contintents with the highest death count per population

select continent, max(cast(Total_deaths as int)) as totaldeathrate 
From prorfolio_projecet_2..CovidDeaths$ 
where continent is not null
group by continent
order by totaldeathrate desc

-- Total global infection rate

select sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as deaths_percentage
from prorfolio_projecet_2..CovidDeaths$ 
order by 1,2

-- global infection rate cross time
select date, sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as deaths_percentage
from prorfolio_projecet_2..CovidDeaths$ 
where continent is not null
group by date
order by 1,2


---> vacination
select *
from prorfolio_projecet_2..CovidVaccinations$

-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from prorfolio_projecet_2..CovidDeaths$ dea
join prorfolio_projecet_2..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- How many people are vaccinated in specific country using CTE (population vs vaccination)
with pop_vac (continet, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
Rolling_People_Vaccinated
from prorfolio_projecet_2..CovidDeaths$ dea
join prorfolio_projecet_2..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select*, (Rolling_People_Vaccinated/population)*100 as the_perctage_of_vaccinated
from pop_vac

-- How many people are vaccinated in specific country using TEMP TABLE (population vs vaccination)
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
Rolling_People_Vaccinated
from prorfolio_projecet_2..CovidDeaths$ dea
join prorfolio_projecet_2..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





