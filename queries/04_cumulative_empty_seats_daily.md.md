### :exclamation: Задача 4
Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.

В результате должны быть: 
 - код аэропорта,
 - дата,
 - количество пустых мест в самолете,
 - накопительный итог.

### :paperclip: SQL-запрос
```sql
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
```
### :heavy_check_mark: Результат выполнения
```csv
departure_airport|actual_departure             |seating_positions|sum |
-----------------+-----------------------------+-----------------+----+
ABA              |2016-09-13 12:07:00.000 +0400|               12|  36|
ABA              |2016-09-13 09:36:00.000 +0400|               12|  36|
ABA              |2016-09-13 12:21:00.000 +0400|               12|  36|
AER              |2016-09-13 15:29:00.000 +0400|               97| 318|
AER              |2016-09-13 18:38:00.000 +0400|               12| 318|
AER              |2016-09-13 12:48:00.000 +0400|               50| 318|
AER              |2016-09-13 13:10:00.000 +0400|               50| 318|
AER              |2016-09-13 15:10:00.000 +0400|               12| 318|
AER              |2016-09-13 20:15:00.000 +0400|               97| 318|
ARH              |2016-09-13 11:39:00.000 +0400|               12|  74|
ARH              |2016-09-13 14:42:00.000 +0400|               12|  74|
ARH              |2016-09-13 13:41:00.000 +0400|               50|  74|
BAX              |2016-09-13 05:02:00.000 +0400|               12| 109|
BAX              |2016-09-13 05:36:00.000 +0400|               97| 109|
BZK              |2016-09-13 19:52:00.000 +0400|               97| 679|
BZK              |2016-09-13 19:00:00.000 +0400|               97| 679|
BZK              |2016-09-13 19:33:00.000 +0400|               97| 679|
BZK              |2016-09-13 20:23:00.000 +0400|               97| 679|
BZK              |2016-09-13 09:23:00.000 +0400|               97| 679|
BZK              |2016-09-13 10:33:00.000 +0400|               97| 679|
BZK              |2016-09-13 11:06:00.000 +0400|               97| 679|
CEE              |2016-09-13 12:47:00.000 +0400|               12| 121|...
```
