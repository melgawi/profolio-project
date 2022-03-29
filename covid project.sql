select location,date,total_cases,new_cases,total_deaths,population from  [dbo].[covid death] order by 1,2

---total cases and total deaths
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100  as deathpercentage from   [dbo].[covid death] 
where location ='canada'


----total cases vs population
select location,date,population total_cases,(total_cases/population) *100  as deathpercentage from  [dbo].[covid death]
where location like '%states%'
order by 1,2


--countries with highest infection rate 
select location,population ,max(total_cases)as highinfectedcount,  max(total_cases/population) *100  as infetedpopulationbyperc from  [dbo].[covid death]
group by location,population
ORDER BY  infetedpopulationbyperc DESC


----showing countries highest deathcount per poplation

select location,max(cast (total_deaths as int ))as totaldeaths from  [dbo].[covid death] 
---where continent is not null
group by location order by totaldeaths desc



-----by continent
select continent ,max(cast (total_deaths as int ))as totaldeaths from  [dbo].[covid death] 
where continent is not null
group by continent order by totaldeaths desc


----showing continent  with highest death count with population

select continent ,max(cast (total_deaths as int ))as totaldeaths from  [dbo].[covid death] 
where continent is not null
group by continent order by totaldeaths desc


---global ##

select  sum(new_cases)  as total_cases ,sum(cast(new_deaths as int)) as total_deaths ,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from [dbo].[covid death]
where continent is not null
--group by date
order by 1,2

-- total population vs vacitnation
select D.continent,D.location,d.date,d.population,v.new_vaccinations,
sum(convert (bigint ,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)as 
from [dbo].[covid death]  D join
[dbo].[covid vacination]  V on D.location=V.location and  D.date=v.date
where d.continent is not null and d.continent='europe'
order by 2,3

with popvsvax(continent,location,date,population,new_vaccinations,rollingpplvax)
as 
(
select D.continent,D.location,d.date,d.population,v.new_vaccinations,
sum(convert (bigint ,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)as rollingpplvax
from [dbo].[covid death]  D join 
[dbo].[covid vacination]  V on D.location=V.location and  D.date=v.date
---where d.continent is not null 
--order by 2,3
)
select *,(rollingpplvax/population)*100 as vaxpercentage
from popvsvax

--- or create tep table 
drop table if exists #temp_percentpopvaxd
create table #temp_percentpopvaxd
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpplvax numeric
)
insert into #temp_percentpopvaxd
select D.continent,D.location,d.date,d.population,v.new_vaccinations,
sum(convert (bigint ,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)as rollingpplvax
from [dbo].[covid death]  D join 
[dbo].[covid vacination]  V on D.location=V.location and  D.date=v.date
where d.continent is not null 
--order by 2,3

select *,(rollingpplvax/population)*100 as vaxpercentage
from #temp_percentpopvaxd

----creating view to store data for later visualization

create view vw_pervaxdcentpopulation
as
select D.continent,D.location,d.date,d.population,v.new_vaccinations,
sum(convert (bigint ,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)as rollingpplvax
from [dbo].[covid death]  D join 
[dbo].[covid vacination]  V on D.location=V.location and  D.date=v.date
where d.continent is not null 
--order by 2,3


select * from[dbo].[vw_pervaxdcentpopulation] order by continent