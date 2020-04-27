-- 1. Create Tables

CREATE DATABASE `MY`;

CREATE TABLE `employees` (
   `id` INT PRIMARY KEY AUTO_INCREMENT,
   `first_name` VARCHAR(30) NOT NULL,
   `last_name` VARCHAR(30) NOT NULL
);

CREATE TABLE `categories`(
   `id` INT PRIMARY KEY AUTO_INCREMENT,
   `name`  VARCHAR(30) NOT NULL
);

CREATE TABLE `products`(
   `id` INT PRIMARY KEY AUTO_INCREMENT,
   `name` VARCHAR(30) NOT NULL,
   `category_id` INT NOT NULL
);

-- 02. Insert Data in Tables

INSERT `employees` VALUE (1, 'asd', 'asd'), (2, 'dsa', 'dsa'), (3, 'ads', 'ads');

-- 03. Alter Table

ALTER TABLE `employees`
ADD COLUMN `middle_name` VARCHAR(50) NOT NULL;

-- 04. Adding Constraints

ALTER TABLE `products`
ADD CONSTRAINT fk_products_categories
    FOREIGN KEY `products` (`category_id`)
	REFERENCES `categories` (`id`);
    
-- 5. Modifying Columns

ALTER TABLE `employees`
MODIFY COLUMN middle_name VARCHAR(100);

