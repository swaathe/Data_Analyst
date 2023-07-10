select *
from PortfolioProject..CovidDeaths
where continent is not null
order  by 3,4


--looking at total cases vs total deaths
-- likelihood of dying if you contacrt covid
select location, date, total_cases , new_cases , total_deaths , (Total_deaths/total_cases)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like 'india'
order  by 1,2

--looking at total cases vs population

select location, date,population, total_cases ,  total_deaths , (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order  by 1,2


-- countries with highest infect rate compared to population

select location , population, max(total_cases) as highestinfectioncount , max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order  by PercentPopulationInfected desc


--showing countries with highest death count per population

select location , max(cast(total_deaths as int)) as totalDeathcount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order  by totalDeathcount desc

--by continent - breaking things

select continent , max(cast(total_deaths as int)) as totalDeathcount 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order  by totalDeathcount desc


-- global nums

select  date,sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent --(Total_deaths/total_cases)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order  by 1,2

--total pop vs vaccination

 select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --use CTE
 with PopvsVac(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated )
 as 
 (
  select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )

 select * , (RollingPeopleVaccinated/Population)*100
 from PopvsVac



 --temp table
 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255), location nvarchar(255),
 date datetime,
 Population numeric, 
 New_vaccinations numeric, 
 RollingPeopleVaccinated numeric 
 )

 insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

 select * , (RollingPeopleVaccinated/Population)*100
 from #PercentPopulationVaccinated


 --- creating view for data viz

 create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select * from PercentPopulationVaccinated