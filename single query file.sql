--1 Выведите название самолетов, которые имеют менее 50 посадочных мест.
select a.model, count(s.seat_no)
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code
group by model
having count(s.seat_no) < 50
/*model             |count|
------------------+-----+
Cessna 208 Caravan|   12|*/


--2 Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.
select date_trunc('month', book_date::date), sum(total_amount),
	lag(sum(total_amount),1) over (order by date_trunc('month',book_date::date)),
	round ((sum(total_amount) - lag(sum(total_amount),1) over (order by date_trunc('month', book_date::date)))/lag(sum(total_amount),1) over (order by date_trunc('month', book_date::date))*100, 2) as "%_изменение_ежемесячной_суммы"
from bookings
group by date_trunc('month', book_date::date)
order by 1;
/*date_trunc                   |sum           |lag           |%_изменение_ежемесячной_суммы|
-----------------------------+--------------+--------------+-----------------------------+
2016-08-01 00:00:00.000 +0400| 1555565200.00|              |                             |
2016-09-01 00:00:00.000 +0400|13126240900.00| 1555565200.00|                       743.82|
2016-10-01 00:00:00.000 +0400| 6085174800.00|13126240900.00|                       -53.64|*/


--3 Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.
select a.model 
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code
group by a.model
having not array_agg(s.fare_conditions) @> array['Business'::varchar];
/*model             |
------------------+
Bombardier CRJ-200|
Cessna 208 Caravan|*/


/*4 Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты,
которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного. В результате должны быть код аэропорта,
дата, количество пустых мест в самолете и накопительный итог.*/
with cte1 as (
	select actual_departure, departure_airport, aircraft_code,
	count (aircraft_code) over (partition by actual_departure::date, departure_airport) as number_of_flights
	from flights f 
	left join boarding_passes bp on bp.flight_id = f.flight_id 
	where bp.ticket_no is null and actual_departure is not null
	order by actual_departure
	),
        cte2 as (
	select aircraft_code, count(seat_no) as seating_positions
	from seats s 
	group by aircraft_code
	)	
select departure_airport, actual_departure, seating_positions,
	sum (cte2.seating_positions) over (partition by cte1.departure_airport order by actual_departure::date)
from cte1
join cte2 on cte2. aircraft_code = cte1. aircraft_code
where number_of_flights >1
order by actual_departure::date, departure_airport;
/*departure_airport|actual_departure             |seating_positions|sum |
-----------------+-----------------------------+-----------------+----+
ABA              |2016-09-13 12:07:00.000 +0400|               12|  36|
ABA              |2016-09-13 09:36:00.000 +0400|               12|  36|
ABA              |2016-09-13 12:21:00.000 +0400|               12|  36|
AER              |2016-09-13 15:29:00.000 +0400|               97| 318|
AER              |2016-09-13 18:38:00.000 +0400|               12| 318|...*/


/*5 Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
Выведите в результат названия аэропортов и процентное отношение.
Решение должно быть через оконную функцию.*/
select distinct a.airport_name, b.airport_name,
count (f.flight_id) over (partition by departure_airport, arrival_airport)*100/ count(f.flight_id) over ()::numeric as "Процентное_соотношение_перелетов"
from flights f 
join airports a on a. airport_code = f.departure_airport 
join airports b on b. airport_code = f.arrival_airport;
/*airport_name        |airport_name        |Процентное_соотношение_перелетов|
--------------------+--------------------+--------------------------------+
Спиченково          |Емельяново          |          0.36834636635367289635|
Пулково             |Якутск              |          0.18417318317683644817|
Пулково             |Чульман             |          0.02717309259986111530|
Элиста              |Оренбург-Центральный|          0.18417318317683644817|
Шереметьево         |Бугульма            |          0.18417318317683644817|...*/


--6 Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7.
select a.phone desc, count (a.phone)
from (select contact_data ->> 'phone',
	substring (contact_data ->> 'phone', 3,3) as phone
	from tickets t) a
group by a.phone;
/*desc|count|
----+-----+
000 | 3540|
001 | 3679|
002 | 3733|
003 | 3652|
004 | 3777|...*/


/*7 Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:
	до 50 млн - low;
	от 50 млн включительно до 150 млн - middle;
	от 150 млн включительно - high.
	Выведите в результат количество маршрутов в каждом полученном классе.*/
select a.сlassification, count (*) as number_of_routesn		
from (
		select 
		departure_airport, arrival_airport, sum (amount),
		case
			when sum (amount) < 50000000 then 'low'
			when sum (amount) >= 50000000 and sum (amount) < 150000000 then 'middle'
			else 'high'
		end сlassification
		from ticket_flights tf
		join flights f on f.flight_id = tf.flight_id
		group by departure_airport, arrival_airport
		) a
group by a.сlassification;
/*сlassification|number_of_routesn|
--------------+-----------------+
high          |               25|
low           |              355|
middle        |               77|*/


/*8 Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования к медиане стоимости перелетов,
округленной до сотых.*/
with cte1 as (
			select percentile_cont(0.5) within group (order by amount) as "медиана стоимости перелета"
			from ticket_flights
			),
    cte2 as (
			select percentile_cont(0.5) within group (order by total_amount) as "медиана размера бронирования"
			from bookings
			)	
select *, round (("медиана размера бронирования" /"медиана стоимости перелета")::numeric ,2) as "отношение"
from cte1, cte2;
/*медиана стоимости перелета|медиана размера бронирования|отношение|
--------------------------+----------------------------+---------+
                   13400.0|                     55900.0|     4.17|*/


/*9 Найдите значение минимальной стоимости полета 1 км для пассажиров.
То есть нужно найти расстояние между аэропортами и с учетом стоимости перелетов получить искомый результат.*/
create extension cube
 
create extension earthdistance 
 
select min (tf.amount / round((point(a.longitude, a.latitude) <@> point(b.longitude, b.latitude)) * 1.609344))
from flights f
join airports a on a.airport_code = f.departure_airport
join airports b on b.airport_code = f.arrival_airport
join ticket_flights tf on tf.flight_id=f.flight_id
/*min              |
-----------------+
9.868421052631579|*/
