### :exclamation: Задача 2
```txt
Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.
```
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
date_trunc                   |sum           |lag           |%_изменение_ежемесячной_суммы|
-----------------------------+--------------+--------------+-----------------------------+
2016-08-01 00:00:00.000 +0400| 1555565200.00|              |                             |
2016-09-01 00:00:00.000 +0400|13126240900.00| 1555565200.00|                       743.82|
2016-10-01 00:00:00.000 +0400| 6085174800.00|13126240900.00|                       -53.64|
```
