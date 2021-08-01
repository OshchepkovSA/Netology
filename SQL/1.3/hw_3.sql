--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.
select 	c.last_name ||' '||c.first_name as "������� � ���",
		a.address as "�����", 
		c2.city as "�����", 
		c3.country as "������" 
from customer c 
inner join address a on c.address_id = a.address_id 
inner join city c2 on c2.city_id = a.city_id
inner join country c3 on c3.country_id = c2.country_id

--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.
select 	c.store_id as "ID ��������", 
		count(c.customer_id) as "���������� �����������" 
from customer c 
group by c.store_id 

--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.
select 	c.store_id as "ID ��������", 
		count(c.customer_id) as "���������� �����������" 
from customer c 
group by c.store_id 
having count(c.customer_id) > 300 

-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.
select 	c.store_id as "ID ��������",
		count(c.customer_id) as "���������� �����������",
	 	city.city as "����� ��������",
	 	staff.last_name||' '||staff.first_name as "��� ��������"
from customer c 
join store s using(store_id) 
join address a on a.address_id = s.address_id 
join city on city.city_id = a.city_id 
join staff on staff.store_id = s.store_id
group by c.store_id, city.city, staff.first_name, staff.last_name 
having count(c.customer_id) > 300 

--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������
select 	c.last_name||' '||c.first_name as "����������",
		count(r.rental_id) as "���������� �������"
from  rental r
join customer c  on r.customer_id = c.customer_id 
group by c.customer_id 
order by "���������� �������" desc 
limit 5 

--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������
select 	c.last_name||' '||c.first_name as "����������",
		count(r.rental_id) as "���������� �������",
		sum(p.amount)::int as "����� ��������� ��������",
		min(p.amount) as "����������� �������� �������",
		max(p.amount) as "������������ �������� �������"
from rental r
join customer c on r.customer_id = c.customer_id 
join payment p on p.rental_id = r.rental_id 
--where c.last_name = 'Lovelace' or c.last_name = 'Soto' or c.last_name = 'Oglesby'
group by c.customer_id 
--order by "���������� �������" desc 

--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.
 select c.city "����� 1", c2.city "����� 2" from city c 
 cross join city c2 
 where c.city != c2.city 

--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.
  select 	c.customer_id "ID ����������", 
	 		round(avg(r.return_date::date-r.rental_date::date), 2)
	 		from rental r 
 join customer c on r.customer_id = c.customer_id 
 group by c.customer_id 
 order by c.customer_id 
  
--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.
-- explain analyse 
 select 	f.title "��������",
		f.rating "�������",
		c."name" "����",
		f.release_year "��� �������", 
		l."name" "����", 
		count(r.rental_id) "���������� �����",
		sum(p.amount)::numeric "����� ��������� ������"
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on f.film_id = i.film_id 
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id 
join "language" l on l.language_id  = f.language_id  
join payment p on p.rental_id = r.rental_id 
group by i.film_id, f.title, f.rating, c."name", f.release_year, l."name"

--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.
select 	f.title "��������",
		f.rating "�������",
		c."name" "����",
		f.release_year "��� �������", 
		l."name" "����", 
		count(r.rental_id) "���������� �����"
,		sum(p.amount)::numeric "����� ��������� ������" 
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

--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".
select 	p.staff_id "ID ����������",
		count(p.payment_id) "���������� ������",
		case when count(p.payment_id)> 7300 then '��'
		else '���' end "������"
from payment p 
group by p.staff_id 

