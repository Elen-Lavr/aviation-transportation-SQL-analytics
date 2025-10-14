### :exclamation: Задача 1
```txt
Выведите название самолетов, которые имеют менее 50 посадочных мест.
```
### :paperclip: SQL-запрос
```sql
select a.model, count(s.seat_no)
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code
group by model
having count(s.seat_no) < 50;
```
### :heavy_check_mark: Результат выполнения

model             |count|
------------------|-----|
Cessna 208 Caravan|   12|

