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

--- getting the infection_percentage and the death_percentage from covid_data table

select location, date, population, max(total_cases) as highest_cases,
	ROUND((total_cases::numeric / population) * 100, 2) as infection_percentage,
	round((total_deaths::numeric / total_cases)*100, 2) as death_percentage
from covid_data
group by location, population, total_cases, date, total_deaths
limit 25;

-- now gettin vaccination_percentage 

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

-- visualizing the data together in a single table

WITH covid_stats AS (
    SELECT
        location,
        date,
        population,
        max(total_cases) AS highest_cases,
        ROUND((total_cases::numeric / population) * 100, 2) AS infection_percentage,
        ROUND((total_deaths::numeric / total_cases) * 100, 2) AS death_percentage
    FROM
        covid_data
    GROUP BY
        location,
        date,
        population,
        total_cases,
        total_deaths
    LIMIT 25
),
vaccination_stats AS (
    SELECT
        covid_data.location,
        covid_data.population,
        MAX(covid_vaccin.total_vaccinations::numeric) AS highest_vaccination,
        ROUND(MAX(covid_vaccin.total_vaccinations) / NULLIF(covid_data.population::numeric, 0) * 100, 5) 
	AS vaccination_percentage
    FROM
        covid_data
    JOIN covid_vaccin ON covid_data.location = covid_vaccin.location
    GROUP BY
        covid_data.location,
        covid_data.population
    ORDER BY
        covid_data.location
)
SELECT
    cs.location,
    cs.date,
    cs.population,
    cs.highest_cases,
    cs.infection_percentage,
    cs.death_percentage,
    vs.highest_vaccination,
    vs.vaccination_percentage
FROM
    covid_stats cs
JOIN vaccination_stats vs ON cs.location = vs.location;

-- creating the last table with the total data and than move to Tableau

CREATE TABLE Covid19_Stats AS (
	WITH covid_stats AS (
    SELECT
        location,
        date,
        population,
        max(total_cases) AS highest_cases,
        ROUND((total_cases::numeric / population) * 100, 2) AS infection_percentage,
        ROUND((total_deaths::numeric / total_cases) * 100, 2) AS death_percentage
    FROM
        covid_data
    GROUP BY
        location,
        date,
        population,
        total_cases,
        total_deaths
),
vaccination_stats AS (
    SELECT
        covid_data.location,
        covid_data.population,
        MAX(covid_vaccin.total_vaccinations::numeric) AS highest_vaccination,
        ROUND(MAX(covid_vaccin.total_vaccinations) / NULLIF(covid_data.population::numeric, 0) * 100, 5)
	AS vaccination_percentage
    FROM
        covid_data
    JOIN covid_vaccin ON covid_data.location = covid_vaccin.location
    GROUP BY
        covid_data.location,
        covid_data.population
    ORDER BY
        covid_data.location
)
SELECT
    cs.location,
    cs.date,
    cs.population,
    cs.highest_cases,
    cs.infection_percentage,
    cs.death_percentage,
    vs.highest_vaccination,
    vs.vaccination_percentage
FROM
    covid_stats cs
JOIN vaccination_stats vs ON cs.location = vs.location
);
