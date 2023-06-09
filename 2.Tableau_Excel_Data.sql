
--- information to get into Tableau for different excel

	-- excel 1
	
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    ROUND(SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100,3) AS DeathPercentage
FROM
    covid_data
WHERE
    continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

	-- excel 2


SELECT
    covid_data.location,
    SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM
    covid_data
WHERE
    continent IS NULL
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY
    location
ORDER BY
    TotalDeathCount DESC;

	-- excel 3

SELECT
    covid_data.location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(MAX(total_cases::NUMERIC) / population * 100, 4) AS PercentPopulationInfected
FROM
    covid_data
--WHERE location LIKE '%states%'
GROUP BY
    location,
    Population
ORDER BY
    PercentPopulationInfected DESC;

	-- excel 4

SELECT
    covid_data.location,
    population,
    date,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(MAX((total_cases::numeric / population)) * 100, 4) AS PercentPopulationInfected
FROM
    covid_data

GROUP BY
    covid_data.location,
    population,
    date
ORDER BY
    PercentPopulationInfected DESC;
