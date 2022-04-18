--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаете новые таблицы в формате:
--таблица_фамилия, 
--если подключение к контейнеру или локальному серверу, то создаете новую схему и в ней создаете таблицы.

create schema lecture_4_oshchepkov 

-- Спроектируйте базу данных для следующих сущностей:
-- 1. язык (в смысле английский, французский и тп)
-- 2. народность (в смысле славяне, англосаксы и тп)
-- 3. страны (в смысле Россия, Германия и тп)


--Правила следующие:
-- на одном языке может говорить несколько народностей
-- одна народность может входить в несколько стран
-- каждая страна может состоять из нескольких народностей

 
--Требования к таблицам-справочникам:
-- идентификатор сущности должен присваиваться автоинкрементом
-- наименования сущностей не должны содержать null значения и не должны допускаться дубликаты в названиях сущностей
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table IF NOT EXISTS lecture_4_oshchepkov."language" (
	language_ID serial not null,
	language_name varchar(50) unique not null,
	CONSTRAINT language_pkey PRIMARY KEY (language_ID)
)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
insert into lecture_4_oshchepkov."language" (language_name)
	values ('английский'), ('французский')
	


--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
create table IF NOT EXISTS lecture_4_oshchepkov.nation (
	nation_ID serial not null,
	nation_name varchar(50) unique not null,
	CONSTRAINT nation_pkey PRIMARY KEY (nation_ID)

)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
insert into lecture_4_oshchepkov.nation (nation_name)
	values ('славяне'), ('англосаксы'), ('французы')

select * from lecture_4_oshchepkov.nation

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table IF NOT EXISTS lecture_4_oshchepkov.country (
	country_ID serial not null,
	country_name varchar(50) unique not null,
	CONSTRAINT country_pkey PRIMARY KEY (country_ID)
)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
insert into lecture_4_oshchepkov.country (country_name)
	values ('Россия'), ('Германия')

	select * from lecture_4_oshchepkov."language"

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table lecture_4_oshchepkov.language_nation (
		language_ID integer not null,
		nation_ID integer  not null,
		CONSTRAINT language_nation_pkey PRIMARY KEY (language_ID, nation_ID),
		CONSTRAINT language_nation_language_ID_fkey FOREIGN KEY (language_ID) REFERENCES lecture_4_oshchepkov."language" (language_ID),
		CONSTRAINT language_nation_nation_ID_fkey FOREIGN KEY (nation_ID) REFERENCES lecture_4_oshchepkov.nation (nation_ID)
)



--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into lecture_4_oshchepkov.language_nation (language_ID, nation_ID)
	values 	(1, 1),
			(1, 2),
			(1, 3),
			(2, 1),
			(2, 2),
			(2, 3)

select * from lecture_4_oshchepkov.language_nation

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table lecture_4_oshchepkov.nation_country (
		nation_ID integer  not null,
		country_ID integer  not null,
		CONSTRAINT nation_country_pkey PRIMARY KEY (nation_ID, country_ID),
		CONSTRAINT nation_country_country_ID_fkey FOREIGN KEY (country_ID) REFERENCES lecture_4_oshchepkov.country (country_ID),
		CONSTRAINT nation_country_nation_ID_fkey FOREIGN KEY (nation_ID) REFERENCES lecture_4_oshchepkov.nation (nation_ID)
)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
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
			
			
--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table lecture_4_oshchepkov.film_new (
	film_name varchar (255) not null,
	film_year integer check (film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check (film_duration > 0)
)



--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]
insert into lecture_4_oshchepkov.film_new (film_name, film_year, film_rental_rate,  film_duration)
values  	('The Shawshank Redemption', 1994, 2.99, 142),
			('The Green Mile', 1999, 0.99, 189), 
			('Back to the Future', 1985, 1.99, 116), 
			('Forrest Gump', 1994, 2.99, 142), 
			('Schindlers List', 1993, 3.99, 195)
	    

--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41
update lecture_4_oshchepkov.film_new
set film_rental_rate = film_rental_rate + 1.41


--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new
delete from lecture_4_oshchepkov.film_new
where film_name = 'Back to the Future'


--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме
insert into lecture_4_oshchepkov.film_new (film_name, film_year, film_rental_rate,  film_duration)
values  	('Hello, world!', 1994, 2.99, 142)


--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых
select *, round(film_duration/60::numeric, 1) from lecture_4_oshchepkov.film_new


--ЗАДАНИЕ №7 
--Удалите таблицу film_new
drop table lecture_4_oshchepkov.film_new
