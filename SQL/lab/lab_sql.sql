--1. Рассчитайте совокупный доход всех магазинов на каждую дату.
select 	p.staff_id 
		, p.payment_date ::date		
		, sum(p.amount)
from payment p
group by p.staff_id, p.payment_date::date
order by p.staff_id, p.payment_date::date 

--2. Выведите наиболее и наименее востребованные жанры
--(те, которые арендовали наибольшее/наименьшее количество раз),
--число их общих продаж и сумму дохода/
(select distinct 	c.category_id
		, c."name"
		, count(1) over(partition by c.category_id)  as pop_r
		, sum(p.amount) over (partition by c.category_id) 
from rental r  
join inventory i on r.inventory_id = i.inventory_id 
join film f on f.film_id = i.film_id 
join film_category fc on fc.film_id = f.film_id 
join category c on fc.category_id = c.category_id  
join payment p on r.rental_id = p.rental_id 
order by pop_r
limit 1)
union
(select distinct 	c.category_id
		, c."name"
		, count(1) over(partition by c.category_id)  as pop_r
		, sum(p.amount) over (partition by c.category_id) 
from rental r  
join inventory i on r.inventory_id = i.inventory_id 
join film f on f.film_id = i.film_id 
join film_category fc on fc.film_id = f.film_id 
join category c on fc.category_id = c.category_id  
left join payment p on r.rental_id = p.rental_id 
order by pop_r desc
limit 1)

--3. Какова средняя арендная ставка для каждого жанра?
--(упорядочить по убыванию, среднее значение округлить до сотых)
select 	c."name"
		, round(avg(f.rental_rate/f.rental_duration)::numeric, 2) as avr 
from film f 
join film_category fc on fc.film_id = f.film_id 
join category c on fc.category_id = c.category_id  
group by c.category_id 
order by avr desc

--4. Составить список из 5 самых дорогих клиентов (арендовавших фильмы с 10 по 13 апреля).
--формат списка:
--'Имя_клиента Фамилия_клиента email address is: e-mail_клиента'
with cte as (select p.customer_id, sum(p.amount) from payment p 
where p.payment_date between '2007-04-10' and '2007-04-13'
group by p.customer_id
order by sum desc
limit 5)
select concat(c1.first_name, ' ', c1.last_name, ' email address is: ', c1.email), c.sum from cte c
join customer c1 on c.customer_id = c1.customer_id
order by c.sum desc

--5. Сколько арендованных фильмов было возвращено в срок, до срока возврата и после, выведите максимальную разницу со сроком?
select 	r.rental_id
		, r.rental_date ::date
		, r.return_date ::date
		, f.rental_duration 
		, r.return_date::date - r.rental_date::date
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
where extract ('day' from r.return_date - r.rental_date) = f.rental_duration

select 	r.rental_id
		, r.rental_date ::date
		, r.return_date ::date
		, f.rental_duration 
		, r.return_date::date - r.rental_date::date
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
where extract ('day' from r.return_date - r.rental_date) < f.rental_duration

select 	r.rental_id
		, r.rental_date 
		, r.return_date 
		, f.rental_duration
		, r.return_date::date - r.rental_date::date
		, extract ('day' from r.return_date - r.rental_date) - f.rental_duration as a
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
where extract ('day' from r.return_date - r.rental_date) > f.rental_duration
order by a desc


