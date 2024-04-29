--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to use

--select location, date, total_cases,new_cases,total_deaths,population
--from PortfolioProject..CovidDeaths
--order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

--select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--order by 1,2

-- looking at total cases vs population

--select location, date, total_cases,population,(total_cases/population) as Percentage
--from PortfolioProject..CovidDeaths
----where location like '%india%'
--order by 1,2


--looking at countries with highest infection rate compared to population

--select location, population, max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as InfectedPercentage
--from PortfolioProject..CovidDeaths
--group by location, population
--order by InfectedPercentage desc

-- showing countries with highest death count per population

--select location, max(cast(total_deaths as int)) as highestdeathcount
--from PortfolioProject..CovidDeaths
--where continent is not null
--group by location
--order by highestdeathcount desc

-- showing continents with the highest death count

--select continent, max(cast(total_deaths as int)) as highestdeathcount
--from PortfolioProject..CovidDeaths
--where continent is not null
--group by continent
--order by highestdeathcount desc


-- global numbers

--select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, 
--(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where continent is not null
----group by date
--order by 1,2


-- looking at total population vs vaccinations

--select * from
--PortfolioProject..coviddeaths as dea
--join
--PortfolioProject..covidvaccinations as vac
--on dea.location = vac.location
--and dea.date = vac.date

-- What is the total number of people in the world who have been vaccinated?

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths as dea
join
PortfolioProject..covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac

-- same thing using a temp table

create table #percentpopulationvaccinated
(
continent varchar(255),location varchar(255),date datetime,population numeric,
new_vaccinations numeric, rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths as dea
join
PortfolioProject..covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


-- Creating View to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths as dea
join
PortfolioProject..covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated