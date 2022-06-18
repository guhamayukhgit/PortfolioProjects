select * from PortfolioProject1..CovidDeaths$
select * from PortfolioProject1..CovidVaccinations$

--Select the data that we are going to be using--

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths$
order by 1,2;

--Looking at Total Cases v/s Total Deaths--
--Shows the possibility of death if a person has contracted Covid19--

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject1..CovidDeaths$
where location like '%india%'
order by 1,2;

--Looking at Total Cases v/s Population--
--Shows the percentage of population that has contracted Covid19--

select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from PortfolioProject1..CovidDeaths$
where location like '%india%'
order by 1,2;

--Showing the Countries with the highest infected rate compared to their population--

select location, max(total_cases) as infection_count, population, 
max((total_cases/population))*100 as population_infected_percentage
from PortfolioProject1..CovidDeaths$
--where location like '%india%'
group by location, population
order by population_infected_percentage desc;

--Showing the Countries with the highest death rate compared to their population--

select continent, max(cast(total_deaths as int)) as death_count
from PortfolioProject1..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by death_count desc;

--Global Numbers--

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from PortfolioProject1..CovidDeaths$
--where location like '%india%'
where continent is not null
group by date
order by 1,2;

--Joining the deaths and the vaccination records--

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/dea.population)*100 as vaccination_percentage
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%india%'
order by 2,3;

--Using CTE--

with popVSvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as rolling_people_vaccinated
	from PortfolioProject1..CovidDeaths$ dea
	join PortfolioProject1..CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--and dea.location like '%india%'
	--order by 2,3
) select *, (rolling_people_vaccinated/population)*100 as vaccination_percentage
from popVSvac

--Temp Table--

drop table if exists #PopulationVaccinated
create table #PopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinactions numeric,
rolling_people_vaccinated numeric
) insert into #PopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as rolling_people_vaccinated
	from PortfolioProject1..CovidDeaths$ dea
	join PortfolioProject1..CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--and dea.location like '%india%'
	--order by 2,3

select *, (rolling_people_vaccinated/population)*100 as vaccination_percentage
from #PopulationVaccinated

--Create view for later visualizations--

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as rolling_people_vaccinated
	from PortfolioProject1..CovidDeaths$ dea
	join PortfolioProject1..CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--and dea.location like '%india%'
	--order by 2,3