-- 1. Employee Address

SELECT e.`employee_id`, e.`job_title`, e.`address_id`, a.`address_text` FROM `employees` AS `e`
JOIN `addresses` AS `a` ON  e.`address_id` = a.`address_id`
ORDER BY e.`address_id` LIMIT 5;

-- 2. Addresses with Towns

SELECT e.`first_name`, e.`last_name`, t.`name`, a.`address_text` FROM `employees` AS `e`
JOIN `addresses` AS `a` ON  e.`address_id` = a.`address_id`
JOIN `towns` AS `t` ON a.`town_id` = t.`town_id`
ORDER BY e.`first_name` ASC, e.`last_name` LIMIT 5;	

-- 3. Sales Employee

SELECT e.`employee_id`, e.`first_name`, e.`last_name`, d.`name` FROM `employees` AS `e`
JOIN `departments` AS `d` ON e.`department_id` = d.`department_id`
WHERE d.`name` = 'Sales'
ORDER BY e.`employee_id` DESC; 

-- 4. Employee Departments

SELECT e.`employee_id`, e.`first_name`, e.`salary`, d.`name` FROM `employees` AS `e`
JOIN `departments` AS `d` ON e.`department_id` = d.`department_id`
WHERE e.`salary` > 15000
ORDER BY e.`department_id` DESC LIMIT 5; 

-- 5. Employees Without Project

SELECT e.`employee_id`, e.`first_name` FROM `employees` AS `e`
LEFT JOIN `employees_projects` AS `ep` ON e.`employee_id` = ep.`employee_id`
WHERE ep.`project_id` IS NULL
ORDER BY `employee_id` DESC LIMIT 3;

-- 6. Employees Hired After

SELECT e.`first_name`, e.`last_name`, e.`hire_date`, d.`name` AS `dept_name` FROM `employees` AS `e`
JOIN `departments` AS `d` ON e.`department_id` = d.`department_id`
WHERE e.`hire_date` > '1999-01-01 23:59:59.997' AND d.`name` IN ('Sales', 'Finance')
ORDER BY e.`hire_date` ASC;

-- 7. Employees with Project

SELECT e.`employee_id`, e.`first_name`, p.`name` FROM `employees` AS `e`
JOIN `employees_projects` AS `ep` ON e.`employee_id` = ep.`employee_id`
JOIN `projects` AS `p` ON p.`project_id` = ep.`project_id`
WHERE p.`start_date` > '2002-08-13 23:59:59.997' AND p.`end_date` IS NULL
ORDER BY e.`first_name` ASC, p.`name` ASC LIMIT 5;	

-- 8. Employee 24

SELECT e.`employee_id`, e.`first_name`, IF(p.`start_date` >= '2005-01-01', NULL, p.`name`) FROM `employees` AS `e`
JOIN `employees_projects` AS `ep` ON e.`employee_id` = ep.`employee_id`
JOIN `projects` AS `p` ON p.`project_id` = ep.`project_id`
WHERE ep.`employee_id` = 24
ORDER BY p.`name` ASC;

-- 9. Employee Manager

SELECT e.`employee_id`, e.`first_name`, m.`employee_id` AS `manager_id`, m.`first_name` AS `manager_name` FROM `employees` AS `e`
JOIN `employees` AS `m` ON e.`manager_id` = m.`employee_id`
WHERE e.`manager_id` IN (3,7)
ORDER BY e.`first_name` ASC;

-- 10. Employee Summary

SELECT 
   e.`employee_id`,
   CONCAT_WS(' ', e.`first_name`, e.`last_name`) AS `employee_name`,
   CONCAT_WS(' ', m.`first_name`, m.`last_name`) AS `manager_name`,
   d.`name` FROM `employees` AS `e`
JOIN `employees` AS `m` ON e.`manager_id` = m.`employee_id` 
JOIN `departments` AS `d` ON e.`department_id` = d.`department_id`
ORDER BY e.`employee_id` ASC LIMIT 5;

-- 11. Min Average Salary

SELECT AVG(`salary`) FROM `employees`
GROUP BY `department_id`
ORDER BY AVG(`salary`) LIMIT 1;


SELECT MIN(`avg`) AS `min_average_salary` 
FROM ( SELECT AVG(`salary`) AS `avg`
       FROM `employees`
       GROUP BY `department_id`
) AS `averageSalary`;

-- 12. Highest Peaks in Bulgaria

SELECT c.`country_code`, m.`mountain_range`, p.`peak_name`, p.`elevation` FROM `countries` AS `c`
JOIN `mountains` AS `m`
JOIN `mountains_countries` AS `mc` ON mc.`mountain_id` = m.`id` 
JOIN `peaks` AS `p` ON p.`mountain_id` = m.`id`
WHERE mc.`country_code` = 'BG' AND c.`country_code` = 'BG' AND p.`elevation` > 2835
ORDER BY p.`elevation` DESC;

-- 13. Count Mountain Ranges

SELECT c.`country_code`, COUNT(mc.`country_code`) AS `mountain_range` FROM `countries` AS `c`
JOIN `mountains_countries` AS `mc` ON mc.`country_code` = c.`country_code` 
WHERE c.`country_name` IN ('United States', 'Russia', 'Bulgaria')
GROUP BY mc.`country_code`
ORDER BY `mountain_range` DESC;

-- 14. Countries with Rivers

SELECT c.`country_name`, r.`river_name` FROM `countries` AS `c`
LEFT JOIN `countries_rivers` AS `cr` ON cr.`country_code` = c.`country_code`
LEFT JOIN `rivers` AS `r` ON cr.`river_id` = r.`id`
WHERE c.`continent_code` = 'AF'
ORDER BY c.`country_name` ASC LIMIT 5;

-- 15. *Continents and Currencies

SELECT c.`continent_code`, c.`currency_code`, COUNT(c.`currency_code`) AS `currency_usage`
FROM `countries` AS `c`
GROUP BY  c.`continent_code`, c.`currency_code`
HAVING `currency_usage` > 1 AND `currency_usage` >= (
       SELECT COUNT(c1.`currency_code`) AS `mx` FROM `countries` AS `c1`
       WHERE c.`continent_code` = c1.`continent_code`
       GROUP BY c1.`continent_code`, c1.`currency_code`
       ORDER BY mx DESC LIMIT 1
)
ORDER BY c.`continent_code`, c.`currency_code`;

-- 16. Countries without any Mountains

SELECT COUNT(*) AS `country_count` FROM `countries` AS `c`
LEFT JOIN `mountains_countries` AS `mc` ON mc.`country_code` = c.`country_code`
WHERE mc.`mountain_id` IS NULL;

-- 17. Highest Peak and Longest River by Country

SELECT c.`country_name`, MAX(p.`elevation`) AS `highest_peak_elevation`, MAX(r.`length`) AS `longest_river_length` FROM `countries` AS `c`
JOIN `mountains_countries` AS `mc` ON  mc.`country_code` = c.`country_code`
JOIN `peaks` AS `p` ON p.`mountain_id` = mc.`mountain_id`
JOIN `countries_rivers` AS `cr` ON  cr.`country_code` = c.`country_code` 
JOIN `rivers` AS `r` ON r.`id` = cr.`river_id`
GROUP BY c.`country_name`
ORDER BY `highest_peak_elevation` DESC, `longest_river_length` DESC LIMIT 5;