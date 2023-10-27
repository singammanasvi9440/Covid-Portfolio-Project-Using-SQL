select * 
from SampleProject..CovidDeaths where continent is not null


--Data analysis
select Location,date,total_cases,new_cases,total_deaths,population
from SampleProject..CovidDeaths order by 1,2

--Total cases vs Total Deaths
select Location,date,total_cases,total_deaths 
from SampleProject..CovidDeaths order by 1,2
--Percentage of deaths in desc order
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from SampleProject..CovidDeaths order by 5 desc
--Death Percentage in Belgium
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from SampleProject..CovidDeaths 
where location='Belgium' order by 5 desc

--Total cases Vs Population
select Location,date,total_cases,population,(total_cases/population)*100 as cases_percentage
from SampleProject..CovidDeaths
order by 5 desc
--shows the percentage of covid_cases in a particular location
select Location,date,total_cases,population,(total_cases/population)*100 as cases_percentage
from SampleProject..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population
select Location,population,max(total_cases) as highest_infectioncount,population,max((total_cases/population))*100 as cases_percentage
from SampleProject..CovidDeaths
group by location,population
order by cases_percentage desc

--Countries with highest death count

select Location,max(cast(total_deaths as int)) as TotalDeathcount
from SampleProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathcount desc

--Continents with highest deaths
select continent,max(cast(total_deaths as int)) as TotalDeathcount
from SampleProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathcount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SampleProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



select * from SampleProject..CovidVaccinations

--Joining two tables CovidDeaths and CovidVaccinations
select * from SampleProject..CovidDeaths as d
join SampleProject..CovidVaccinations as v
on d.location= v.location
 and   d.date=v.date

 --tot_poulation vs vaccination
 select d.continent,d.location ,d.date,d.population,v.new_vaccinations
 from SampleProject..CovidDeaths as d
join SampleProject..CovidVaccinations as v
on d.location= v.location
 and   d.date=v.date
 where d.continent is not null and v.new_vaccinations is not null
 order by 5


  select d.continent,d.location ,d.date,d.population,v.new_vaccinations,
  sum(cast(v.new_vaccinations as int)) over ( partition by d.location order by d.location,d.date)
as RollingPeopleVaccinated
from SampleProject..CovidDeaths as d
join SampleProject..CovidVaccinations as v
on d.location= v.location
 and   d.date=v.date
 where d.continent is not null and v.new_vaccinations is not null
 order by 2,3


 --TEMP TABLE
 DROP table if exists #Percentpopulationvaccinated
 create table #Percentpopulationvaccinated(
 continent varchar(255),location varchar(255),
 Date datetime,population numeric,new_vaccinations numeric,
 rollingPeopleVaccinated numeric)



 insert into #Percentpopulationvaccinated
 select d.continent,d.location ,d.date,d.population,v.new_vaccinations,
  sum(cast(v.new_vaccinations as int)) over ( partition by d.location order by d.location,d.date)
as RollingPeopleVaccinated
from SampleProject..CovidDeaths as d
join SampleProject..CovidVaccinations as v
on d.location= v.location
 and   d.date=v.date
 where d.continent is not null and v.new_vaccinations is not null
 order by 2,3

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SampleProject..CovidDeaths d
Join SampleProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
select * from PercentPopulationVaccinated