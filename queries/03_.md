### :exclamation: Задача 3
Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.

### :paperclip: SQL-запрос
```sql
select a.model 
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code
group by a.model
having not array_agg(s.fare_conditions) @> array['Business'::varchar];
```
### :heavy_check_mark: Результат выполнения
```csv
aircraft_name
Cessna 172
ATR 42
Bombardier CRJ200
```
