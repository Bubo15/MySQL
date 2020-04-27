-- 1. Table Design

create schema `fsd`;

create table `skills_data`(
   `id` int primary key auto_increment,
   `dribbling` int default 0,
   `pace` int default 0,
   `passing` int default 0,
   `shooting` int default 0,
   `speed` int default 0,
   `strength` int default 0
);

create table `countries`(
 `id` int primary key auto_increment,
  `name` varchar(45) not null
);

create table `towns`(
 `id` int primary key auto_increment,
  `name` varchar(45) not null,
  `country_id` int not null,
  
  constraint `pk_towns_countries`
  foreign key (`country_id`)
  references `countries` (`id`)
);

create table `stadiums`(
  `id` int primary key auto_increment,
  `name` varchar(45) not null,
  `capacity` int not null,
  `town_id` int not null,
  
  constraint `pk_stadiums_towns`
  foreign key (`town_id`)
  references `towns` (`id`)
);



create table `teams`(
   `id` int primary key auto_increment,
   `name` varchar(45) not null,
   `established` date not null,
   `fan_base` bigint(20) not null,
   `stadium_id` int not null,
   
  constraint `pk_teams_stadiums`
  foreign key (`stadium_id`)
  references `stadiums` (`id`)
);

create table `players`(
   `id` int primary key auto_increment,
   `first_name` varchar(10) not null,
   `last_name` varchar(20) not null,
   `age` int default 0 not null,
   `position` char(1) not null,
   `salary` decimal(10,2) default 0 not null,
   `hire_date` datetime,
   `skills_data_id` int not null,
   `team_id` int,
   
   constraint `pk_players_skills_data`
   foreign key (`skills_data_id`)
   references `skills_data` (`id`),
   
   constraint `pk_players_teams`
   foreign key (`team_id`)
   references `teams` (`id`)
);


create table `coaches` (
  `id` int primary key auto_increment,
    `first_name` varchar(10) not null,
   `last_name` varchar(20) not null,
   `salary` decimal(10,2) default 0 not null,
   `coach_level` int default 0 not null
);

create table `players_coaches` (
  `player_id` int,
  `coach_id` int,
  
  constraint `pk_player_coach`
  primary key (`player_id`, `coach_id`),
  
  constraint `fk_players_coaches_players`
  foreign key (`player_id`)
  references `players` (`id`),
  
  constraint `fk_players_coaches`
  foreign key (`coach_id`)
  references `coaches` (`id`)
);

-- 2. Insert

insert `coaches` ( `first_name`, `last_name`, `salary`, `coach_level`)
select first_name, last_name, salary * 2, char_length(first_name) from `players`
where age >= 45;

-- 3. Update

update `coaches` as `c`
join `players_coaches` as `pc` on pc.coach_id = c.id
set c.coach_level = c.coach_level + 1
where c.first_name like 'A%' and pc.player_id >= 1;

-- 4. Delete

delete `p` from `players` as `p`
where p.age >= 45;

-- 5. Players

select `first_name`, `age`, `salary` from `players`
order by `salary` desc;

-- 6

select p.`id`, concat(p.`first_name`, ' ', p.`last_name`) as `full_name`, p.`age`, p.`position`, p.`hire_date` from `players` as `p`
join `skills_data` as `sd` on sd.id = p.skills_data_id
where p.age < 23 and p.position = 'A' and p.hire_date is null and sd.strength > 50
order by p.salary asc, p.age;

-- 7

select t.`name`, t.`established`, t.`fan_base`, count(p.id) as `players_count` from `teams` as `t`
left join `players` as `p` on t.id = p.team_id
group by t.id
order by `players_count` desc, t.fan_base desc;

-- 8. The fastest player by towns

select distinct MAX(sd.speed) as `max_speed`,  tow.`name` as `town_name`  from `teams` as `t`
left join `players` as `p` on p.team_id = t.id
left join `skills_data` as `sd` on sd.id = p.skills_data_id
join `stadiums` as `s` on s.id = t.stadium_id
join `towns` as `tow` on tow.id = s.town_id
where  t.name != 'Devify'
group by tow.id
order by `max_speed` desc, tow.name;

select distinct MAX(sd.speed) as `max_speed`, tow.`name` as `town_name` from `towns` as `tow`
join `stadiums` as `s` on s.town_id = tow.id
join `teams` as `t` on t.stadium_id = s.id
left join `players` as `p` on p.team_id = t.id
left join `skills_data` as `sd` on sd.id = p.skills_data_id
where  t.name != 'Devify'
group by tow.id
order by `max_speed` desc, tow.name;

-- 9. Total salaries and players by country

select c.name, count(p.id) as `total_count_of_players`, sum(p.salary) as `total_sum_of_salaries` from `teams` as `t`
join `players` as `p` on p.team_id = t.id
join `stadiums` as `s` on s.id = t.stadium_id
join `towns` as `tow` on tow.id = s.town_id
right join `countries` as `c` on c.id = tow.country_id
group by c.id
order by `total_count_of_players` desc, c.name asc;

-- 10. Find all players that play on stadium

delimiter &&
create function udf_stadium_players_count (stadium_name VARCHAR(30))
returns int
begin
   declare countOfPlayers int;
   
   set countOfPlayers := (select count(p.id) from `players` as `p`
                         join `teams` as `t` on t.id = p.team_id
                         join `stadiums` as `s` on s.id = t.stadium_id
                         where s.name = stadium_name);
                         
	return countOfPlayers;
end
&&

SELECT udf_stadium_players_count ('Jaxworks') as `count`; 

-- 11. Find good playmaker by teams

delimiter &&
create procedure udp_find_playmaker (min_dribble_points int, team_name varchar(45))
begin
    select concat(p.`first_name`, ' ', p.`last_name`) as `full_name`, p.`age`, p.`salary`, sd.`dribbling`, sd.`speed`, t.name from `players` as `p`
    join `skills_data` as `sd` on sd.id = p.skills_data_id
    join `teams` as `t` on t.id = p.team_id
    where sd.dribbling > min_dribble_points and t.name = team_name and sd.speed > (select avg(sd.speed) from `players` as p1
                                                                                   join `skills_data` as `sd` on p1.skills_data_id = sd.id)
	order by sd.speed desc limit 1;
end
&&

CALL udp_find_playmaker (20, 'Skyble');
