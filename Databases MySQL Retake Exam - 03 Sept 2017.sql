-- 1. Table Design

create schema `instagraph_db`;

create table `pictures` (
  `id` int primary key auto_increment,
  `path` varchar(255) not null,
  `size` decimal(10,2) not null
);

create table `users` (
 `id` int primary key auto_increment,
 `username` varchar(30) not null unique,
 `password` varchar(30) not null,
 `profile_picture_id` int,
 
 constraint `fk_users_pictures`
 foreign key (`profile_picture_id`)
 references `pictures` (`id`) 
);

create table `posts` (
   `id` int primary key auto_increment,
   `caption` varchar(255) not null,
   `user_id` int not null,
   `picture_id` int not null,
   
  
  constraint `fk_posts_users`
  foreign key (`user_id`)
  references `users` (`id`),
  
  constraint `fk_posts_pictures`
  foreign key (`picture_id`)
  references `pictures` (`id`)
);

create table `comments` (
     `id` int primary key auto_increment,
     `content` varchar(255) not null,
     `user_id` int not null,
     `post_id` int not null,
     
     constraint `fk_comments_users`
     foreign key (`user_id`)
     references `users` (`id`),
  
     constraint `fk_comments_posts`
     foreign key (`post_id`)
     references `posts` (`id`)
);

create table `users_followers` (
   `user_id` int,
   `follower_id` int,
   
     constraint `fk_users_followers_users`
     foreign key (`user_id`)
     references `users` (`id`),
     
     constraint `fk_users_followers_follower`
     foreign key (`follower_id`)
     references `users` (`id`)
);

-- 2. Insert
insert into comments(content, user_id, post_id)
select concat('Omg!', u.username, '!This is so cool!'),
       ceil(p.id * 3 / 2),
       p.id
from posts p
         join users u on p.user_id = u.id
where p.id between 1 and 10;

INSERT INTO `comments` (`content`, `user_id`, `post_id`) 
(
select concat('Omg!', u.`username`, '!This is so cool!'),
       ceil(p.`id` * 3 / 2),
       p.`id`
from `posts` as `p`
join `users` as `u` on p.`user_id` = u.`id`
where p.id between 1 and 10
);

-- 3. Update

update `users` as `u`
set u.profile_picture_id =  if((select count(*) from `users_followers` as `uf` where uf.follower_id = u.id) > 0, (select count(*) from `users_followers` as `uf` where uf.follower_id = u.id), u.id)
where u.profile_picture_id is null;

-- 4. Delete

delete `u` from `users` as `u`
left join `users_followers` as `uf` on u.id = uf.user_id
WHERE uf.follower_id is null;

-- 5. Users

select id, username from `users`
order by id asc;

-- 6. Cheaters

select u.id, u.username from `users` as u
join `users_followers` as uf on uf.user_id = u.id
where uf.follower_id = uf.user_id
order by id asc; 

-- 7. High Quality Pictures

select id, `path`, size from `pictures`
where size > 50000 and (`path` like '%jpeg' or `path` like '%png')
order by size desc;

-- 8. Comments and Users

select c.`id`, concat(u.`username` ,' : ', c.`content`) as `full_comment` from `comments` as `c`
join `users` as `u` on u.id = c.user_id
order by c.id desc;

-- 9. Profile Pictures

select u.id, u.username, concat(p.`size`, 'KB') from `users` as `u`
join `pictures` AS `p` on u.profile_picture_id = p.id
join (select profile_picture_id from `users` group by profile_picture_id having count(*) > 1) as `u1`
where u1.profile_picture_id = u.profile_picture_id
order by u.id asc;

-- 10. Spam Posts

select p.id, p.caption, count(c.id) as `comments` from `posts` as `p`
left join `comments` as `c` on  c.post_id = p.id
group by p.id
order by `comments` desc, p.`id` asc limit 5;

-- 11. Most Popular User

select u.id,
	   u.username, 
       (select count(p.id) from `posts` as p where p.user_id = uf.user_id) as `posts`,
       count(uf.follower_id) as `followers`
from `users` as `u`
join `users_followers` as `uf` on uf.user_id = u.id
group by u.id
order by followers desc limit 1;

-- 12. Commenting Myself

select u.id, u.username, count(p.user_id) as `my_comments` from `users` as `u`
join `posts` as `p` on p.user_id = u.id
join `comments` as `c` on c.user_id = u.id
where c.post_id = p.id
group by u.id
order by `my_comments` desc, u.id asc;

-- 13. User Top Posts
                    
select u.id, u.username,  (select p.caption from posts p 
                           left join comments c on p.id = c.post_id
                           where u.id = p.user_id
                           group by p.id
                           order by count(c.id) desc, p.id limit 1) as `post` from `users` as `u`
right join `posts` as `p` on p.user_id = u.id
left join `comments` as `c` on p.id = c.post_id
group by u.id
order by u.id;

-- 14. Posts and Commentators

SELECT p.`id`, p.`caption`, count(c.user_id) as `users` from `posts` as p
left join `comments` as `c` on c.post_id = p.id
group by c.post_id
order by `users` desc, p.id asc;

-- 15. Post

DELIMITER &&
CREATE PROCEDURE udp_commit(
	`username` VARCHAR(30),
	`password` VARCHAR(30), 
	`caption` VARCHAR(255), 
	`path` VARCHAR(255))
BEGIN
	DECLARE `user_id` INT(11);
    DECLARE `picture_id` INT(11);

	IF ((SELECT u.`password` FROM `users` AS `u` WHERE u.`username` = `username`) <> `password`)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Password is incorrect!';
    ELSEIF ((SELECT COUNT(p.`id`) FROM `pictures` AS `p` WHERE p.`path` = `path`)) = 0
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The picture does not exist!';
	ELSE 
    SET `user_id` := (
		SELECT `id`
		FROM `users` AS `u`
		WHERE u.`username` = `username` 
	);
    
    SET `picture_id` := (
		SELECT p.`id`
		FROM `pictures` AS `p`
		WHERE p.`path` = `path` 
	);
    
    INSERT INTO `posts` (`caption`, `user_id`, `picture_id`)
    VALUES (`caption`, `user_id`, `picture_id`);
END IF;
    
END
&&