-- 1. One-To-One Relationship

CREATE schema `relations`;

CREATE TABLE `persons`(
`person_id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
`first_name` VARCHAR(50) NOT NULL,
`salary` DECIMAL(10,2) NOT NULL,
`passport_id` INT UNIQUE NOT NULL
);

INSERT INTO `persons` 
(`person_id`, `first_name`, `salary`, `passport_id`) 
VALUE(1, 'Roberto', 43300, 102),
     (2, 'Tom', 56100, 103),
     (3, 'Yana', 60200 , 101);
     
     
CREATE TABLE `passports`(
`passport_id` INT PRIMARY KEY NOT NULL,
`passport_number` CHAR(20) UNIQUE NOT NULL
);

INSERT INTO `passports` (`passport_id`, `passport_number`)
 VALUE (101, 'N34FG21B'), (102, 'K65LO4R7'), (103, 'ZE657QP2'); 
 
ALTER TABLE `persons`
ADD CONSTRAINT `fk_persons_passports`
FOREIGN KEY `perons` (`passport_id`)
REFERENCES `passports` (`passport_id`);

-- 2. One-To-Many Relationship

CREATE TABLE `manufacturers`(
`manufacturer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL,
`established_on` DATE
);

INSERT INTO `manufacturers` (`name`, `established_on`) 
VALUE
     ('BMW', '1916-03-01'),
     ('Tesla', '2003-01-01'),
     ('Lada', '1966-05-01');
     

CREATE TABLE `models` (
`model_id` INT PRIMARY KEY NOT NULL,
`name` VARCHAR(30),
`manufacturer_id` INT
);

INSERT INTO `models` (`model_id`, `name`, `manufacturer_id`)
VALUE 
   (102, 'i6', 1),
   (101, 'X1', 1), 
   (103, 'Model S', 2),
   (104, 'Model X', 2),
   (105, 'Model 3', 2),
   (106, 'Nova', 2);

ALTER TABLE `models`
ADD CONSTRAINT `fk_models_manufacturers`
FOREIGN KEY `models` (`manufacturer_id`)
REFERENCES `manufacturers` (`manufacturer_id`);

-- 3. Many-To-Many Relationship

CREATE TABLE `students`(
     `student_id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
     `name` VARCHAR(30) NOT NULL
);

INSERT `students` (`name`) VALUE ('Mila'), ('Toni'), ('Ron');


CREATE TABLE `exams` (
  `exam_id` INT PRIMARY KEY,
  `name` VARCHAR(30) NOT NULL
  );
  
INSERT `exams` (`exam_id`, `name`) VALUE (101, 'Spring MVC'), (102, 'Neo4j'), (103, 'Oracle 11g');

CREATE TABLE `students_exams` (
  `student_id` INT,
  `exam_id` INT,
  
  CONSTRAINT `pk_students_exams` 
  PRIMARY KEY (`student_id`,`exam_id`),
  
  CONSTRAINT `fk_students_exams_exams` 
  FOREIGN KEY (`exam_id`)
  REFERENCES `exams` (`exam_id`),
  
  CONSTRAINT `fk_students_exams_students` 
  FOREIGN KEY  (`student_id`)
  REFERENCES `students` (`student_id`)
);

INSERT `students_exams` (`student_id`, `exam_id`) VALUE (1, 101), (1, 102), (2, 101), (3, 103), (2, 102), (2, 103);

-- ALTER TABLE `students_exams`
-- ADD CONSTRAINT `fk_students_exams_students` 
-- FOREIGN KEY `students_exams` (`student_id`)
-- REFERENCES `students` (`student_id`);

-- ALTER TABLE `students_exams`
-- ADD CONSTRAINT `fk_students_exams_exams` 
-- FOREIGN KEY `students_exams` (`exam_id`)
-- REFERENCES `exams` (`exam_id`);

-- 4. Self-Referencing

CREATE TABLE `teachers`(
`teacher_id` INT PRIMARY KEY,
`name` VARCHAR(20),
`manager_id` INT

-- CONSTRAINT `fk_teachers_teachers`
-- FOREIGN KEY (`manager_id`)
-- REFERENCES `teachers` (`teacher_id`)
);

INSERT INTO `teachers` (`teacher_id`, `name`, `manager_id`) VALUE 
(101, 'John', NULL),
 (102, 'Maya', 106),
 (103, 'Silvia', 106),
 (104, 'Ted', 105),
 (105, 'Mark', 101),
 (106, 'Greta', 101);
 
 ALTER TABLE `teachers`
 ADD CONSTRAINT `fk_teachers_teachers`
FOREIGN KEY (`manager_id`)
REFERENCES `teachers` (`teacher_id`);


-- 5. Online Store Database

CREATE TABLE `cities` (
  `city_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50)
);

CREATE TABLE `customers` (
`customer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`birthday` DATE,
`city_id` INT,

  CONSTRAINT `fk_customers_cities`
  FOREIGN KEY (`city_id`)
  REFERENCES `cities` (`city_id`)
);

CREATE TABLE `orders` (
  `order_id` INT PRIMARY KEY AUTO_INCREMENT,
  `customer_id` INT,
  
  CONSTRAINT `fk_orders_customers`
  FOREIGN KEY (`customer_id`)
  REFERENCES `customers` (`customer_id`)
);

CREATE TABLE `item_types` (
  `item_type_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50)
);

CREATE TABLE `items` (
  `item_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50),
  `item_type_id` INT,
  
  CONSTRAINT `fk_items_item_types`
  FOREIGN KEY (`item_type_id`)
  REFERENCES `item_types` (`item_type_id`)
);

CREATE TABLE `order_items` (
  `order_id` INT,
  `item_id` INT,
  
  CONSTRAINT `pk_order_item`
  PRIMARY KEY (`order_id`, `item_id`),
  
  CONSTRAINT `fk_order_items_orders`
  FOREIGN KEY `order_items` (`order_id`)
  REFERENCES `orders` (`order_id`),
  
  CONSTRAINT `fk_order_items_items`
  FOREIGN KEY `order_items` (`item_id`)
  REFERENCES `items` (`item_id`)
);

-- 6. University Database

CREATE SCHEMA `University`;

CREATE TABLE `majors` (
  `major_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50)
);

CREATE TABLE `students` (
 `student_id` INT PRIMARY KEY AUTO_INCREMENT,
 `student_number` VARCHAR(12),
 `student_name` VARCHAR(50),
 `major_id` INT,
 
 CONSTRAINT `fk_students_majors`
 FOREIGN KEY `students` (`major_id`)
 REFERENCES `majors` (`major_id`)
);

CREATE TABLE `payments` (
  `payment_id` INT PRIMARY KEY AUTO_INCREMENT,
  `payment_date` DATE,
  `payment_amount` DECIMAL(8,2),
  `student_id` INT,
   
   CONSTRAINT `fk_paymnets_students`
   FOREIGN KEY `payments` (`student_id`)
   REFERENCES `students` (`student_id`)
);

CREATE TABLE `subjects` (
    `subject_id` INT PRIMARY KEY AUTO_INCREMENT,
	`subject_name` VARCHAR(50)
);

CREATE TABLE `agenda` (
`student_id` INT,
`subject_id` INT,

 CONSTRAINT `pk_student_subject`
 PRIMARY KEY (`student_id`, `subject_id`),
  
  CONSTRAINT `fk_agenda_students`
  FOREIGN KEY `agenda` (`student_id`)
  REFERENCES `students` (`student_id`),
  
  CONSTRAINT `fk_agenda_subjects`
  FOREIGN KEY `agenda` (`subject_id`)
  REFERENCES `subjects` (`subject_id`)
);

-- 9. Peaks in Rila

SELECT m.`mountain_range`, p.`peak_name`, p.`elevation` FROM `peaks` AS `p`
JOIN `mountains` AS `m` ON p.`mountain_id` = m.`id`
WHERE m.`mountain_range` = 'Rila'
ORDER BY p.`elevation` DESC;