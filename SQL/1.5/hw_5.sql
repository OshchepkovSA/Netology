--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--C������� ������ � ������� payment. 
--������������ ��� ������� �� 1 �� N �� ���� �������.
select p.payment_id 
, p.payment_date
, row_number() over (order by p.payment_date) as ID
FROM payment p 
order by ID 




--������� �2
--��������� ������� ������� �������� ������� � ���������� �������
--������� ��� ������� ����������,
--���������� �������� ������ ���� �� ���� �������.
select  p.payment_id 
		, p.payment_date 
		, p.customer_id
	, row_number () over (partition by p.customer_id order by p.payment_date)
from payment p 




--������� �3
--��� ������� ������������ ���������� ����������� ������ ����� ���� ��� ��������,
--���������� �������� ������ ���� �� ���� �������.
select p.customer_id
	, p.payment_id 
	, p.payment_date 
	, p.amount
	, sum (p.amount) over (partition by p.customer_id order by p.payment_date)
	--, sum(p.amount) over (partition by p.customer_id order by p.payment_date rows between unbounded preceding and current row)
from payment p 
group by p.payment_id 
order by p.customer_id, p.payment_date 




--������� �4
--��� ������� ���������� �������� ������ � ��� ��������� ������ ������.
select p.customer_id 
			, p.payment_id 
			, p.payment_date
			, p.amount 
from (
	select  p.customer_id 
			, p.payment_id 
			, p.payment_date
			, p.amount 
			, row_number () over (partition by p.customer_id order by p.payment_date desc)
	from payment p
	order by p.customer_id, p.payment_date desc
	) as p
where row_number = 1


--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ��������
--��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0
--� ����������� �� ���� �������
select 	s.staff_id
		, p.payment_id
		, p.payment_date
		, p.amount 
		, coalesce (lag (p.amount, 1) over(partition by s.staff_id order by p.payment_date), 0) as last_amount
from staff s 
join payment p on s.staff_id = p.staff_id 
order by s.staff_id, p.payment_date 


--������� �2
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ���� 2007 ����
--� ����������� ������ �� ������� ���������� � �� ������ ���� ������� (���� ��� ����� �������)
--� ����������� �� ���� �������
--explain analyse 
select 	fish.staff_id
		, fish.payment_date
		, sum(fish.amount) as sum_amount
		, fish.sum
from 	(
		select 	 s.staff_id 
				, p.payment_date :: date 
				, p.amount 
				, sum (p.amount) over(partition by s.staff_id order by date_trunc('day', p.payment_date)) as sum
		from staff s 
		join payment p on s.staff_id = p.staff_id
		where  p.payment_date between '2007-03-01' and '2007-03-31'
		order by s.staff_id 
		) as fish
group by fish.payment_date, fish.staff_id, fish.sum
order by fish.staff_id, fish.payment_date


--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
-- 1. ����������, ������������ ���������� ���������� �������
-- 2. ����������, ������������ ������� �� ����� ������� �����
-- 3. ����������, ������� ��������� ��������� �����
--explain analyse 
with cte as (
		select 	c.country
				, c3.customer_id 
				, c3.first_name 
				, c3.last_name 
		from country c 
		join city c2 on c.country_id = c2.country_id 
		join address a on c2.city_id = a.city_id 
		join customer c3 on a.address_id = c3.address_id
		order by c.country 
		),
	cte_mr as (
		select 	c.country
				, c.first_name
				, c.last_name
				, row_number() over(partition by c.country) rn
		from (
			select 	distinct c.*
					, count (r.rental_id) over (partition by c.customer_id) as mr
			from cte c
			join rental r on c.customer_id = r.customer_id
			order by c.country, mr desc) as c
		),
	cte_mp as (
		select 	c.country
				, c.first_name
				, c.last_name
				, row_number() over(partition by c.country) rn
		from (
			select 	distinct	c.*
					, sum(p.amount) over (partition by c.customer_id order by c.country desc) as mp
			from cte c
			join payment p on c.customer_id = p.customer_id 
			order by c.country, mp desc) as c
		),
	cte_md as (
		select 	c.country
				, c.first_name
				, c.last_name
				, row_number() over(partition by c.country) rn
		from (
			select 	distinct c.*
					, r.rental_date 
					, max(r.rental_date) over (partition by c.customer_id ) as md
			from cte c
			join rental r on c.customer_id = r.customer_id
			order by c.country, md desc) as c
		)
	select 	mr.country
			, mr.first_name||' '||mr.last_name
			, mp.first_name||' '||mp.last_name
			, md.first_name||' '||md.last_name
	from cte_mr mr
	join cte_mp mp on mr.country = mp.country
	join cte_md md on mr.country = md.country
	where mr.rn = 1 and mp.rn = 1 and md.rn = 1 
		

	