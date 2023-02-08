-- Just reading data.

SELECT *
from CovidDeaths
where continent is not null
order by 3, 4


-- Select Data to be used

SELECT Location, Date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1 DESC

-- Total cases vs total deaths.
-- Shows the chances of person dying due to covid.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
FROM CovidDeaths
where location = 'India'
and continent is not null
ORDER by 2

-- Total cases vs population
-- Shows the infected percentage as per the population.

Select Location, Date, population, total_cases, (total_cases/population) * 100 as Infected_Percentage
FROM CovidDeaths
where location = 'Germany'
and continent is not null
order by 2

-- Countries with highest infection rate compared to the population

Select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population)) * 100 as Max_Infected_Percentage
FROM CovidDeaths
where continent is not null
group by location, population
ORDER by 4 desc

-- Continents with highest infection rate

Select continent, max(total_cases) as Highest_Infection_Rate, max(total_cases/population) * 100 as Max_Infected_Percentage
From CovidDeaths
where continent is not null
group by continent


-- Countries with Highest Death Count 

Select location, max(total_deaths) as Max_Death_Count
From CovidDeaths
where continent is null
group by location
order by 2 desc

-- Continents with highest death rate

SELECT continent, max(total_deaths) as Max_Death_Count
From CovidDeaths
GROUP by continent
order by 2 

-- Sum of new cases grouped by date at global level.

SELECT Date, 
       sum(new_cases) as New_Cases_Sum,
       sum(new_deaths) as New_Deaths_Sum,
       format(SUM(new_deaths)/SUM(new_cases) * 100, 'N3') as Death_Percentage
From CovidDeaths
where continent is not null
group by date
order by 1

-- Across the world. 

SELECT  
       sum(new_cases) as New_Cases_Sum,
       sum(new_deaths) as New_Deaths_Sum,
       format(SUM(new_deaths)/SUM(new_cases) * 100, 'N3') as Death_Percentage
From CovidDeaths
where continent is not null
order by 1

-- Calculating the rolled vaccinations as per date, location

SELECT dea.[Date],
       dea.Continent,
       dea.[Location],
       dea.Population,
       vac.New_vaccinations,
       SUM(vac.new_vaccinations) over (partition by dea.location order by dea.Date, dea.location) as Rolled_Vaccinations
       
From CovidDeaths as dea
JOIN CovidVaccinations as vac
on dea.date = vac.[date]
and dea.[location] = vac.[location]
WHERE dea.continent is NOT NULL
order by 3


-- With CTE

WITH PopsvsVacc (Date, Continent, Location, Population, New_vaccinations, Rolled_Vaccinations)
as 
(
    SELECT dea.[Date],
       dea.Continent,
       dea.[Location],
       dea.Population,
       vac.New_vaccinations,
       SUM(vac.new_vaccinations) over (partition by dea.location order by dea.Date, dea.location) as Rolled_Vaccinations     
From CovidDeaths as dea
JOIN CovidVaccinations as vac
on dea.date = vac.[date]
and dea.[location] = vac.[location]
WHERE dea.continent is NOT NULL
)

Select *, (Rolled_Vaccinations/Population) * 100 as Vaccinated_Percentage
FROM PopsvsVacc

SELECT SUM(new_deaths)
FROM CovidDeaths
WHERE continent is not NULL
and continent in ('Asia', 'Europe', 'Africa', 'South America', 'North America', 'Oceania')
and [location] != 'World'

Select max(date)
from CovidDeaths

-- With Temp tables
DROP TABLE if EXISTS #VaccinationTemp
CREATE table #VaccinationTemp
(
    Date DATE,
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Population NUMERIC,
    New_vaccinations NUMERIC,
    Rolled_Vaccinations NUMERIC
)

Insert into #VaccinationTemp

    SELECT dea.[Date],
       dea.Continent,
       dea.[Location],
       dea.Population,
       vac.New_vaccinations,
       SUM(vac.new_vaccinations) over (partition by dea.location order by dea.Date, dea.location) as Rolled_Vaccinations     
    From CovidDeaths as dea
    JOIN CovidVaccinations as vac
    on dea.date = vac.[date]
    and dea.[location] = vac.[location]
    -- WHERE dea.continent is NOT NULL

SELECT *, (Rolled_Vaccinations/Population) * 100 as Vaccinated_Percentage
FROM #VaccinationTemp

-- Creating views 
Create view VaccinatedPeopleView AS
SELECT dea.[Date],
       dea.Continent,
       dea.[Location],
       dea.Population,
       vac.New_vaccinations,
       SUM(vac.new_vaccinations) over (partition by dea.location order by dea.Date, dea.location) as Rolled_Vaccinations
       
From CovidDeaths as dea
JOIN CovidVaccinations as vac
on dea.date = vac.[date]
and dea.[location] = vac.[location]
WHERE dea.continent is NOT NULL
-- order by 3

SELECT *
from VaccinatedPeopleView
