select * from vaccinations
select * from covid_Deaths


---Porcentaje de personas que mueren en cada país
select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage, population
From covid_Deaths where location ='Mexico'
order by 2,3 desc,4 desc

--alter table  covid_Vaccinations alter column new_vaccinations float

--Buscar el total de casos frente a su población

select location, date, total_cases,population,(total_cases/population)*100 as CovidPercentage
From covid_Deaths 
where 1=1 
--and location ='Mexico'
and continent is not null
order by 2,3 desc,4 desc



--Buscar el porcentaje más alto de infección
select location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as CovidPercentage
From covid_Deaths 
where 1=1 
--and location ='Mexico'
and continent is not null
group by location,population
Having MAX((total_cases/population)*100) is not null
order by 3 desc,4 desc


--Paises con el mayor numero de muertes por población
select location, MAX(total_deaths) as HighestDeathsCount,MAX((total_deaths/population)*100) as DeathPercentage
From covid_Deaths 
where 1=1 
--and location ='Mexico'
and continent is not null
group by location
Having MAX((total_deaths/population)*100) is not null
order by 2 desc,3 desc

select * from covid_Deaths where location='Canada'


--Continentes con el mayor numero de muertes por población
select date ,continent, SUM(total_deaths) as HighestDeathsCount,MAX((total_deaths/population)*100) as DeathPercentage
From covid_Deaths 
where 1=1 
--and location ='Mexico'
and continent is not null
and date ='2023-07-04'
group by date,continent
Having MAX((total_deaths/population)*100) is not null
order by 3 desc,4 desc

--opcion 2 data ya contabilizada
select location, MAX(total_deaths) as HighestDeathsCount,MAX((total_deaths/population)*100) as DeathPercentage
From covid_Deaths 
where 1=1 
--and location ='Mexico'
and continent is not null
group by location
Having MAX((total_deaths/population)*100) is not null
order by 2 desc,3 desc


--Numeros a nivel Global

select  date, 
SUM(new_cases)  as totalNewCases, 
SUM(new_deaths) as totalNewDeaths,
SUM(total_cases) as totalCases,
SUM(total_deaths) as total_deaths, 
SUM(total_deaths)/SUM(total_cases)*100 as DeathPercentage
From covid_Deaths 
where 1=1 
--and location ='Mexico'
and continent is not null
group by date
order by 1



---Trabajando con vacunaciones y muertes
-- validar el porcentaje de vacunados contra el numero de población
with pVac (Continent, Location, Date, Population,New_Vaccinations,totalVaccinated)
as
(
select cd.continent,cd.location, cv.date,cv.population,cv.new_vaccinations,
SUM(cv.new_vaccinations) over (PARTITION by cd.location order by cd.location, cd.date) totalVaccinated
--(totalVaccinated/cd.population*100) as percentageVaccinated,
from vaccinations cv
join covid_Deaths cd 
on cd.date =cv.date and cv.location =cd.location 
where 1=1 
and cd.location ='Mexico'
and cv.continent is not null and cd.continent is not null
--order by 2,3
)

select *,(totalVaccinated/population*100) as percentageVaccinated from pVac 




-- aplicando el uso de tablas temporales

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_Deaths cd
Join vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where 1=1
--and dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Utilizando vista para obtener el mismo resultado

create view PercentPopulationVaccinatedView as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_Deaths cd
Join vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 

select * from PercentPopulationVaccinatedView

