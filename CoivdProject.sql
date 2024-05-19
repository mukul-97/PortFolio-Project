select count(*) from CovidDeaths
select count(*) from CovidVaccinations
select * from CovidDeaths
select * from CovidVaccinations
truncate table covidvaccinations
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float;

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Showing Likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,( total_deaths/ total_cases)*100 as Death_percentage
from CovidDeaths
where location='India' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid 

select location,date,total_cases,population,( total_cases/population )*100 as Percentage_Of_Population_Effected
from CovidDeaths
where location='India' and continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate compared to population

select location,population,Max(total_cases) as Highest_Infeaction_counts,( max( total_cases)/population )*100 as Percentage_Of_Population_Effected
from CovidDeaths
where continent is not null
group by location,population
order by Percentage_Of_Population_Effected desc


--Showing Countries with Highest Death Count per population

select location,Max(total_deaths) as Total_Deaths
from CovidDeaths
where continent is not null
group by location
order by Total_Deaths desc


-- Breaking it down by Continents
--Showing Continent with the highest death count per population

select Continent,Max(total_deaths) as Total_Deaths
from CovidDeaths
where continent is not null
group by Continent
order by Total_Deaths desc

select location,Max(total_deaths) as Total_Deaths
from CovidDeaths
where continent is null
group by location
order by Total_Deaths desc




-- GLOBAL NUMBER

select date,sum(new_cases) as Total_Cases,sum(new_deaths) as Total_Deaths, CASE WHEN sum(new_cases) = 0 THEN NULL ELSE (sum(new_deaths) / sum(new_cases))*100 END AS Global_Death_Percentage
from CovidDeaths
where  continent is not null
group by date
order by 1,2 desc


-- Overall Death Percentage 
select sum(new_cases) as Total_Cases,sum(new_deaths) as Total_Deaths, CASE WHEN sum(new_cases) = 0 THEN NULL ELSE (sum(new_deaths) / sum(new_cases))*100 END AS Global_Death_Percentage
from CovidDeaths
where  continent is not null


-- Looking at Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as Rolling_Count_Vaccinatied_People
from 
CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

with  PopvsVacc (continent,location,date,population,new_vaccinations,Rolling_Count_Vaccinatied_People)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as Rolling_Count_Vaccinatied_People
from 
CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null 
)
select *,(Rolling_Count_Vaccinatied_People/population)*100 as Daily_Vaccinated_Percentage from PopvsVacc
order by 2,3



-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent varchar(255),
location  varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_Count_Vaccinatied_People numeric 
)

insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as Rolling_Count_Vaccinatied_People
from 
CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null 

select *,(Rolling_Count_Vaccinatied_People/population)*100 as Daily_Vaccinated_Percentage from #PercentPopulationVaccinated
order by 2,3



-- Creating View to store data for later visualizations

Create view VW_Rolling_Count_Vaccinatied_People as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as Rolling_Count_Vaccinatied_People
from 
CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null 

Select 
	* 
from VW_Rolling_Count_Vaccinatied_People