### :exclamation: Задача 1
```txt
Выведите название самолетов, которые имеют менее 50 посадочных мест.
```
### :paperclip: SQL-запрос
```sql
select a.model
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code
group by model
having count(s.seat_no) < 50;
```
### :heavy_check_mark: Результат выполнения

|model             |
|------------------|
|Cessna 208 Caravan|

