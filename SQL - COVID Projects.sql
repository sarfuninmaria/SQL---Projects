select *
from [Project Portofolio]..CovidDeaths
where continent is not null
order by 3, 4


--select *
--from [Project Portofolio]..CovidVaccinations
--order by 3, 4


--select the data
select location, date, total_cases, new_cases, total_deaths, population
from [Project Portofolio]..CovidDeaths
order by 1, 2


-- total cases vs. total deaths 
-- likelihood of dying
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Project Portofolio]..CovidDeaths
Where location like '%states%'
order by 1, 2


-- total cases vs. population
select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from [Project Portofolio]..CovidDeaths
--Where location like '%states%'
order by 1, 2


-- counties with highest infection rate compare to population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected
from [Project Portofolio]..CovidDeaths
--Where location like '%states%'
group by location, population
order by percent_population_infected desc


-- countries with highest death per population
select location, max(cast(total_deaths as int)) as total_deaths_count
from [Project Portofolio]..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location
order by total_deaths_count desc



-- continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as total_deaths_count
from [Project Portofolio]..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
order by total_deaths_count desc


-- global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from [Project Portofolio]..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- total population vs. vaccination
-- use CTE
with population_vs_vaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [Project Portofolio]..CovidDeaths dea
join [Project Portofolio]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (rolling_people_vaccinated/population)*100
from population_vs_vaccination


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [Project Portofolio]..CovidDeaths dea
join [Project Portofolio]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3
select *, (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view for store data

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [Project Portofolio]..CovidDeaths dea
join [Project Portofolio]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated
