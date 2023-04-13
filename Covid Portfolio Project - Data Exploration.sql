use PortfolioProject;

select * from PortfolioProject..CovidDeaths_1$
where continent is not null
order by 3,4;

select * from PortfolioProject..CovidVaccinations_1$ order by 3,4;

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths_1$ 
where continent is not null
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths_1$ 
where location like '%India%'
and continent is not null
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths_1$ 
-- where location like '%India%'
where continent is not null
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths_1$ 
-- where location like '%India%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths_1$ 
-- where location like '%India%'
where continent is not null
Group by location, population
order by TotalDeathCount desc;

-- Let's break things down by continent

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths_1$ 
-- where location like '%India%'
where continent is null
Group by location
order by TotalDeathCount desc;


-- Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths_1$ 
-- where location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc;


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths_1$ 
-- where location like '%India%'
where continent is not null
Group By date
order by 1,2;

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths_1$ 
-- where location like '%India%'
where continent is not null
order by 1,2;


Select * 
from PortfolioProject..CovidDeaths_1$ dea
join PortfolioProject..CovidVaccinations_1$ vac
on dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

-- Use CTE

With PopvsVAc (Continent, Location, Date, Population, New_Vaacinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths_1$ dea
join PortfolioProject..CovidVaccinations_1$ vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From popvsVac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths_1$ dea
join PortfolioProject..CovidVaccinations_1$ vac
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths_1$ dea
join PortfolioProject..CovidVaccinations_1$ vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated;