--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия регионов из таблицы адресов
select distinct a.district from address a 
order by a.district 

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те регионы, 
--названия которых начинаются на "K" и заканчиваются на "a", и названия не содержат пробелов
select distinct a.district from address a 
where a.district ilike 'k%' and  a.district ilike '%a' and not a.district ilike '% %'
order by a.district 

--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 марта 2007 года по 19 марта 2007 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.
select p.payment_id, p.payment_date, p.amount from payment p 
where 	p.amount > 1.00 
		and date_trunc('day', p.payment_date) >='2007-03-17'
		and date_trunc('day', p.payment_date) <='2007-03-19'
order by p.payment_date 

--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
SELECT p.payment_id, p.payment_date, p.amount 
FROM  payment p
ORDER BY payment_date DESC 
LIMIT 10

--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.
select 	c.first_name ||' '||  c.last_name as "Фаимлия и имя", 
		c.email as "Электронная почта", 
		char_length(c.email) as "Длина Email",
		c.last_update :: date as "Дата"
from customer c 

--ЗАДАНИЕ №6
--Выведите одним запросом активных покупателей, имена которых Kelly или Willie.
--Все буквы в фамилии и имени из нижнего регистра должны быть переведены в высокий регистр.
select upper(c.last_name), upper(c.first_name) from customer c 
where c.activebool = true and (c.first_name ilike 'kelly' or c.first_name ilike 'willie')

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.
select f.film_id, f.title, f.description, f.rating, f.rental_rate from film f 
where 	(f.rating = 'R'	and f.rental_rate between 0.00 and 3.00)
		or (f.rating = 'PG-13'	and f.rental_rate >= 4.00)

--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.
select f.film_id, f.title, f.description from film f 
order by char_length(f.description) DESC
limit 3

--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.
select 	c.customer_id, 
		c.email, 
		substring(c.email from 1 for position('@' in c.email)-1) as "Email before @", 
		substring(c.email from position('@' in c.email)+1 for length(c.email)) as "Email after @" 
from customer c 
order by c.customer_id 

--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.
select 	c.customer_id, 
		c.email, 
		upper(substring(c.email from 1 for 1))||substring(c.email from 2 for position('@' in c.email)-2) as "Email before @", 
		upper(substring(c.email from position('@' in c.email)+1 for 1))||substring(c.email from position('@' in c.email)+2 for length(c.email)) as "Email after @" 
from customer c 
order by c.customer_id 
