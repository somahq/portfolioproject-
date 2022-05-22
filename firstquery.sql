select *
from portfolioproject..covedDeaths
order by 3,4

--select *
--from portfolioproject..covedvaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..covedDeaths
order by 1,2

-- looking at total cases vs total deaths 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..covedDeaths
--where location like '%saudi%'
order by 1,2

--looking at toatal cases VS population
-- shows what percentages of population got covid 
select location,date,population,total_cases, (total_cases/population)*100 as Casesprecentage
from portfolioproject..covedDeaths
--where location like '%saudi%'
order by 1,2

-- looking at countries with highest infection rate compared to population 
select location,population,max(total_cases) as highestinfectioncount , max (total_cases/population)*100 as percentpopulationinfected
from portfolioproject..covedDeaths
--where location like '%saudi%'
group by location, population
order by percentpopulationinfected desc

-- shows countries with highest death count per population 
select location ,max(cast (total_deaths as int)) as totaldeathcount 
from portfolioproject..covedDeaths
where continent is not null
group by location
order by totaldeathcount desc

-- Break things down by continent 

select location ,max(cast (total_deaths as int)) as totaldeathcount 
from portfolioproject..covedDeaths
where continent is  null
group by location
order by totaldeathcount desc

-- Global number 
select date,sum(new_cases)as  total_cases  , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int)) / sum(new_cases) * 100 as Deathpercentage
from portfolioproject..covedDeaths
--where location like '%saudi%'
where continent is not null
group by date 
order by 1,2

-- looking at total population vs vaccinations 


with popvsvac (continent , location , date , population , new_vaccinations , Rollingpepolevaccinated)
as (
select dea.continent, dea.location , dea.date , dea.population ,vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location 
, dea.date ) as Rollingpepolevaccinated
from portfolioproject..coveddeaths dea
join portfolioproject..covedvaccinations vac
    on dea.location = vac.location
	  and dea.date = vac.date
	 -- order by 2,3
	 )
select *,(Rollingpepolevaccinated/population)*100
from popvsvac


--Temp table 
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime ,
population bigint,
nwe_vaccination bigint ,
rollingpepolevaccinated bigint )



insert into #percentpopulationvaccinated

select dea.continent, dea.location , dea.date , dea.population ,vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location 
, dea.date ) as Rollingpepolevaccinated
from portfolioproject..coveddeaths dea
join portfolioproject..covedvaccinations vac
    on dea.location = vac.location
	  and dea.date = vac.date
	 -- order by 2,3
	
select *,(Rollingpepolevaccinated/population)*100
from #percentpopulationvaccinated

-- creating view to store data for visualization 
create view percentpopulationvaccinated as 
select dea.continent, dea.location , dea.date , dea.population ,vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.location 
, dea.date ) as Rollingpepolevaccinated
from portfolioproject..coveddeaths dea
join portfolioproject..covedvaccinations vac
    on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  --order by 2,3







