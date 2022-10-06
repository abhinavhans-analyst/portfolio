--Data Analysis on Covid dataset with two different dataset, covid_deaths and covid_vaccinations--

select * 
from portfolio_project..covid_deaths$
where continent is not Null
order by 3,4

--select * 
--from portfolio_project..covid_vaccinations$
--order by 3,4
--using the required data for covid deaths

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..covid_deaths$ 
where continent is not Null
order by 1,2

--total cases vs total deaths

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as dealth_percentage
from portfolio_project..covid_deaths$
where location like '%states%'
order by 1,2

--total cases vs population

select location, max(total_cases) as highestInfectedCases, population, round(MAX((total_cases/population))*100,2) as percentPopulationInfected
from portfolio_project..covid_deaths$
--where location like '%states%'
where continent is not Null
group by location, population
order by percentPopulationInfected desc


-- countries with highest death per population

select location, max(cast(total_deaths as int)) as total_death_count
from portfolio_project..covid_deaths$
where continent is not Null
group by location
order by total_death_count desc

-- Analysis according to continent

select continent, max(cast(total_deaths as int)) as total_deaths
from portfolio_project..covid_deaths$
where continent is not null
group by continent
order by total_deaths desc

--world stats
--date wise new cases vs total deaths
select date, sum(new_cases) as new_cases,sum(cast(total_deaths as int)) as total_deaths, ((sum(cast(total_deaths as int))/sum(new_cases))*100) as death_percentage
from portfolio_project..covid_deaths$
where continent is not null
group by date
order by 1,2

--total cases and deaths

select continent, sum(new_cases) as new_cases, sum(cast(total_deaths as int)) as total_death
from portfolio_project..covid_deaths$
where continent is not null
group by continent

--vaccination dataset

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccination
from portfolio_project..covid_deaths$ dea
join portfolio_project..covid_vaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

--cte

with pop_vac(continent, locaiton, date, population, new_vaccincations, rolling_total_vaccincation)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccination
from portfolio_project..covid_deaths$ dea
join portfolio_project..covid_vaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
)

select *, round((rolling_total_vaccincation/population)*100,2) as percentage_vacc_pop
from pop_vac


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
-- uisng insert for temporary table

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..covid_deaths$ dea
Join portfolio_project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating view for population percentage vaccincation

create view percent_population_vaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccination
from portfolio_project..covid_deaths$ dea
join portfolio_project..covid_vaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 

