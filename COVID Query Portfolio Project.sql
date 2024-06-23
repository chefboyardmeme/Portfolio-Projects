--Link to original data set: https://ourworldindata.org/covid-deaths
--Sample Queries


--Using CovidDeaths table
Select *
From PortfolioProject..CovidDeaths$
order by 3,4

-- Select Data To Be Used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where Continent is not null
order by 1, 2

-- Looking at Total Cases vs. Total Deaths

--Likelihood of Death after contracting the virus in your country
Select Location, date, total_cases, total_deaths, 
(Convert(decimal, total_deaths)/ Convert(decimal, total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%' and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid at that time

Select Location, date, Population, total_cases, (Convert(decimal, total_cases)/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
Where Continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(Convert(decimal,total_cases)) as HighestInfectionCount, (Max(Convert(decimal,total_cases))/population)*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths$
Where Continent is not null
Group by Location, Population
order by PopulationInfectedPercentage desc

--Showing Countries with Highest Death Count per Population

Select Location, Max(Convert(int, Total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where Continent is not null
Group by Location
order by TotalDeathCount desc

--Break Down By Continent\
--Showing continents with Highest Death Count per population

Select Continent, Max(Convert(int, Total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where Continent is not null
Group by Continent
order by TotalDeathCount desc

--Global Numbers

--Shows Total Cases and Deaths by Date, 
--Germany has reported at the start of the outbreak 1 infected and 3 dead which results in 150% Death Percentage
Select date,Sum(new_cases) as Total_Cases, Sum(new_deaths) as total_deaths, (Sum(new_deaths)/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
group by date
having Sum(new_cases) != 0
Order by 1,2

Select Sum(new_cases) as Total_Cases, Sum(new_deaths) as total_deaths, (Sum(new_deaths)/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
--group by date
--having Sum(new_cases) != 0
Order by 1,2


--Using CovidVaccinations table
--Looking at Total Population vs Vaccinations per Day

Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations
From PortfolioProject.dbo.CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
On dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
Order by 1,2,3

--Looking at Total Population & Vaccinations vs Vaccinations per Day by Country

Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject.dbo.CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
On dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
Order by 1,2,3

--Looking at how many vaccinations by country

Select dea.continent, dea.location, Max(dea.population) as Population, Sum(cast(vac. new_vaccinations as float)) as TotalVaccinations
From PortfolioProject.dbo.CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
On dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
Group By dea.location, dea.continent
Order by 1,2

--USE CTE
With PopvsVac (Continent, location, date,population,new_vaccinations,RollingTotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject.dbo.CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingTotalVaccinations/population)*100 as RollingVaccinationPercentage
From PopvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject.dbo.CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingTotalVaccinations/population)*100 as RollingVaccinationPercentage
From #PercentPopulationVaccinated


--Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject.dbo.CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
order by continent, location, date

--View 2

Create View GlobalDeathPercentage as
Select date,Sum(new_cases) as Total_Cases, Sum(new_deaths) as total_deaths, (Sum(new_deaths)/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
group by date
having Sum(new_cases) != 0
--Order by 1,2

Select *
From GlobalDeathPercentage
