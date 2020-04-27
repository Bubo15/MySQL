-- 1. Create Tables

CREATE TABLE `minions` (
 `id` INT NOT NULL PRIMARY KEY,
 `name` VARCHAR(45) NOT NULL,
 `age` INT
);

CREATE TABLE `towns` (
 `id` INT NOT NULL PRIMARY KEY,
 `name` VARCHAR(45)
);

-- 2. Alter Minions Table

ALTER TABLE `minions`
ADD COLUMN `town_id` INT;

ALTER TABLE `minions`
ADD CONSTRAINT `fk_minions_towns`

FOREIGN KEY `minions` (`town_id`)
REFERENCES `towns` (`id`);
  
-- 3. Insert Records in Both Tables

INSERT INTO `towns`(`id`, `name`) 
VALUES (1, 'Sofia'), (2, 'Plovdiv'), (3, 'Varna');
 
INSERT INTO `minions`(`id`, `name`, `age`, `town_id`) 
VALUES (1, 'Kevin', 22, 1), (2, 'Bob', 15, 3), (3, 'Steward', NULL, 2);
 
 -- 4. Truncate Table Minions

 TRUNCATE TABLE `minions`;

-- 5. Drop All Tables

 DROP TABLE `minions`;
 DROP TABLE `towns`;

-- 6. Create Table People

CREATE TABLE `people` (
  `id` INT NOT NULL UNIQUE PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `picture` BLOB NULL,
  `height` FLOAT(5,2) NULL,
  `weight` FLOAT(5,2) NULL,
  `gender` CHAR NOT NULL,
  `birthdate` DATE NOT NULL,
  `biography` TEXT NULL
);

-- 7. Create Table Users

CREATE TABLE `users` (
  `id` INT NOT NULL UNIQUE PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(30) NOT NULL UNIQUE,
  `password` VARCHAR(25) NOT NULL,
  `profile_picture` BLOB NULL,
  `last_login_time` TIMESTAMP NULL,
  `is_deleted` BOOLEAN NULL
 );
 
INSERT INTO users (username, password, profile_picture, last_login_time, is_deleted)
VALUES('stanva', '123', NULL, NOW(), TRUE),
      ('stanvb', '124', NULL, NOW(), FALSE),
      ('stanvc', '125', NULL, NOW(), TRUE),
      ('stanvd', '126', NULL, NOW(), FALSE),
      ('stanve', '127', NULL, NOW(), TRUE);
 
 -- 8. Change Primary Key
 
 ALTER TABLE `users` DROP PRIMARY KEY,
 ADD CONSTRAINT pk_users PRIMARY KEY (`id`, `username`);

-- 9. Set Default Value of a Field

 ALTER TABLE `users` 
 CHANGE COLUMN `last_login_time` `last_login_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ;

-- 10. Set Unique Field

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_id PRIMARY KEY(id), 
ADD UNIQUE(`username`); 

-- 11 Movies Database

CREATE TABLE `directors`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(45) NOT NULL,
`notes` TEXT
);
 
INSERT INTO `directors` (`director_name`)
    VALUES ('Kiro'),
        ('Miro'),
        ('Tosho'),
        ('Gosho'),
        ('Ani');
 
CREATE TABLE `genres`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`genre_name` VARCHAR(45) NOT NULL,
`notes` TEXT
);
 
INSERT INTO `genres` (`genre_name`)
    VALUES ('KiroG'),
        ('MiroG'),
        ('ToshoG'),
        ('GoshoG'),
        ('AniG');
 
CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(45) NOT NULL,
`notes` TEXT
);
 
INSERT INTO `categories` (`category_name`)
    VALUES ('KiroC'),
        ('MiroC'),
        ('ToshoC'),
        ('GoshoC'),
        ('AniC');
 
CREATE TABLE `movies`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(45) NOT NULL,
`director_id` INT,
`copyright_year` YEAR,
`length` INT(3),
`genre_id` INT,
`category_id` INT,
`rating` DECIMAL,
`notes` TEXT
);  
 
INSERT INTO `movies` (`title`,`director_id`,`genre_id`,`category_id`)
    VALUES ('KiroM',1,1,1),
        ('MiroM',2,2,2),
        ('ToshoM',3,3,3),
        ('GoshoM',4,4,4),
        ('AniM',5,5,5);

-- 12 Car Rental Database

create table categories(
    id INT(11) AUTO_INCREMENT primary key,
    category varchar(50) not null,
    daily_rate int(3),
    weekly_rate int(3),
    monthly_rate int(3),
    weekend_rate int(3)
);

create table cars(
    id INT AUTO_INCREMENT primary key,
    plate_number varchar(50) not null,
    make varchar(50),
	model varchar(50),
    car_year int(4),
    category_id INT(11),
    doors INT(2),
    picture blob,
    car_condition varchar(50),
    available bool,
    
	CONSTRAINT fk_cars_categories 
    FOREIGN KEY `cars` (`category_id`)
	REFERENCES `categories` (`id`)
);

create table employees(
    id INT AUTO_INCREMENT primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    title varchar(50),
    notes text
);

create table customers(
    id INT AUTO_INCREMENT primary key,
    driver_licence_number int(11) not null,
    full_name varchar(50),
    address varchar(50),
    city varchar(50),
    zip_code int(5),
    notes text
);
 
create table rental_orders(
    id INT AUTO_INCREMENT primary key,
    employee_id int(11) not null,
    customer_id int(11),
    car_id int(11) not null,
    car_condition varchar(50),
    tank_level INT(11),
    kilometrage_start int(11),
    kilometrage_end int(11),
    total_kilometrage int(11),
    start_date date,
    end_date date,
    total_days INT(11),
    rate_applied INT(3),
    tax_rate INT(11),
    order_status varchar(50),
    notes text,
    
    CONSTRAINT fk_rental_orders_employees 
    FOREIGN KEY `rental_orders` (`employee_id`)
	REFERENCES `employees` (`id`),
    
    CONSTRAINT fk_rental_orders_customers
    FOREIGN KEY `rental_orders` (`customer_id`)
	REFERENCES `customers` (`id`),
     
	CONSTRAINT fk_rental_orders_cars 
    FOREIGN KEY `rental_orders` (`car_id`)
	REFERENCES `cars` (`id`)
);

insert into cars(plate_number) values ('123'),('1234'),('12345');
insert into categories(category) values ('Classic'),('Limuzine'),('Sport');
insert into customers(driver_licence_number) values ('2232'),('232323'),('111');
insert into employees(first_name,last_name) values ('Ivan', 'Ivanov'),('Ivan1', 'Ivanov1'), ('Ivan2', 'Ivanov2');
insert into rental_orders(employee_id,car_id) values (1, 1),(1, 2), (2, 3);

-- 13 Hotel Database
create table employees(
    id  int primary key not null auto_increment,
    first_name varchar(50)     not null,
    last_name varchar(50)     not null,
    title varchar(50)     not null,
    notes blob not null
);
 
insert into employees(id, first_name, last_name, title, notes)
values (1, 'da', 'dwa', 'dad', 'dawda'),
       (2, 'da', 'dwa', 'dad', 'dawda'),
       (3, 'da', 'dwa', 'dad', 'dawda');
 
create table customers
(
    account_number   int primary key not null auto_increment,
    first_name       varchar(50)     not null,
    last_name        varchar(50)     not null,
    phone_number     int     not null,
    emergency_name   varchar(50)     not null,
    emergency_number int     not null,
    notes            blob not null
);
insert into customers(account_number,
                      first_name, last_name,
                      phone_number, emergency_name,
                      emergency_number, notes)
values (1, 'sa', 'sa', 21, 'sa', 123, 'dawda'),
       (2, 'sa', 'sa', 21, 'sa', 123, 'dawda'),
       (3, 'sa', 'sa', 21, 'sa', 123, 'dawda');
 
create table room_status
(
    room_status int not null,
    notes       blob not null
);
 
insert into room_status(room_status, notes)
values (1, 'daw'),
       (2, 'daw'),
       (3, 'daw');
 
create table room_types
(
    room_type varchar(50),
    notes     blob not null
);
 
insert into room_types(room_type, notes)
values ('zxc', 'daw'),
       ('zxc', 'daw'),
       ('zxc', 'daw');
 
create table bed_types
(
    bed_type varchar(50),
    notes    blob not null
);
 
insert into bed_types(bed_type, notes)
values ('top', 'da'),
       ('top', 'da'),
       ('top', 'da');
 
create table rooms
(
    room_number int primary key not null auto_increment,
    room_type   varchar(50)     not null,
    bed_type    varchar(50)     not null,
    rate        int             not null,
    room_status int     not null,
    notes       blob not null
);
insert into rooms(room_number, room_type, bed_type, rate, room_status, notes)
values (1, 'daw', 'da', 5, 32, 'dawd'),
       (2, 'daw', 'da', 5, 32, 'dawd'),
       (3, 'daw', 'da', 5, 32, 'dawd');
 
create table payments
(
    id                  int primary key not null auto_increment,
    employee_id         int             not null,
    payment_date        datetime        not null,
    account_number      int             not null,
    first_date_occupied date            not null,
    last_date_occupied  date            not null,
    total_days          int             not null,
    amount_charged      int             not null,
    tax_rate            int             not null,
    tax_amount          int             not null,
    payment_total       int              not null,
    notes               blob not null
);
 
insert into payments (id, employee_id, payment_date, account_number, first_date_occupied,
                      last_date_occupied, total_days, amount_charged, tax_rate, tax_amount, payment_total, notes)
values (1, 1, '2000-10-10', 5, '2000-10-10', '2000-10-10', 20, 10, 10, 10, 10, 'блоб'),
       (2, 1, '2000-10-10', 5, '2000-10-10', '2000-10-10', 20, 10, 10, 10, 10, 'блоб'),
       (3, 1, '2000-10-10', 5, '2000-10-10', '2000-10-10', 20, 10, 10, 10, 10, 'блоб');
 
create table occupancies
(
    id             int primary key not null auto_increment,
    employee_id    int             not null,
    date_occupied  date            not null,
    account_number int             not null,
    room_number    int             not null,
    rate_applied   int             not null,
    phone_charge   int             not null,
    notes          blob not null
);
 
insert into occupancies(id, employee_id, date_occupied, account_number,
                        room_number, rate_applied, phone_charge, notes)
values (1, 1, '2000-10-10', 1, 5, 1, 1, 'dawd'),
       (2, 1, '2000-10-10', 1, 5, 1, 1, 'dawd'),
       (3, 1, '2000-10-10', 1, 5, 1, 1, 'dawd');
-- 14. Create SoftUni Database

 CREATE DATABASE `soft_uni`;

 CREATE TABLE `towns`(
   `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   `name` VARCHAR(30) NOT NULL
 );

 CREATE TABLE `addresses` (
   `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   `address_text` VARCHAR(255) NOT NULL,
   `town_id` INT,
   CONSTRAINT fk_addresses_towns
   FOREIGN KEY `addresses` (`town_id`)
   REFERENCES `towns` (`id`)
 ); 

 CREATE TABLE `departments`(
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   `name` VARCHAR(50) NOT NULL
 );

CREATE TABLE `employees` (
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `first_name` VARCHAR(45) NOT NULL,
    `middle_name` VARCHAR(45) NOT NULL,
    `last_name` VARCHAR(45) NOT NULL,
    `job_title` VARCHAR(45) NOT NULL,
    `department_id` INT,
    `hire_date` DATE,
    `salary` DECIMAL(10 , 2 ),
    `address_id` INT,
   
   CONSTRAINT fk_employees_departments FOREIGN KEY (`department_id`)
        REFERENCES `departments` (`id`),
  
  CONSTRAINT fk_employees_addresses FOREIGN KEY (`address_id`)
        REFERENCES `addresses` (`id`)
);

-- 15. Basic Insert

INSERT INTO `towns` (`id`,`name`) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna'),
(4, 'Burgas');

INSERT INTO `departments` (`id`,`name`) VALUES
(1, 'Engineering'),
(2, 'Sales'),
(3, 'Marketing'),
(4, 'Software Development'),
(5, 'Quality Assurance');

INSERT INTO `employees`
(`id`,
`first_name`,
`middle_name`,
`last_name`,
`job_title`,
`department_id`,
`hire_date`,
`salary`)
VALUES
(1, 'Ivan', 'Ivanov', 'Ivanov', '.NET Developer',	4,	'2013/02/01',3500.00),
(2, 'Petar', 'Petrov', 'Petrov', 'Senior Engineer',	1,	'2004/03/02', 4000.00),
(3, 'Maria', 'Petrova', 'Ivanova',	'Intern', 5, '2016/08/28', 525.25),
(4, 'Georgi', 'Terziev', 'Ivanov',	'CEO' ,2 ,	'2007/12/09', 3000.00),
(5, 'Peter', 'Pan', 'Pan', 'Intern', 3, '2016/08/28', 599.88);

-- 16. Basic Select All Fields

SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;

-- 17. Basic Select All Fields and Order Them

SELECT * FROM `towns`
ORDER BY `name`;

SELECT * FROM `departments`
ORDER BY `name`;

SELECT * FROM `employees`
ORDER BY `salary` DESC;

-- 18. Basic Select Some Fields

SELECT `name` FROM `towns` ORDER BY `name`;
SELECT `name` FROM `departments` ORDER BY `name`;
SELECT `first_name`, `last_name`, `job_title`, `salary` FROM `employees` ORDER BY `salary` DESC;

-- 19. Increase Employees Salary

UPDATE `employees` SET salary = salary + (salary * 0.1);
SELECT `salary` FROM `employees`;

-- 20 Decrease Tax Rate

use `hotel`;
UPDATE `payments` SET tax_rat = tax_rate - (tax_rate * 0.03);
SELECT `tax_rate` FROM `payments`;

-- 21. Delete All Records

TRUNCATE TABLE `occupancies`;
