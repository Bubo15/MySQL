-- 1. Employees with Salary Above 35000

DELIMITER &&
create procedure `usp_get_employees_salary_above_35000`()
begin
    SELECT `first_name`, `last_name` FROM `employees`
    Where `salary` > 35000
    ORDER BY `first_name`, `last_name`, `employee_id`;
end
&&


CALL `usp_get_employees_salary_above_35000`();

-- 2. Employees with Salary Above Number

DELIMITER &&
create procedure `usp_get_employees_salary_above`(salary_input double)
begin
    SELECT `first_name`, `last_name` FROM `employees`
    where `salary` >= salary_input
    ORDER BY `first_name`, `last_name`, `employee_id`;
end
&&

CALL `usp_get_employees_salary_above`(48100);


-- 3. Town Names Starting With

DELIMITER &&
create procedure `usp_get_towns_starting_with`(`input_str` VARCHAR(50))
begin
    select `name` from `towns`
    where `name` like concat(`input_str`, '%')
    order by `name`;
end
&&

CALL `usp_get_towns_starting_with`('b');

-- 4. Employees from Town


DELIMITER &&
create procedure `usp_get_employees_from_town` (`town_name` VARCHAR(50))
begin
    SELECT e.`first_name`, e.`last_name` FROM `employees` as `e`
    JOIN `addresses` as `a` on e.`address_id` = a.`address_id`
    JOIN `towns` as `t` on t.`town_id` = a.`town_id`
    WHERE t.`name` = `town_name`
    ORDER BY e.`first_name`, e.`last_name`, e.`employee_id`;
end
&&

CALL `usp_get_employees_from_town` ('Sofia');

-- 5. Salary Level Function

DELIMITER &&
create function `ufn_get_salary_level` (`salary` DECIMAL(19,4))
returns varchar(10)
begin
   declare result varchar(10);
   
   IF (salary < 30000) then set result := 'Low';
   ELSEIF (salary <= 50000) then set result := 'Average';
   else set result := 'High';
   END IF;
   
   return result;
end
&&
-- 6. Employees by Salary Level   ---> v edno s 5

create procedure `usp_get_employees_by_salary_level` (salary_level VARCHAR(20))
begin
   SELECT `first_name`, `last_name` from `employees`
   WHERE ufn_get_salary_level(`salary`) = salary_level
   order by `first_name` desc, `last_name` desc;
end
&&

-- 
bank_accounts
DELIMITER &&
create function ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
returns bit
begin
    declare length int;
    declare i int;
    declare res int;
    set res = 1;
    set i = 0;
    set length = char_length(word);
 
    while (i <= length) 
         do
            if lower(set_of_letters) not like lower(concat('%', substring(word, i, 1), '%')) <> 0
               then set res = 0;
            end if;
			set i = i + 1;
	end while;
    return res;
end;
&&

SELECT substring('ASD', 0, 1);

-- 8. Find Full Name
DELIMITER &&
create procedure `usp_get_holders_full_name`()
begin
   SELECT concat(e.`first_name`, ' ', e.`last_name`) as `full_name` FROM `account_holders` as `e`
   order by `full_name`, e.`id`;
end
&&

call usp_get_holders_full_name();

-- 9. People with Balance Higher Than

DELIMITER &&
create procedure `usp_get_holders_with_balance_higher_than`(`number` double)
begin
   SELECT ah.`first_name`, ah.`last_name` FROM `account_holders` as `ah`
   JOIN `accounts` as `a` on a.account_holder_id = ah.id
   group by a.`account_holder_id`
   having SUM(a.balance) > `number`
   order by a.`id` asc;
end;
&&

call `usp_get_holders_with_balance_higher_than`(7000);

-- 10. Future Value Function
DELIMITER &&
create function `ufn_calculate_future_value`(`I` decimal(16,4), `R` decimal(16,4), `T` int)
returns decimal(16,4)
begin
   declare res decimal(16,4);
   set res := `I` * (POW(1 + `R`, `T`));
   return res;
end
&&

select `ufn_calculate_future_value`(1000, 0.1, 5);

-- 11. Calculating Interest

DELIMITER &&
create procedure `usp_calculate_future_value_for_account`(`account_id` int, `interest_rate` decimal(16,4))
begin
   SELECT 
        a.`id`, 
        ah.`first_name`,
        ah.`last_name`, 
        a.`balance`, 
        round(`ufn_calculate_future_value`(a.`balance`, `interest_rate`, 5), 4) as `balance_in_5_years` from `accounts` as `a`
   join `account_holders` as `ah` on ah.id = a.account_holder_id
   where a.`id` = `account_id`;
end
&&

call `usp_calculate_future_value_for_account`(1, 0.1);

-- 12. Deposit Money

DELIMITER &&
create procedure `usp_deposit_money`(`account_id` int, `money_amount` decimal(16,4))
begin
  update `accounts`
  set balance = balance + `money_amount`
  where `id` = `account_id` and `money_amount` >= 0;
end
&&

call `usp_deposit_money` (1,10);

-- 13. Withdraw Money

DELIMITER &&
create procedure `usp_withdraw_money`(`account_id` int, `money_amount` decimal(16,4))
begin
 start Transaction;
   if(select (`balance` - `money_amount`) from `accounts` where `id` = `account_id`) < 0 then Rollback;
   else 
      update `accounts`
      set balance = balance - `money_amount`
      where `id` = `account_id` and `money_amount` >= 0; 
   end if;
end
&&

-- 14. Money Transfer - sled else tuk moje da izvikame gornite dve proceduri koito pravqt sashtoto neshto
-- sashto taka nqma da e nujno ot proverkata dali balance shte e po malko ot 0 


DELIMITER &&
create procedure `usp_transfer_money`(`from_account_id` int, `to_account_id` int, `amount` decimal(16,4))
begin 
   start Transaction;
   
      if(select `id` from `accounts` where `id` = `from_account_id`) is null then rollback;
      elseif(select `id` from `accounts` where `id` = `to_account_id`) is null then rollback;
      elseif(`from_account_id` = `to_account_id`) then rollback;
	  elseif(select (`balance` - `amount`) from `accounts` where `id` = `from_account_id`) < 0 then Rollback;
      else
        update `accounts` set balance = balance + `amount` where `id` = `to_account_id` and `amount` >= 0;
        update `accounts` set balance = balance - `amount` where `id` = `from_account_id` and `amount` >= 0; 
        commit;
    end if;
end
&&

-- 15. Log Accounts Trigger

CREATE TABLE logs (
    `log_id` INT PRIMARY KEY AUTO_INCREMENT,
    `account_id` INT,
    `old_sum` DECIMAL(19 , 4),
    `new_sum` DECIMAL(19 , 4)
);

DELIMITER &&
CREATE TRIGGER tr_logs
AFTER UPDATE 
on `accounts`
FOR EACH ROW
BEGIN 
    INSERT INTO logs(`account_id`, `old_sum`, `new_sum`)
    VALUES(OLD.id, OLD.balance, NEW.balance);
END;
&&

update `accounts`
set balance = balance + 10
where id = 1;

select * from logs;

-- 16. Emails Trigger

CREATE TABLE `notification_emails` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `recipient` INT,
    `subject` VARCHAR(255),
    `body` VARCHAR(255)
);

 DELIMITER &&
CREATE TRIGGER `tr_logs_create_new_email`
    AFTER INSERT
    ON `logs`
    FOR EACH ROW
BEGIN
    IF (new.old_sum != new.new_sum) THEN
        INSERT INTO `notification_emails`(`recipient`, `subject`, `body`)
        VALUES (NEW.`account_id`,
                concat('Balance change for account: ', NEW.`account_id`),
                concat('On ', date_format(now(), '%b %d %Y %l:%i:%s %p'), ' your balance was changed from ', NEW.old_sum, ' to ', NEW.new_sum, '.'));
    END IF;
END;
&&

INSERT INTO `logs` (`account_id`, `old_sum`, `new_sum`) values (2, 15, 20);

select * from `notification_emails`;