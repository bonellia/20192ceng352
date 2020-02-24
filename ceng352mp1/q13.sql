select
	ac.airline_name, t1.monday_flights, t2.sunday_flights
from
	(
		select
			fr1.airline_code,
			count(*) as monday_flights
		from flight_reports fr1, weekdays w1
		where
			fr1.is_cancelled = 0 and
			fr1.weekday_id = w1.weekday_id and
			w1.weekday_name = 'Monday'
		group by fr1.airline_code
	)  t1,
	(
		select
			fr2.airline_code,
			count(*) as sunday_flights
		from flight_reports fr2, weekdays w2
		where
			fr2.is_cancelled = 0 and
			fr2.weekday_id = w2.weekday_id and
			w2.weekday_name = 'Sunday'
		group by fr2.airline_code
	) t2,
	airline_codes ac
where
	t1.airline_code = t2.airline_code and
	t1.airline_code = ac.airline_code
order by ac.airline_name asc;