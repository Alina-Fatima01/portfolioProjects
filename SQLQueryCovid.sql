
Select *
From PortfolioProject..CovidDeaths
where continent is not null

-- Changing Data type of Total cases and Total deaths
Alter Table PortfolioProject..CovidDeaths
ALTER COLUMN total_cases INT;

Alter Table PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths INT;

--calculating Death Percentage Total cases vs Total deaths
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like  '%pak%'
order by 1,2

--Looking at total cases Vs Population
--shows what percentage of population got Covid
Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))* 100 AS Percentagepopulationinfected
from PortfolioProject..covidDeaths
--where location like  '%pak%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location,population, 
MAX (total_cases) as HighestInfectionCount,
MAX (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))* 100 AS Percentagepopulationinfected
from PortfolioProject..CovidDeaths
--where location like  '%pak%'
group by population,location
order by Percentagepopulationinfected desc

-- showing countries with the highest death count per population
Select location,population,
MAX (cast (total_deaths as int) )as deathCount
from PortfolioProject..CovidDeaths
--where location like  '%pak%'
where continent is NOT NULL	
group by population, location
order by deathCount desc

--lets break this down by continent
Select continent,
MAX (cast (total_deaths as int) )as deathCount
from PortfolioProject..CovidDeaths
--where location like  '%pak%'
where continent is not null
group by continent
order by deathCount desc

--showing continents with highest Death count per population
Select continent,population,
MAX (cast (total_deaths as int) )as deathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent,population
order by deathCount desc

--global numbers

Select location, date, new_cases,new_deaths, 
sum((CONVERT(float, new_deaths) / NULLIF(CONVERT(float, new_cases), 0)) * 100) AS Deathpercentage
from PortfolioProject..covidDeaths
where continent is not null
group by date, location, new_cases,new_deaths
order by 1,2

-- joining two tables
select *
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--looking at population vs vaccination
select dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations,
sum (CONVERT(float,vac.new_vaccinations)) over(partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsVac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations,
sum (CONVERT(float,vac.new_vaccinations)) over(partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *
from popvsVac

--temp table
drop table if exists #percentpopulationVaccinated
create table #percentpopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date nvarchar(255),
population nvarchar(255),
new_vaccinations nvarchar(255),
Rollingpeoplevaccinated numeric
)
insert into #percentpopulationVaccinated
select dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations,
sum (CONVERT(float,vac.new_vaccinations)) over(partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (Rollingpeoplevaccinated/population)*100
from #percentpopulationVaccinated


--creating view to store data for later visualization
create view percentpopulationVaccinated as
select dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations,
sum (CONVERT(float,vac.new_vaccinations)) over(partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationVaccinated





