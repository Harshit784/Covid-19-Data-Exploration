select * from
PortfolioProject..UpdatedDeaths
where continent is not null
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..UpdatedDeaths
where continent is not null
order by 1,2

--Total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/cast(total_cases as float))*100 as death_percentage
from PortfolioProject..UpdatedDeaths
where location='India'
and continent is not null
order by 1,2

--total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as covid_hit_percentage
from PortfolioProject..UpdatedDeaths
where location='India'
and continent is not null
order by 1,2

--countries with highest infection rate
select location,max(total_cases) as highest_infection_count,population,max((total_cases/population))*100 as percent_population_infected
from PortfolioProject..UpdatedDeaths
where location = 'United States'
and continent is not null
group by location,population
order by percent_population_infected desc

--create sub-table
with sub_table as
(select * from PortfolioProject..UpdatedDeaths
where date<'2021-04-30'
order by date,location)

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..UpdatedDeaths
where continent is not null
group by location
order by total_death_count desc

--breaking by continent
select continent,max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..UpdatedDeaths
where continent is not null
group by continent
order by total_death_count 

--new cases and deaths per day
select date,sum(cast(new_cases as int)) as cases_per_day,sum(cast(new_deaths as int)) as deaths_per_day,(sum(cast(new_deaths as int))/sum(cast(new_cases as float)))*100 as death_percentage_per_day
from PortfolioProject..UpdatedDeaths
where continent is not null
group by date
order by 1,2


--QUERIES ON COVID VACCINATIONS


--looking at total population vs vaccination

select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from PortfolioProject..UpdatedDeaths as d 
join PortfolioProject..UpdatedVaccinations as v
on d.location=v.location
and d.date = v.date
where d.continent is not null
order by 2,3

--using CTE clause
with popvsvac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from PortfolioProject..UpdatedDeaths as d 
join PortfolioProject..UpdatedVaccinations as v
on d.location=v.location
and d.date = v.date
where d.continent is not null
)
select *,(rolling_people_vaccinated/population)*100
from popvsvac

--TEMP TABLE

drop table if exists percentpeoplevaccinated
create table percentpeoplevaccinated
(
continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,rolling_people_vaccinated numeric
)

insert into percentpeoplevaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from PortfolioProject..UpdatedDeaths as d 
join PortfolioProject..UpdatedVaccinations as v
on d.location=v.location
and d.date = v.date
where d.continent is not null

select *,(rolling_people_vaccinated/population)*100
from percentpeoplevaccinated




--Creating Views For Later Visualization

create view PercentPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from PortfolioProject..UpdatedDeaths as d 
join PortfolioProject..UpdatedVaccinations as v
on d.location=v.location
and d.date = v.date
where d.continent is not null


select *,(rolling_people_vaccinated/population)*100
from PercentPopulationVaccinated