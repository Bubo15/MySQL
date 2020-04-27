-- 1. Managers

SELECT
    e.`employee_id`, 
	CONCAT(e.`first_name`, ' ', e.`last_name`) AS `full_name`,
    d.`department_id`,
    d.`name` AS `department_name`
FROM `employees` AS `e`
JOIN `departments` AS `d` ON d.`manager_id` = e.`employee_id`
ORDER BY e.`employee_id` LIMIT 5; 

-- 3. Employees Without Managers

SELECT e.`employee_id`, e.`first_name`, e.`last_name`, d.`department_id` , e.`salary` FROM `employees` AS `e`
LEFT JOIN `departments` AS `d` ON d.`department_id` = e.`department_id`
WHERE e.`manager_id` IS NULL; 

-- 4. High Salary

SELECT COUNT(*) AS `count` FROM `employees` AS `e1`
WHERE e1.`salary` > (SELECT AVG(e2.`salary`) FROM `employees` AS `e2`);

