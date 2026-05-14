The Data Consolidation taking first 12 separate months od data and combining them into one "Master table" while adding a duration column and the day of the week

 CREATE OR REPLACE TABLE first-planet-494018-d6.cyclistic_2025data.cleaned_trips_2025 AS
WITH combined_data AS (
  SELECT * FROM first-planet-494018-d6.cyclistic_2025data.jan
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.feb
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.march
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.april
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.may
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.june
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.july
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.august
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.september
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.oct
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.nov
  UNION ALL SELECT * FROM first-planet-494018-d6.cyclistic_2025data.dec
)
SELECT
    *,
    TIMESTAMP_DIFF(ended_at, started_at, SECOND) AS ride_length_seconds,
    CASE EXTRACT(DAYOFWEEK FROM started_at)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_of_week
FROM combined_data
WHERE
    TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 60 -- Remove trips < 1 minute
    AND TIMESTAMP_DIFF(ended_at, started_at, HOUR) < 24; -- Remove trips > 24 hours



The Quality Assurance (The "cleaning") ensuring that there were no duplicate trips or missing IDs in master list


CREATE OR REPLACE TABLE first-planet-494018-d6.cyclistic_2025data.cleaned_trips_2025 AS
SELECT DISTINCT *
FROM first-planet-494018-d6.cyclistic_2025data.cleaned_trips_2025
WHERE ride_id IS NOT NULL
  AND started_at IS NOT NULL
  AND ended_at IS NOT NULL;


The Core Analysis this gave me the final numbers for your my report

SELECT
    member_casual,
    COUNT(*) AS total_trips,
    AVG(ride_length_seconds / 60) AS avg_ride_duration,
    MAX(ride_length_seconds / 60) AS max_ride_duration
FROM first-planet-494018-d6.cyclistic_2025data.cleaned_trips_2025
GROUP BY member_casual;

Behavioral Analysis ( these queries confirmed that casual riders peak on Saturday and at locations like navy pier
Day of the week Trends
SELECT member_casual, day_of_week, COUNT(*) as total_trips
FROM first-planet-494018-d6.cyclistic_2025data.cleaned_trips_2025
GROUP BY 1, 2
ORDER BY 1,
    CASE day_of_week
        WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 WHEN 'Sunday' THEN 7
    END;

Top Stations for casual riders
SELECT start_station_name, COUNT(*) AS total_trips
FROM first-planet-494018-d6.cyclistic_2025data.cleaned_trips_2025
WHERE member_casual = 'casual' AND start_station_name IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;