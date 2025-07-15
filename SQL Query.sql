CREATE DATABASE Covid

/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Covid..CovidDeaths 
order by date, location, continent


-- Select Data that we are going to be starting with

Select Continent, Location, Date, New_cases, Total_cases, New_deaths, Total_deaths, Population
From Covid..CovidDeaths
Where continent is not null 
order by continent, location


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Continent, Location, Date, Total_cases, Total_deaths, (total_deaths/(convert(float,total_cases)))*100 as DeathPercentage
From Covid..CovidDeaths
Where location in ('united states', 'india', 'united kingdom', 'france', 'germany', 'canada')
And continent is not null 
Order by continent, location, date


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Continent, Location, Date, Population, Total_cases,  (total_cases/cast(population as float)*100) as PercentPopulationInfected
From Covid..CovidDeaths
order by date, location


-- Countries with Highest Infection Rate compared to Population

Select Continent, Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/cast(population as float)))*100 as PercentPopulationInfected
From Covid..CovidDeaths
Group by continent, location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count in a single day using Having


SELECT location, max(new_deaths) as Highest_death_in_a_day
From Covid..CovidDeaths
Where continent is not null
Group By location
Having Max(new_deaths) > 0
order by location


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select dea.Continent, MAX(dea.total_deaths) as Max_TotalDeathCount_in_a_day 
From Covid..CovidDeaths dea
Where continent is not null 
Group by continent



-- GLOBAL DEATH PERCENTAGE DATE WISE

Select Date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, (cast(SUM(new_deaths) as float)/cast(SUM(new_cases) as float))*100 as DeathPercentage
From Covid..CovidDeaths
where continent is not null 
Group By date
order by date



-- Percentage of people fully vaccinated

Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.people_fully_vaccinated, 
(vac.people_fully_vaccinated/(convert(float,vac.population))*100) as Percentage_fully_vaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and people_fully_vaccinated is not null
order by continent, location, date


-- Using CTE to perform Calculation on percentage of people with atleast single vaccination

With PopvsVac (Continent, Location, Date, Population, people_vaccinated, Percentage_atleast_single_vaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, vac.people_vaccinated/(convert(float,vac.population))*100 as Percentage_atleast_single_vaccination
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and people_vaccinated is not null
)
Select *
From PopvsVac
Order By continent, location, date



-- Using Temp Table to perform Calculation on Percentage of people fully vaccinated

--DROP Table if exists #PercentPopulationVaccinated
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
People_fully_vaccinated float,
Percentage_fully_vaccinated float,
)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.People_fully_vaccinated, 
(vac.people_fully_vaccinated/(convert(float,vac.population))*100) as Percentage_fully_vaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and people_fully_vaccinated is not null
order by continent, location, date

Select *
From #PercentPopulationVaccinated
