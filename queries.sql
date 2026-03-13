CREATE SCHEMA pandemic;
USE pandemic;

SELECT COUNT(*) 
FROM infectious_cases;


CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255),
    code VARCHAR(10)
);


INSERT INTO locations (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;


CREATE TABLE cases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location_id INT,
    year YEAR,
    Number_rabies FLOAT,
    FOREIGN KEY (location_id) REFERENCES locations(id)
);


INSERT INTO cases (location_id, year, Number_rabies)
SELECT 
    l.id,
    ic.Year,
    ic.Number_rabies
FROM infectious_cases ic
JOIN locations l
ON ic.Entity = l.entity 
AND ic.Code = l.code;


SELECT 
    l.entity,
    l.code,
    AVG(c.Number_rabies) AS avg_rabies,
    MIN(c.Number_rabies) AS min_rabies,
    MAX(c.Number_rabies) AS max_rabies,
    SUM(c.Number_rabies) AS total_rabies
FROM cases c
JOIN locations l
ON c.location_id = l.id
WHERE c.Number_rabies IS NOT NULL
GROUP BY l.entity, l.code
ORDER BY avg_rabies DESC
LIMIT 10;


SELECT 
    Year,
    STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d') AS first_day_year,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    ) AS year_difference
FROM cases;


DROP FUNCTION IF EXISTS year_diff;

DELIMITER //

CREATE FUNCTION year_diff(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(input_year,'-01-01'), '%Y-%m-%d'),
        CURDATE()
    );
END //

DELIMITER ;

SELECT 
    Year,
    year_diff(Year) AS years_difference
FROM cases;
