--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select 	c.last_name ||' '||c.first_name as "Фамилия и имя",
		a.address as "Адрес", 
		c2.city as "Город", 
		c3.country as "Страна" 
from customer c 
inner join address a on c.address_id = a.address_id 
inner join city c2 on c2.city_id = a.city_id
inner join country c3 on c3.country_id = c2.country_id

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select 	c.store_id as "ID магазина", 
		count(c.customer_id) as "Количество покупателей" 
from customer c 
group by c.store_id 

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select 	c.store_id as "ID магазина", 
		count(c.customer_id) as "Количество покупателей" 
from customer c 
group by c.store_id 
having count(c.customer_id) > 300 

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select 	c.store_id as "ID магазина",
		count(c.customer_id) as "Количество покупателей",
	 	city.city as "Город магазина",
	 	staff.last_name||' '||staff.first_name as "ФИО продавца"
from customer c 
join store s using(store_id) 
join address a on a.address_id = s.address_id 
join city on city.city_id = a.city_id 
join staff on staff.store_id = s.store_id
group by c.store_id, city.city, staff.first_name, staff.last_name 
having count(c.customer_id) > 300 

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select 	c.last_name||' '||c.first_name as "Покупатель",
		count(r.rental_id) as "Количество фильмов"
from  rental r
join customer c  on r.customer_id = c.customer_id 
group by c.customer_id 
order by "Количество фильмов" desc 
limit 5 

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select 	c.last_name||' '||c.first_name as "Покупатель",
		count(r.rental_id) as "Количество фильмов",
		sum(p.amount)::int as "Общая стоимость платежей",
		min(p.amount) as "Минимальное значение платежа",
		max(p.amount) as "Максимальное значение платежа"
from rental r
join customer c on r.customer_id = c.customer_id 
join payment p on p.rental_id = r.rental_id 
--where c.last_name = 'Lovelace' or c.last_name = 'Soto' or c.last_name = 'Oglesby'
group by c.customer_id 
--order by "Количество фильмов" desc 

--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 select c.city "Город 1", c2.city "Город 2" from city c 
 cross join city c2 
 where c.city != c2.city 

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
  select 	c.customer_id "ID покупателя", 
	 		round(avg(r.return_date::date-r.rental_date::date), 2)
	 		from rental r 
 join customer c on r.customer_id = c.customer_id 
 group by c.customer_id 
 order by c.customer_id 
  
--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
-- explain analyse 
 select 	f.title "Название",
		f.rating "Рейтинг",
		c."name" "Жанр",
		f.release_year "Год выпуска", 
		l."name" "Язык", 
		count(r.rental_id) "Количество аренд",
		sum(p.amount)::numeric "Общая стоимость аренды"
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on f.film_id = i.film_id 
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id 
join "language" l on l.language_id  = f.language_id  
join payment p on p.rental_id = r.rental_id 
group by i.film_id, f.title, f.rating, c."name", f.release_year, l."name"

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
select 	f.title "Название",
		f.rating "Рейтинг",
		c."name" "Жанр",
		f.release_year "Год выпуска", 
		l."name" "Язык", 
		count(r.rental_id) "Количество аренд"
,		sum(p.amount)::numeric "Общая стоимость аренды" 
from film f 
left join inventory i on i.film_id = f.film_id 
left join rental r on r.inventory_id = i.inventory_id 
left join film_category fc on f.film_id = fc.film_id
left join category c on fc.category_id = c.category_id 
left join "language" l on l.language_id  = f.language_id 
left join payment p on p.rental_id = r.rental_id 
where r.rental_id is null --f.title = 'Alice Fantasia'
group by f.film_id , f.title, c."name", f.rating, l."name"
having count(r.rental_id) = 0

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select 	p.staff_id "ID сотрудника",
		count(p.payment_id) "Количество продаж",
		case when count(p.payment_id)> 7300 then 'Да'
		else 'Нет' end "Премия"
from payment p 
group by p.staff_id 

