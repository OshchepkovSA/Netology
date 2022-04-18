--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� �������� �� ������� �������
select distinct a.district from address a 
order by a.district 

--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� �������, 
--�������� ������� ���������� �� "K" � ������������� �� "a", � �������� �� �������� ��������
select distinct a.district from address a 
where a.district ilike 'k%' and  a.district ilike '%a' and not a.district ilike '% %'
order by a.district 

--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ����� 2007 ���� �� 19 ����� 2007 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.
select p.payment_id, p.payment_date, p.amount from payment p 
where 	p.amount > 1.00 
		and date_trunc('day', p.payment_date) >='2007-03-17'
		and date_trunc('day', p.payment_date) <='2007-03-19'
order by p.payment_date 

--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.
SELECT p.payment_id, p.payment_date, p.amount 
FROM  payment p
ORDER BY payment_date DESC 
LIMIT 10

--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.
select 	c.first_name ||' '||  c.last_name as "������� � ���", 
		c.email as "����������� �����", 
		char_length(c.email) as "����� Email",
		c.last_update :: date as "����"
from customer c 

--������� �6
--�������� ����� �������� �������� �����������, ����� ������� Kelly ��� Willie.
--��� ����� � ������� � ����� �� ������� �������� ������ ���� ���������� � ������� �������.
select upper(c.last_name), upper(c.first_name) from customer c 
where c.activebool = true and (c.first_name ilike 'kelly' or c.first_name ilike 'willie')

--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.
select f.film_id, f.title, f.description, f.rating, f.rental_rate from film f 
where 	(f.rating = 'R'	and f.rental_rate between 0.00 and 3.00)
		or (f.rating = 'PG-13'	and f.rental_rate >= 4.00)

--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.
select f.film_id, f.title, f.description from film f 
order by char_length(f.description) DESC
limit 3

--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.
select 	c.customer_id, 
		c.email, 
		substring(c.email from 1 for position('@' in c.email)-1) as "Email before @", 
		substring(c.email from position('@' in c.email)+1 for length(c.email)) as "Email after @" 
from customer c 
order by c.customer_id 

--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.
select 	c.customer_id, 
		c.email, 
		upper(substring(c.email from 1 for 1))||substring(c.email from 2 for position('@' in c.email)-2) as "Email before @", 
		upper(substring(c.email from position('@' in c.email)+1 for 1))||substring(c.email from position('@' in c.email)+2 for length(c.email)) as "Email after @" 
from customer c 
order by c.customer_id 
