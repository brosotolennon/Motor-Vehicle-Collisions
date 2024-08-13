/*Which type of car model (SUV, Sedan, etc) most likely got into an accident?

Requirement A, B, C*/

USE mydb;
DROP VIEW IF EXISTS type_car_most_likely_in_accident;
CREATE VIEW type_car_most_likely_in_accident AS

SELECT vehicle_type,
       COUNT(*) AS accident_count
FROM vehicle_info
JOIN vehicle_damage_vehicle_info USING (unique_id)
JOIN vehicle_damage USING (vehicle_damage_id)
WHERE vehicle_type IS NOT NULL AND vehicle_type <> ''
GROUP BY vehicle_type
ORDER BY accident_count DESC; 

/*How many men vs. women were the driver of a sedan in a collision?

Requirement A, B, C*/

USE mydb;

DROP VIEW IF EXISTS men_vs_women_sedan_collision;
CREATE VIEW men_vs_women_sedan_collision AS

SELECT 
    SUM(CASE WHEN driver_sex = 'M' AND vehicle_type = 'Sedan' THEN 1 END) AS male_collision_count,
    SUM(CASE WHEN driver_sex = 'F' AND vehicle_type = 'Sedan' THEN 1 END) AS female_collision_count
FROM 
    driver_info di
JOIN vehicle_info vi
ON di.driver_id = vi.driver_id
WHERE 
    driver_sex IN ('M', 'F');

/*What vehicle type caused damage to public property and at what time?

Requirement A, B, D*/

USE mydb;

DROP VIEW IF EXISTS vehicle_type_and_public_property_damage;
CREATE VIEW vehicle_type_and_public_property_damage AS

SELECT vehicle_type, crash_time, public_property_damage
FROM collison_info ci
JOIN collison_info_public_property_damage cp
ON ci.Collision_id = cp.Collision_id
JOIN public_property_damage pp
ON cp.public_property_id = pp.public_property_id
JOIN collison_info_vehicle_info cv
ON ci.Collision_id = cv.Collision_id
JOIN vehicle_info vi
ON cv.unique_id = vi.unique_id
WHERE pp.public_property_damage IS NOT NULL
ORDER BY crash_time ASC;


/*Which car company had the most collisions?

Requirement B, C, E*/

USE mydb;

DROP VIEW IF EXISTS car_company_most_collisions;
CREATE VIEW car_company_most_collisions AS

SELECT vehicle_make AS Company_Most_Collisions
FROM (
    SELECT vehicle_make
    FROM vehicle_info
) AS Company_Vehicle
GROUP BY vehicle_make
HAVING COUNT(vehicle_make) = (
    SELECT MAX(CollisionCount)
    FROM (
        SELECT vehicle_make, COUNT(vehicle_make) AS CollisionCount
        FROM vehicle_info
        GROUP BY vehicle_make
    ) AS Vehicle_Collision_Calc
);

/*What time period had the most collisions?

Requirement A, C*/

USE mydb;

DROP VIEW IF EXISTS most_collisions_time_period;
CREATE VIEW most_collisions_time_period AS

SELECT 
    CASE
        WHEN HOUR(crash_time) >= 0 AND HOUR(crash_time) < 6 THEN '12AM-6AM'
        WHEN HOUR(crash_time) >= 6 AND HOUR(crash_time) < 12 THEN '6AM-12PM'
        WHEN HOUR(crash_time) >= 12 AND HOUR(crash_time) < 18 THEN '12PM-6PM'
        ELSE '6PM-12AM'
    END AS Time_Periods,
    COUNT(vehicle_info.unique_id) AS Accident_Amount
FROM 
    vehicle_info
    JOIN collison_info_vehicle_info USING (unique_id)
    JOIN collison_info USING (Collision_id)
GROUP BY 
    Time_Periods
ORDER BY 
    Accident_Amount DESC;

