### :exclamation: Задача 2
Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

### :paperclip: SQL-запрос
```sql
select date_trunc('month', book_date::date), sum(total_amount),
	lag(sum(total_amount),1) over (order by date_trunc('month',book_date::date)),
	round ((sum(total_amount) - lag(sum(total_amount),1) over (order by date_trunc('month', book_date::date)))/lag(sum(total_amount),1) over (order by date_trunc('month', book_date::date))*100, 2) as "%_изменение_ежемесячной_суммы"
from bookings
group by date_trunc('month', book_date::date)
order by 1;
```
### :heavy_check_mark: Результат выполнения
```csv
aircraft_name
Cessna 172
ATR 42
Bombardier CRJ200
```
