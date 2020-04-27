-- 1. Mountains and Peaks

CREATE TABLE `mountains` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50)
);

CREATE TABLE `peaks` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50),
  `mountain_id` INT,
  
  CONSTRAINT `fk_peaks_mountains`
  FOREIGN KEY ( `mountain_id`)
  REFERENCES `mountains` (`id`)
);

-- 2. Trip Organization

SELECT c.id, v.vehicle_type, CONCAT(first_name, ' ', last_name)
FROM campers AS c
JOIN vehicles AS v
ON c.id = v.driver_id;

-- 3. SoftUni Hiking

SELECT r.starting_point, r.end_point, c.id, CONCAT(c.first_name, ' ', last_name)
FROM routes AS r
JOIN campers AS c
ON c.id = r.leader_id;
