Select * from Portfolioproject..coviddeaths$
order by 3,4

--Select * from Portfolioproject..covidvac$
--order by 3,4


select location, date, total_cases, total_deaths, population
from Portfolioproject..coviddeaths$
order by 1,2

--Looking at Total Cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..coviddeaths$
where location like '%india%'
order by 1,2


--looking at Total cases vs poplation

Select location, date, total_cases, population, (total_cases/population)*100 as POpulationInfected
from Portfolioproject..coviddeaths$
where location like '%india%'
order by 1,2


--looking at the countries with Highest infection rate compared to poupulation

Select location,population,MAX(total_cases) as HightestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from Portfolioproject..coviddeaths$
--where location like '%india%'
group by location,population
order by 1,2


--showing countries with highest death count per population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..coviddeaths$
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc


--By continent


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..coviddeaths$
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing the continents with the highest death count


select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..coviddeaths$
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolioproject..coviddeaths$
where continent is not null
order by 1,2



--Looking at total population vs vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portfolioproject..covidvac$ vac
join Portfolioproject..coviddeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
With popvsvac (continent, location, date, population,new_vaccination, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portfolioproject..covidvac$ vac
join Portfolioproject..coviddeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac



--temptable
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portfolioproject..covidvac$ vac
join Portfolioproject..coviddeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later viz

create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portfolioproject..covidvac$ vac
join Portfolioproject..coviddeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * 
from percentpopulationvaccinated
