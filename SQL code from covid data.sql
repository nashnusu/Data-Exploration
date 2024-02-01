--check data
Select *
from [SQLPortfolio  Project]..CovidDeaths$

select location, date, total_cases,total_deaths
from [SQLPortfolio  Project]..CovidDeaths$
order by 1,2

-- Global numbers

select sum(total_cases) as total_global_cases, sum(cast(total_deaths as int)) as total_deaths_globally,
sum(cast(total_deaths as int))/sum(total_cases)*100as death_percentage_globally
from [SQLPortfolio  Project]..CovidDeaths$
where continent is not null 


--looking at total cases vs total deaths 

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from [SQLPortfolio  Project]..CovidDeaths$
order by 1,2


select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from [SQLPortfolio  Project]..CovidDeaths$
where location like 'Albania'
order by 1,2

--highest infection rate compared to population


select location, population, Max(total_cases) as highestinfectioncount,max (total_cases/population)*100 as percentpopulationinfected
from [SQLPortfolio  Project]..CovidDeaths$
group by location, population
order by percentpopulationinfected desc

--countries with highest deathcount per population

select location, Max(cast(total_deaths as int)) as totaldeathcount
from [SQLPortfolio  Project]..CovidDeaths$
group by location
order by totaldeathcount desc

--total population vs vaccinations 

with PopvsVac (continent, location,date, population,new_vaccinations,cumulative_new_vaccinations)
as  
(
 SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) as cumulative_new_vaccinations
FROM
    [SQLPortfolio  Project]..CovidDeaths$ dea
join [SQLPortfolio  Project]..CovidVaccinations$ vac
ON
    dea.location = vac.location
    AND dea.date = vac.date 
where dea.continent is not null
GROUP BY 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
--order by 1,2,3
)
 
select*, (cumulative_new_vaccinations/population)*100
from PopvsVac

--temp table 

drop table if exists #percentpopulationvaccinated 
create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
New_vaccinations numeric,
cumulative_new_vaccinations numeric
)

insert into #percentpopulationvaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) as cumulative_new_vaccinations
FROM
    [SQLPortfolio  Project]..CovidDeaths$ dea
join [SQLPortfolio  Project]..CovidVaccinations$ vac
ON
    dea.location = vac.location
    AND dea.date = vac.date 
where dea.continent is not null
GROUP BY 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
order by 1,2,3


select*, (cumulative_new_vaccinations/population)*100
from #percentpopulationvaccinated

--creating views for later 

create view  percentage_population_vaccinated as 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) as cumulative_new_vaccinations
FROM
    [SQLPortfolio  Project]..CovidDeaths$ dea
join [SQLPortfolio  Project]..CovidVaccinations$ vac
ON
    dea.location = vac.location
    AND dea.date = vac.date 
where dea.continent is not null
GROUP BY 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
-- order by 1,2,3

select *
from percentage_population_vaccinated