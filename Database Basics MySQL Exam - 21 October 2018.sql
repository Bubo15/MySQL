-- 0.Table Design

CREATE DATABASE `colonial_journey_management_system_db`;

create table `planets` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(30) not null
);

create table `spaceports` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) not null,
  `planet_id` int,
  
  constraint `pk_spaceports_planets`
  foreign key (`planet_id`)
  references `planets` (`id`)
);

create table `spaceships` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) not null,
  `manufacturer` VARCHAR(30) not null,
  `light_speed_rate` int default 0
);

create table `colonists` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
  `first_name` VARCHAR(20) not null,
  `last_name` VARCHAR(20) not null,
  `ucn` char(10) not null unique,
  `birth_date` DATE NOT NULL
);

create table `journeys` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`journey_start` datetime not null,
`journey_end` datetime not null,
`purpose` enum('Medical', 'Technical', 'Educational', 'Military') not null,
`destination_spaceport_id` int,
`spaceship_id` int,

constraint `fk_journeys_spaceships`
foreign key (`spaceship_id`)
references `spaceships` (`id`),

constraint `fk_journeys_spaceports`
foreign key (`destination_spaceport_id`)
references `spaceports` (`id`)
);

create table `travel_cards` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `card_number` char(10) not null unique,
  `job_during_journey`  enum('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook') not null,
`colonist_id` int,
`journey_id` int,

constraint `fk_travel_cards_colonists`
foreign key (`colonist_id`)
references `colonists` (`id`),

constraint `fk_travel_cards_journeys`
foreign key (`journey_id`)
references `journeys` (`id`)
);

-- 1. Insert

INSERT INTO `travel_cards` (`card_number`, `job_during_journey`, `colonist_id` ,`journey_id`)
SELECT (
CASE
   WHEN c.`birth_date` > '1980-01-01' THEN CONCAT(YEAR(c.`birth_date`),DAY(c.`birth_date`), substring(c.`ucn`, 1,4))
   ELSE CONCAT(YEAR(c.`birth_date`),MONTH(c.`birth_date`), substring(c.`ucn`, -4))
END
), (
CASE
   WHEN c.`id` % 2 = 0 THEN 'Pilot'
   WHEN c.`id` % 3 = 0 THEN 'Cook'
   ELSE 'Engineer'
END
), c.`id` ,
substring(c.`ucn`, 1, 1) FROM `colonists` as `c`
WHERE c.`id` BETWEEN 96 AND 100;

-- 2. Update

UPDATE `journeys` 
SET `purpose` = 
(
CASE 
  WHEN `id` % 2 = 0 THEN 'Medical'
  WHEN `id` % 3 = 0 THEN 'Technical'
  WHEN `id` % 5 = 0 THEN 'Educational'
  WHEN `id` % 7 = 0 THEN 'Military'
END)
where id % 2 = 0
   or id % 3 = 0
   or id % 5 = 0
   or id % 7 = 0;

-- 3. Delete

delete c from colonists as `c`
left join travel_cards as `tc` on c.`id` = tc.`colonist_id`
where tc.`colonist_id` is null;

-- 4. Extract all travel cards

select `card_number`, `job_during_journey` from `travel_cards`
order by `card_number`;

-- 5. Extract all colonists

SELECT `id`, concat(`first_name` , ' ' ,`last_name`) as `full_name`, `ucn` from `colonists`
order by `first_name`, `last_name`, `id`;

-- 6. Extract all military journeys

SELECT `id`, `journey_start` , `journey_end` FROM `journeys`
WHERE `purpose` = 'Military'
order by `journey_start`;

-- 7. Extract all pilots

SELECT c.`id`, concat(c.`first_name` , ' ' ,c.`last_name`) as `full_name` from `colonists` as c
JOIN `travel_cards` as `tc` ON tc.colonist_id = c.id
WHERE tc.job_during_journey = 'Pilot'
order by `id`;

-- 8. Count all colonists

SELECT  count(*) as `count` from `colonists` as c
JOIN `travel_cards` as `tc` ON tc.colonist_id = c.id
JOIN `journeys` as `j` ON j.id = tc.journey_id
WHERE j.purpose = 'Technical';

-- 9.Extract the fastest spaceship

select s1.`name` as `spaceship_name`, s.name as `spaceport_name` from `spaceships` AS `s1`
JOIN `journeys` as `j` on j.spaceship_id = s1.id
JOIN `spaceports` as `s` ON s.id = j.destination_spaceport_id
WHERE s1.light_speed_rate = (select Max(s2.light_speed_rate) from spaceships as s2);

-- 10. Extract - pilots younger than 30 years

select s1.`name`, s1.`manufacturer` from `spaceships` AS `s1`
JOIN `journeys` as `j` on j.spaceship_id = s1.id
JOIN `travel_cards` as `tc` on j.id = tc.journey_id
JOIN `colonists` as `c` on tc.colonist_id = c.id
WHERE c.birth_date > date('1989-01-01') AND tc.job_during_journey = 'Pilot'
GROUP BY s1.`name`
ORDER BY s1.`name` asc;

-- 11. Extract all educational mission

SELECT p.`name` as `planet_name`, sp.name as `spaceport_name` from `planets` as `p`
JOIN `spaceports` as `sp` on sp.planet_id = p.id
JOIN `journeys` as `j` on j.destination_spaceport_id = sp.id
JOIN `spaceships` as `sh` on j.spaceship_id = sh.id
WHERE j.`purpose` = 'Educational'
ORDER BY `spaceport_name` DESC;

-- 12. Extract all planets and their journey count

SELECT p.`name` as `planet_name`, count(j.destination_spaceport_id) as `journeys_count` FROM `planets` as `p`
JOIN `spaceports` as `s` on s.`planet_id` = p.`id`
JOIN `journeys` as `j` on j.`destination_spaceport_id` = s.`id`
group by p.`name`
order by `journeys_count` desc, p.`name` asc; 

-- 13. Extract the shortest journey

SELECT j.`id`, p.`name` as `planet_name`, s.`name` as `spaceport_name`, j.`purpose` as `journey_purpose` FROM `planets` as `p`
JOIN `spaceports` as `s` on s.`planet_id` = p.`id`
JOIN `journeys` AS `j` on j.`destination_spaceport_id` = s.`id`
where j.`journey_end` - j.`journey_start` = (
		SELECT MIN(j2.`journey_end` - j2.`journey_start`) FROM `journeys` as `j2`
);

-- 14. Extract the less popular job

SELECT tc1.`job_during_journey` FROM `travel_cards` AS `tc1`
JOIN `journeys` as `j` on j.`id` = tc1.`journey_id`
where j.`journey_end` - j.`journey_start` = (
		SELECT MAX(j2.`journey_end` - j2.`journey_start`) FROM `journeys` as `j2`
) 
group by tc1.`job_during_journey`
ORDER BY COUNT(tc1.`job_during_journey`) LIMIT 1;

-- 15
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER &&
create function `udf_count_colonists_by_destination_planet` (`planet_name` VARCHAR (30))
RETURNS INT
BEGIN
   DECLARE count int;
   set count := 
      (SELECT count(c.id) FROM `planets` as `p`
      join `spaceports` as `sp` on sp.planet_id = p.id
      join `journeys` as `j` on j.destination_spaceport_id = sp.id
      join `travel_cards` as `tc` on tc.journey_id = j.id
      join `colonists` as `c` on c.id = tc.colonist_id
      where p.name = `planet_name`);
	return count;
END
 &&

 
 SELECT p.name, udf_count_colonists_by_destination_planet('Otroyphus') AS count
FROM planets AS p
WHERE p.name = 'Otroyphus';

-- 16. Modify spaceship
DELIMITER &&
create procedure `udp_modify_spaceship_light_speed_rate` (`spaceship_name` VARCHAR(50), `light_speed_rate_increse` INT(11))
begin
    start transaction;
   
   if not exists(select `name` from `spaceships` 
                 where `name` = spaceship_name) then ROLLBACK;
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
    end if;
 
    update `spaceships`
    set `light_speed_rate` = `light_speed_rate` + `light_speed_rate_increse`;
    commit;
end;
&&
 
CALL udp_modify_spaceship_light_speed_rate ('Na Pesho koraba', 1914);
SELECT name, light_speed_rate FROM spacheships WHERE name = 'Na Pesho koraba';

CALL udp_modify_spaceship_light_speed_rate ('USS Templar', 5);
SELECT name, light_speed_rate FROM spaceships WHERE name = 'USS Templar';

