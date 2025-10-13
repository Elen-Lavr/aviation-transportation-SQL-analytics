### :exclamation: Задача 1
Выведите название самолетов, которые имеют менее 50 посадочных мест.

### :paperclip: SQL-запрос
```sql
select aircraft_name 
from aircrafts 
where total_seats < 50;
```
### :heavy_check_mark: Результат выполнения
```csv
aircraft_name
Cessna 172
ATR 42
Bombardier CRJ200
```
