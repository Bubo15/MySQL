-- 1. Select Employee Information

SELECT `id`, `first_name`, `last_name`, `job_title` FROM `employees`
ORDER BY `id`;

-- 2. Select Employees with Filter

SELECT `id`, concat_ws(' ', `first_name`, `last_name`) AS 'full_name', `job_title`, `salary` 
FROM `employees` 
WHERE `salary` > 1000.00
ORDER BY `id`;

-- 3. Update Salary and Select

UPDATE `employees`
SET salary = salary * 1.1
WHERE job_title =  'Therapist';


SELECT salary FROM `employees`
ORDER BY salary ASC;

-- 4. Top Paid Employee

CREATE VIEW `employee` AS
SELECT * FROM `employees`
ORDER BY salary DESC
LIMIT 1;

SELECT * FROM employee;

-- 5 Select Employees by Multiple Filters

SELECT * FROM `employees`
WHERE department_id = 4 AND salary >= 1600
ORDER BY id ;

-- 6. Delete from Table