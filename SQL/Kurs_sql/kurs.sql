 SET search_path = bookings, public;

--В каких городах больше одного аэропорта?
SELECT 	a.airport_code as code,
		a.airport_name,
		a.city,
		a.longitude,
		a.latitude
FROM airports a
WHERE a.city in (
 SELECT aa.city
 FROM airports aa
 GROUP BY aa.city
 HAVING COUNT(aa.city) > 1
 )
ORDER BY a.city, code;

--В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
--- Подзапрос
select 
		a2.airport_code  as code, 
		a2.airport_name
from flights f 
join airports a2 on (f.departure_airport = a2.airport_code) --or (f.arrival_airport = a2.airport_code)
where f.aircraft_code = (select a.aircraft_code from aircrafts a
						order by a.range desc
						limit 1
						)
group by a2.airport_code						
					
-- Вывести 10 рейсов с максимальным временем задержки вылета
--- Оператор LIMIT
select 	f.flight_id 
		, f.actual_departure
		,  f.scheduled_departure
		, (f.actual_departure - f.scheduled_departure) delay 
from flights f
where f.actual_departure is not null
order by delay desc
limit  10

-- Были ли брони, по которым не были получены посадочные талоны?
--- Верный тип JOIN
select 	b.book_ref "Номер брони (талон не получен)"
from bookings b 
join tickets t on t.book_ref = b.book_ref 
join ticket_flights tf on tf.ticket_no = t.ticket_no 
left join boarding_passes bp on tf.ticket_no = bp.ticket_no and bp.flight_id = tf.flight_id 
where bp.boarding_no is null
group by b.book_ref

--Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров 
--из каждого аэропорта на каждый день. Т.е. в этом столбце должна отражаться накопительная сумма - 
--сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
--- Оконная функция
--- Подзапросы
select 	f.flight_id
		, f.departure_airport as air_code
		, f.actual_departure::date "Время вылета, факт"
	--	, c.count
		, sum(c.count) over (partition by f.departure_airport order by f.actual_departure::date) "Накопительная сумма"
		, count(*) "Всего мест"
		, count(*) - c.count "Свободные места"
		, round((count(*)::numeric - c.count::numeric)/count(*)::numeric,4)*100 "Процент свободных мест"
from flights f
join seats s on f.aircraft_code = s.aircraft_code 
join 	(select tf.flight_id, count(*) --Количество занятых мест
		from ticket_flights tf
		group by tf.flight_id
		) as c on f.flight_id = c.flight_id
where f.status = 'Arrived' or f.status = 'Departed'
group by f.flight_id, c.count, f.departure_airport 
order by f.departure_airport , f.actual_departure 

--Найдите процентное соотношение перелетов по типам самолетов от общего количества.
--- Подзапрос
--- Оператор ROUND
with sum_full (aircraft_code, sf) as 
	(select 	f.aircraft_code,
				sum(round(count(f.flight_id)::numeric/(select count(f.flight_id) from flights f)::numeric*100,2)) over()
				from flights f 
				group by f.aircraft_code ),
	sum_per (aircraft_code, sp) as 
	(select 	f.aircraft_code,
				round(count(f.flight_id)::numeric/(select count(f.flight_id) from flights f)::numeric*100,2)
				from flights f 
				group by f.aircraft_code )
select 	f.aircraft_code,
		count(f.flight_id),
		sum (count(f.flight_id)) over(),
		case 	when f.aircraft_code = first_value (f.aircraft_code) over() then 
				sum_per.sp+	case 	when sum_full.sf-100.>0. then 100-sum_full.sf
									when sum_full.sf-100.<0. then sum_full.sf-100
							else 0
							end
		else sum_per.sp 	
		end
from flights f 
join sum_full on f.aircraft_code = sum_full.aircraft_code
join sum_per on f.aircraft_code = sum_per.aircraft_code
group by f.aircraft_code, sum_full.sf, sum_per.sp

--Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
--- CTE
with bus_am as (select 	tf.flight_id
						, tf.amount
from ticket_flights tf 
where tf.fare_conditions = 'Business'
group by tf.flight_id, tf.amount 
order by tf.flight_id
)
, eco_am as (select 	tf.flight_id
						, tf.amount 
from ticket_flights tf 
where tf.fare_conditions = 'Economy'
group by tf.flight_id, tf.amount 
order by tf.flight_id
)
select 	tf.flight_id
		, bus_am.amount as Business_amount
		, eco_am.amount as Economy_amount
		, a.city 
from ticket_flights tf
join bus_am on tf.flight_id = bus_am.flight_id
join eco_am on tf.flight_id = eco_am.flight_id
join flights f on tf.flight_id = f.flight_id 
join airports a on f.departure_airport = a.airport_code 
where bus_am.amount < eco_am.amount
group by tf.flight_id , bus_am.amount, eco_am.amount, a.city

--Между какими городами нет прямых рейсов?
--- Декартово произведение в предложении FROM
--- Самостоятельно созданные представления
--- Оператор EXCEPT
create materialized view 
not_flight as 
		select  a.airport_code as departure --cross join airports
				, a2.airport_code as arrival
		from airports a, airports a2 
		where a.airport_code != a2.airport_code
		except 
		select f.arrival_airport, f.departure_airport  -- all direct flights
		from flights f
with data

select 	nf.arrival
		, nf.departure
		, a.city city_arr
		, a1.city city_dep
from not_flight nf 
join airports a on nf.arrival = a.airport_code 
join airports a1 on nf.departure = a1.airport_code

--Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной 
--дальностью перелетов  в самолетах, обслуживающих эти рейсы *
--- Оператор RADIANS или использование sind/cosd
/* * - В облачной базе координаты находятся в столбце airports_data.coordinates - работаете, как с массивом. В локальной базе координаты находятся в столбцах airports.longitude и airports.latitude.
Кратчайшее расстояние между двумя точками A и B на земной поверхности (если принять ее за сферу) определяется зависимостью:
d = arccos {sin(latitude_a)•sin(latitude_b) + cos(latitude_a)•cos(latitude_b)•cos(longitude_a - longitude_b)}, где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы данных пунктов, d — расстояние между пунктами измеряется в радианах длиной дуги большого круга земного шара.
Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
L = d•R, где R = 6371 км — средний радиус земного шара.*/
select  f.departure_airport
		, f.arrival_airport
		, a.aircraft_code
		, a.range range_aircraft
		--, a2.longitude longitude_a
		--, a3.longitude longitude_b
		--, acos(sind(a2.latitude)*sind(a3.latitude)+cosd(a2.latitude)*cosd(a3.latitude)*cosd(a2.longitude - a3.longitude))
		, round(6371*acos(sind(a2.latitude)*sind(a3.latitude)+cosd(a2.latitude)*cosd(a3.latitude)*cosd(a2.longitude - a3.longitude))) as distance
		, a.range - round(6371*acos(sind(a2.latitude)*sind(a3.latitude)+cosd(a2.latitude)*cosd(a3.latitude)*cosd(a2.longitude - a3.longitude))) as delta 
from flights f
join aircrafts a on f.aircraft_code = a.aircraft_code 
join airports a2 on f.arrival_airport = a2.airport_code 
join airports a3 on f.departure_airport = a3.airport_code
group by f.arrival_airport, f.departure_airport, a.aircraft_code, a2.airport_code, a3.airport_code
					