Select location, date, total_cases, new_cases, total_deaths, population
from covid_data
order by 1,2;

-- looking at Total Cases vs Total Deaths
	-- shows percentage of daying by covid by country 

Select location, date, total_cases, total_deaths, population, 
	ROUND((total_deaths::numeric / total_cases) * 100, 5)
	as Deaths_Percentage
from covid_data
order by 1,2;

-- now let's take a look at total cases vs population 
	-- shows percentage of population that got Covid
	
Select location, date, total_cases, total_deaths, population, 
	ROUND((total_cases::numeric / population) * 100, 5)
	as Deaths_by_Population
from covid_data
order by 1,2;

-- countries with highest infection rate by population 

Select location, population, max(total_cases) as Highest_infection, 
	ROUND(Max(total_cases::numeric / population) * 100, 5)
	as Deaths_by_Population
from covid_data
group by location, population
order by Deaths_by_Population desc;

-- now let's see under same criteria highest number of people died

Select location, population, max(total_deaths) as Highest_Deaths, 
	ROUND(max(total_deaths::numeric / population) * 100, 5)
	as Deaths_by_Population
from covid_data
where continent is not null
group by location, population
order by Highest_Deaths desc;

-- now let's look at the other table 

select * from covid_data;

-- looking at total population vs vaccination 

SELECT covid_data.location, (max (covid_vaccin.total_vaccinations::numeric)) as Highest_vaccination,
       ROUND(max(covid_vaccin.total_vaccinations / 
			  NULLIF(covid_data.population::numeric, 0)) * 100, 5) 
	   AS vaccination_percentage
FROM covid_data
JOIN covid_vaccin
ON covid_data.location = covid_vaccin.location 
	GROUP BY covid_data.location, 
		covid_vaccin.total_vaccinations
order by covid_data.location
limit 20;

---- took a while to get the formula right 

SELECT covid_data.location, covid_data.population, 
		MAX(covid_vaccin.total_vaccinations::numeric) 
			AS Highest_vaccination,
	ROUND(MAX(covid_vaccin.total_vaccinations) / NULLIF(covid_data.population::numeric, 0) * 100, 5) 
	   		AS vaccination_percentage
FROM covid_data
JOIN covid_vaccin ON covid_data.location = covid_vaccin.location 
GROUP BY covid_data.location, covid_data.population
ORDER BY covid_data.location
LIMIT 20;

-- now let's create a table with this information 


--create table vaccination_stats as
(
	SELECT covid_data.location, covid_data.population, 
		MAX(covid_vaccin.total_vaccinations::numeric) 
			AS Highest_vaccination,
	ROUND(MAX(covid_vaccin.total_vaccinations) / NULLIF(covid_data.population::numeric, 0) * 100, 5) 
	   		AS vaccination_percentage
FROM covid_data
JOIN covid_vaccin ON covid_data.location = covid_vaccin.location 
GROUP BY covid_data.location, covid_data.population
);

-- after the table has been created we can update 
	--or alter the table to insert different information 
