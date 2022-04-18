--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
explain analyze -- 92.25
select f.film_id, f.title, f.special_features from film f 
where f.special_features @> array['Behind the Scenes']
order by f.film_id 




--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
explain analyze --83.78
select 	f.film_id, f.title
		, f.special_features
from film f 
where array_position(f.special_features, 'Behind the Scenes') >0 
order by f.film_id 

explain analyze --92.25
select f.film_id, f.title, f.special_features from film f 
where f.special_features && array['Behind the Scenes']
order by f.film_id 




--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
explain analyze --939.58
with cte as (select f.film_id, f.title, f.special_features from film f 
where f.special_features && array['Behind the Scenes']
order by f.film_id )
select 	c.customer_id
		, count(1)
from 	customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
left join cte c1 on c1.film_id = f.film_id
where c1.film_id is not null
group by c.customer_id
order by c.customer_id 




--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.
explain analyze --939.58
select 	c.customer_id
		, count(1)
from customer c 
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
left join (select f.film_id, f.title, f.special_features from film f 
			where f.special_features && array['Behind the Scenes']
			order by f.film_id) c1 on c1.film_id = f.film_id
where c1.film_id is not null
group by c.customer_id
order by c.customer_id 


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view cust_beh as
(
select 	c.customer_id
		, count(1)
from customer c 
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
left join (select f.film_id, f.title, f.special_features from film f 
			where f.special_features && array['Behind the Scenes']
			order by f.film_id) c1 on c1.film_id = f.film_id
where c1.film_id is not null
group by c.customer_id
order by c.customer_id 
) with  data

refresh materialized view cust_beh




--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
В задаче 1 и 2  меньше ресурсов тратится при использовании функции array_position() - 83.78,
при применении методов @> и && результат показал - 92.25.
По скорости исполнения данных запросов разницы не заметил.

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
Разницы нет, результат одинаковый. Версия PostgreSQL 13.3, compiled by Visual C++ build 1914, 64-bit

 select version()




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии
explain analyze --8599.22
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

explain analyze --781.09
select 	c.first_name  || ' ' || c.last_name
		, count(1)
from customer c 
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
join (select 	f.film_id
		from film f 
		where array_position(f.special_features, 'Behind the Scenes') >0 
		) c1 on c1.film_id = f.film_id
group by c.customer_id
order by count(1) desc 

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
--explain analyze
select 	 s.staff_id
		 , f.film_id 
		 , f.title 
		 , s.payment_date
		 , s.amount
		 , c.last_name 
		 , c.first_name 
from
	(select p.staff_id
			, p.rental_id 
			, p.amount 
			, p.payment_date
			, row_number () over (partition by p.staff_id order by p.payment_date) as rn
	from payment p ) as s
join rental r on r.rental_id = s.rental_id 
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
join customer c on c.customer_id = r.customer_id 
where s.rn = 1


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

select p.store_id
	, r.rental_date 
	, r.count
	, p.payment_date 
	, p.sum
from (
select r_1.store_id
, r_1.payment_date
, r_1.sum
, row_number () over(partition by r_1.store_id order by r_1.sum)
from
	(select s2.store_id
	, p.payment_date:: date
	, sum(p.amount) 
	from payment p 
	join staff s on s.staff_id = p.staff_id 
	join store s2 on s2.manager_staff_id = s.staff_id 
	group by s2.store_id, p.payment_date::date) as r_1
order by row_number) p
join
(select r_1.store_id
, r_1.rental_date
, r_1.count
, row_number () over(partition by r_1.store_id order by r_1.count desc)
from
	(select s2.store_id
	, r.rental_date:: date
	, count(r.rental_id) 
	from rental r 
	join staff s on s.staff_id = r.staff_id 
	join store s2 on s2.manager_staff_id = s.staff_id 
	group by s2.store_id, r.rental_date::date) as r_1
order by row_number) r on r.store_id = p.store_id
where p.row_number=1 and r.row_number = 1
order by 1