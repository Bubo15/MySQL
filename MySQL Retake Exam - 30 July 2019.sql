-- 1. Table Design

create database `colonial_blog_db`;

create table `users` (
  `id` int primary key auto_increment,
  `username` varchar(30) not null unique,
  `password` varchar(30) not null,
  `email` varchar(50) not null
);

create table `categories` (
  `id` int primary key auto_increment,
  `category` varchar(30) not null
);

create table `articles`(
  `id` int primary key auto_increment,
  `title` varchar(50) not null,
  `content` text not null,
  `category_id` int,
  
  constraint `fk_articles_categories`
  foreign key (`category_id`)
  references `categories` (`id`)
);

create table `users_articles` (
  `user_id` int,
  `article_id` int,
  
  constraint `pk_user_article`
  primary key (`user_id`,`article_id`),
  
  constraint `fk_users_articles_users`
  foreign key (`user_id`)
  references `users` (`id`),
  
  constraint `fk_users_articles_articles`
  foreign key (`article_id`)
  references `articles` (`id`)
);

create table `comments` (
  `id` int primary key auto_increment,
  `comment` varchar(255) not null,
  `article_id` int not null,
  `user_id` int not null,
  
   constraint `fk_comments_articles`
   foreign key (`article_id`)
   references `articles` (`id`),
   
   constraint `fk_comments_users`
   foreign key (`user_id`)
   references `users` (`id`)
);

create table `likes` (
  `id` int primary key auto_increment,
  `article_id` int,
  `comment_id` int,
  `user_id` int not null,
  
   constraint `fk_likes_articles`
   foreign key (`article_id`)
   references `articles` (`id`),
   
   constraint `fk_likes_comments`
   foreign key (`comment_id`)
   references `comments` (`id`),
   
   constraint `fk_likes_users`
   foreign key (`user_id`)
   references `users` (`id`)
);

-- 2. INSERT

insert into `likes` (`article_id`, `comment_id`, `user_id`)
select if(u.id % 2 = 0, char_length(u.username), null), if(u.id % 2 <> 0, char_length(u.email), null), u.id from `users` as `u`
 where u.id between 16 and 20;
                         
-- 3. Update

update `comments`
set `comment` = (case 
				when id % 2 = 0 then 'Very good article.'		
				when id % 3 = 0 then 'This is interesting.'		
				when id % 5 = 0 then 'I definitely will read the article again.'	
				when id % 7 = 0 then 'The universe is such an amazing thing.'
                else 
                comment
                end)
where id between 1 and 15;

-- 4. Delete

delete `a` from `articles` as `a` where a.category_id is null;
                          
-- 5. Extract 3 biggest articles

select a.title,a.summary  from (select title, concat(substring(content, 1,20), '...') as `summary`, id from `articles`
			                   order by char_length(content) desc, id asc limit 3) as `a`
order by a.id asc;

-- 6. Golden articles

select a.id, a.title from `articles` as `a`
join `users` as `u`
join `users_articles` as `ua` on ua.user_id = u.id
where ua.article_id = a.id and u.id = a.id
group by a.id
order by a.id asc;

-- 7. Extract categories

select c.category, c.count_art as `articles`, count(l.id) as `likes` from (select c2.id as `id`,c2.category as `category` ,count(a2.category_id) as `count_art` from `articles` as `a2`
				                                                           join `categories` as `c2` on a2.category_id = c2.id
															               group by a2.category_id) as `c`
join `articles` as `a` on a.category_id = c.id
join `likes` as `l` on a.id = l.article_id
group by a.category_id
order by `likes` desc, `articles` desc, c.id asc;

-- 8. Extract the most commented social article

select a.title, count(c.article_id) as `comments` from `comments` as `c`
join `articles` as `a` on a.id = c.article_id
join `categories` as `ca` on ca.id = a.category_id
where ca.category = 'Social'
group by c.article_id
order by `comments` desc limit 1;

-- 9. Extract the less liked comments

select concat(substring(c.comment, 1,20), '...') as `summary` from `comments` as `c`
left join `likes` as `l` on l.comment_id = c.id
where l.comment_id is null
order by c.id desc;

-- 10. Get users articles count

DELIMITER &&
create function `udf_users_articles_count` (username VARCHAR(30))
returns int
begin
      declare res int;
      
     set res := (SELEct count(us.article_id) from `users_articles` as `us`
                 join `users` as `u` on u.id = us.user_id
                 where u.username = username);
				
	 return res;
end
&&

-- 
DELIMITER &&
create procedure udp_like_article(username VARCHAR(30), title VARCHAR(30))
begin
  declare name_id varchar(30);
  declare title_id varchar(30);
  start transaction;
	if((select count(u.id) from `users` as `u` where u.username = username) = 0) then
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Non-existent user.';
        rollback;
	elseif ((select count(a.id) from `articles` as `a` where a.title = title) = 0) then
       SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Non-existent article.';
        rollback;
	else 
    set name_id := (select u.id from `users` as `u`
                        where u.username = username); 
	set title_id := (select a.id from `articles` as `a`
                        where a.title = title);
    
    insert into `likes` (`article_id`, `comment_id`, `user_id`)
    value (title_id, null, name_id);
      commit;
	end if;
end
&&



CALL udp_like_article('BlaAntigadsa', 'Donnybrook, Victoria');
SELECT a.title, u.username 
FROM articles a 
JOIN likes l
ON a.id = l.article_id
JOIN users u
ON l.user_id = u.id
WHERE u.username = 'BlaAntigadsa' AND a.title = 'Donnybrook, Victoria';
