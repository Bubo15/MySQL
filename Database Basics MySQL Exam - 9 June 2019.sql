-- 1. Table Design

CREATE SCHEMA `ruk_database`;

CREATE TABLE `branches` (
   `id` INT PRIMARY KEY AUTO_INCREMENT,
   `name` VARCHAR(30) NOT NULL UNIQUE 
);

CREATE TABLE `employees` (
   `id` INT PRIMARY KEY AUTO_INCREMENT,
   `first_name` VARCHAR(20) NOT NULL,
   `last_name` VARCHAR(20) NOT NULL,
   `salary` DECIMAL(10,2) NOT NULL,
   `started_on` DATE NOT NULL,
   `branch_id` INT NOT NULL,
   
   CONSTRAINT `fk_employees_branches`
   FOREIGN KEY `employee` (`branch_id`)
   REFERENCES `branches` (`id`)
);

CREATE TABLE `clients` (
   `id` INT PRIMARY KEY AUTO_INCREMENT,
   `full_name` VARCHAR(50) NOT NULL,
   `age` INT NOT NULL
);

CREATE TABLE `employees_clients` (
   `employee_id` INT NOT NULL,
   `client_id` INT NOT NULL,
   
   CONSTRAINT `pk_employee_client`
   PRIMARY KEY (`employee_id`, `client_id`),
   
   CONSTRAINT `fk_employees_clients_employees`
   FOREIGN KEY `employees_clients` (`employee_id`)
   REFERENCES `employees` (`id`),
   
   CONSTRAINT `fk_employees_clients_clients`
   FOREIGN KEY `employees_clients` (`client_id`)
   REFERENCES `clients` (`id`)
);

CREATE TABLE `bank_accounts` (
   `id` INT PRIMARY KEY AUTO_INCREMENT,
   `account_number` VARCHAR(10) NOT NULL,
   `balance` DECIMAL(10,2) NOT NULL,
   `client_id` INT NOT NULL UNIQUE,
   
   CONSTRAINT `fk_bank_accounts_clients`
   FOREIGN KEY `bank_accounts` (`client_id`)
   REFERENCES `clients` (`id`)
);

CREATE TABLE `cards` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `card_number` VARCHAR(19) NOT NULL,
    `card_status` VARCHAR(7) NOT NULL,
    `bank_account_id` INT NOT NULL,
    
    CONSTRAINT `fk_cards_bank_accounts`
    FOREIGN KEY `cards` (`bank_account_id`)
    REFERENCES `bank_accounts` (`id`)
);

-- 2. Insert

INSERT INTO `cards`  (`card_number`, `card_status`, `bank_account_id`)
SELECT REVERSE(c.`full_name`), 'Active', c.`id` FROM `clients` AS `c`
WHERE c.`id` BETWEEN 191 AND 200;

-- 3. Update

UPDATE `employees_clients` JOIN
    (SELECT e.`employee_id` AS `empid` FROM `employees_clients` AS `e`
     GROUP BY e.`employee_id`
     ORDER BY COUNT(e.`client_id`), e.`employee_id`
     LIMIT 1) es
SET `employee_id` = es.`empid`
WHERE `employee_id` = `client_id`;


-- 4. Delete

DELETE e FROM employees AS e
LEFT JOIN `employees_clients` as `ec` ON e.`id` = ec.`employee_id`
WHERE ec.`client_id` is null;

-- 5. Clients

SELECT `id`, `full_name` from `clients`
ORDER BY `id`;

-- 6. Newbies

SELECT e.`id`, concat(e.`first_name`, ' ', e.`last_name`) AS `full_name`, concat('$', e.`salary`), e.`started_on`
FROM `employees` AS `e`
WHERE e.`salary` >= 100000 AND DATE(e.`started_on`) >= '2018-01-01'
ORDER BY e.`salary` DESC, e.`id`;

-- 7. Cards against Humanity

SELECT c.`id`, concat(c.`card_number`, ' : ', cl.`full_name`) AS `card_token` FROM `cards` AS `c`
JOIN `bank_accounts` AS `ba` ON c.`bank_account_id` = ba.`id`
JOIN `clients` AS `cl` ON ba.`client_id` = cl.`id`
ORDER BY c.`id` DESC;

-- 8. Top 5 Employees

SELECT CONCAT(e.`first_name`, ' ', e.`last_name`) AS `name`, e.`started_on`, COUNT(ec.`client_id`) AS `count_of_clients` FROM `employees` AS `e`
JOIN `employees_clients` AS `ec` ON e.`id` = ec.`employee_id`
GROUP BY  ec.`employee_id`, e.`id`
ORDER BY `count_of_clients` desc, e.`id`
limit 5;

-- 9. Branch cards

SELECT b.`name`, count(c2.`id`) as `cc` FROM `branches` AS `b`
         LEFT JOIN employees AS `e` on b.id = e.branch_id
         LEFT JOIN employees_clients AS `ec` on e.id = ec.employee_id
         LEFT JOIN clients AS `c` on ec.client_id = c.id
         LEFT JOIN bank_accounts AS `ba` on c.id = ba.client_id
         LEFT JOIN cards AS `c2` on ba.id = c2.bank_account_id
group by b.name
order by cc desc, b.name;

-- 10

create function
    udf_client_cards_count(name VARCHAR(30))
    returns int
begin
    declare count int;
 
    set count := (select count(c2.id)
                  from clients c
                           join bank_accounts ba on c.id = ba.client_id
                           join cards c2 on ba.id = c2.bank_account_id
                  where c.full_name = name
                  group by c.full_name);
    return count;
end;

-- 11

create procedure udp_clientinfo(name varchar(50))
begin
    select c.full_name, c.age, ba.account_number, concat('$', ba.balance)
    from clients c
             join bank_accounts ba on c.id = client_id
    where c.full_name = name;
end;













