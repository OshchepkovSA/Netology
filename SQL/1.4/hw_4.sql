--=============== ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� �������� ����� ������� � �������:
--�������_�������, 
--���� ����������� � ���������� ��� ���������� �������, �� �������� ����� ����� � � ��� �������� �������.

create schema lecture_4_oshchepkov 

-- ������������� ���� ������ ��� ��������� ���������:
-- 1. ���� (� ������ ����������, ����������� � ��)
-- 2. ���������� (� ������ �������, ���������� � ��)
-- 3. ������ (� ������ ������, �������� � ��)


--������� ���������:
-- �� ����� ����� ����� �������� ��������� �����������
-- ���� ���������� ����� ������� � ��������� �����
-- ������ ������ ����� �������� �� ���������� �����������

 
--���������� � ��������-������������:
-- ������������� �������� ������ ������������� ���������������
-- ������������ ��������� �� ������ ��������� null �������� � �� ������ ����������� ��������� � ��������� ���������
 
--�������� ������� �����
create table IF NOT EXISTS lecture_4_oshchepkov."language" (
	language_ID serial not null,
	language_name varchar(50) unique not null,
	CONSTRAINT language_pkey PRIMARY KEY (language_ID)
)


--�������� ������ � ������� �����
insert into lecture_4_oshchepkov."language" (language_name)
	values ('����������'), ('�����������')
	


--�������� ������� ����������
create table IF NOT EXISTS lecture_4_oshchepkov.nation (
	nation_ID serial not null,
	nation_name varchar(50) unique not null,
	CONSTRAINT nation_pkey PRIMARY KEY (nation_ID)

)


--�������� ������ � ������� ����������
insert into lecture_4_oshchepkov.nation (nation_name)
	values ('�������'), ('����������'), ('��������')

select * from lecture_4_oshchepkov.nation

--�������� ������� ������
create table IF NOT EXISTS lecture_4_oshchepkov.country (
	country_ID serial not null,
	country_name varchar(50) unique not null,
	CONSTRAINT country_pkey PRIMARY KEY (country_ID)
)


--�������� ������ � ������� ������
insert into lecture_4_oshchepkov.country (country_name)
	values ('������'), ('��������')

	select * from lecture_4_oshchepkov."language"

--�������� ������ ������� �� �������
create table lecture_4_oshchepkov.language_nation (
		language_ID integer not null,
		nation_ID integer  not null,
		CONSTRAINT language_nation_pkey PRIMARY KEY (language_ID, nation_ID),
		CONSTRAINT language_nation_language_ID_fkey FOREIGN KEY (language_ID) REFERENCES lecture_4_oshchepkov."language" (language_ID),
		CONSTRAINT language_nation_nation_ID_fkey FOREIGN KEY (nation_ID) REFERENCES lecture_4_oshchepkov.nation (nation_ID)
)



--�������� ������ � ������� �� �������
insert into lecture_4_oshchepkov.language_nation (language_ID, nation_ID)
	values 	(1, 1),
			(1, 2),
			(1, 3),
			(2, 1),
			(2, 2),
			(2, 3)

select * from lecture_4_oshchepkov.language_nation

--�������� ������ ������� �� �������
create table lecture_4_oshchepkov.nation_country (
		nation_ID integer  not null,
		country_ID integer  not null,
		CONSTRAINT nation_country_pkey PRIMARY KEY (nation_ID, country_ID),
		CONSTRAINT nation_country_country_ID_fkey FOREIGN KEY (country_ID) REFERENCES lecture_4_oshchepkov.country (country_ID),
		CONSTRAINT nation_country_nation_ID_fkey FOREIGN KEY (nation_ID) REFERENCES lecture_4_oshchepkov.nation (nation_ID)
)


--�������� ������ � ������� �� �������
insert into lecture_4_oshchepkov.nation_country (nation_ID, country_ID)
	values 	(1, 1),
			(1, 2),
			(2, 1),
			(2, 2),
			(3, 1),
			(3, 2)

select * from lecture_4_oshchepkov."language"
join lecture_4_oshchepkov.language_nation on lecture_4_oshchepkov.language_nation.language_ID = lecture_4_oshchepkov."language".language_ID
join lecture_4_oshchepkov.nation on lecture_4_oshchepkov.language_nation.nation_ID = lecture_4_oshchepkov.nation.nation_ID
join lecture_4_oshchepkov.nation_country on lecture_4_oshchepkov.nation_country.nation_ID = lecture_4_oshchepkov.nation.nation_ID
join lecture_4_oshchepkov.country on lecture_4_oshchepkov.nation_country.country_ID = lecture_4_oshchepkov.country.country_ID
			
			
--======== �������������� ����� ==============


--������� �1 
--�������� ����� ������� film_new �� ���������� ������:
--�   	film_name - �������� ������ - ��� ������ varchar(255) � ����������� not null
--�   	film_year - ��� ������� ������ - ��� ������ integer, �������, ��� �������� ������ ���� ������ 0
--�   	film_rental_rate - ��������� ������ ������ - ��� ������ numeric(4,2), �������� �� ��������� 0.99
--�   	film_duration - ������������ ������ � ������� - ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0
--���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

create table lecture_4_oshchepkov.film_new (
	film_name varchar (255) not null,
	film_year integer check (film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check (film_duration > 0)
)



--������� �2 
--��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
--�       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--�       film_year - array[1994, 1999, 1985, 1994, 1993]
--�       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--�   	  film_duration - array[142, 189, 116, 142, 195]
insert into lecture_4_oshchepkov.film_new (film_name, film_year, film_rental_rate,  film_duration)
values  	('The Shawshank Redemption', 1994, 2.99, 142),
			('The Green Mile', 1999, 0.99, 189), 
			('Back to the Future', 1985, 1.99, 116), 
			('Forrest Gump', 1994, 2.99, 142), 
			('Schindlers List', 1993, 3.99, 195)
	    

--������� �3
--�������� ��������� ������ ������� � ������� film_new � ������ ����������, 
--��� ��������� ������ ���� ������� ��������� �� 1.41
update lecture_4_oshchepkov.film_new
set film_rental_rate = film_rental_rate + 1.41


--������� �4
--����� � ��������� "Back to the Future" ��� ���� � ������, 
--������� ������ � ���� ������� �� ������� film_new
delete from lecture_4_oshchepkov.film_new
where film_name = 'Back to the Future'


--������� �5
--�������� � ������� film_new ������ � ����� ������ ����� ������
insert into lecture_4_oshchepkov.film_new (film_name, film_year, film_rental_rate,  film_duration)
values  	('Hello, world!', 1994, 2.99, 142)


--������� �6
--�������� SQL-������, ������� ������� ��� ������� �� ������� film_new, 
--� ����� ����� ����������� ������� "������������ ������ � �����", ���������� �� �������
select *, round(film_duration/60::numeric, 1) from lecture_4_oshchepkov.film_new


--������� �7 
--������� ������� film_new
drop table lecture_4_oshchepkov.film_new
