### :exclamation: Задача 3
```txt
Выведите названия самолетов не имеющих бизнес - класс.
Решение должно быть через функцию array_agg.
```
### :paperclip: SQL-запрос
```sql
select a.model 
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code
group by a.model
having not array_agg(s.fare_conditions) @> array['Business'::varchar];
```
### :heavy_check_mark: Результат выполнения

|model             |
|------------------|
|Bombardier CRJ-200|
|Cessna 208 Caravan|
