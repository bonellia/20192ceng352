select
	t1."year",
	t1.airline_code,
	t2.boston_flight_count,
	(t2.boston_flight_count::float*100)/t1.total_flights::float as boston_flight_percentage
from
	(
		select
			fr1."year",
			fr1.airline_code,
			count(*) as total_flights
		from flight_reports fr1
		where
			fr1.is_cancelled = 0	
		group by fr1."year", fr1.airline_code
	)  t1,
	(
		select
			fr2."year",
			fr2.airline_code,
			count(*) as boston_flight_count
		from flight_reports fr2
		where
			fr2.is_cancelled = 0 and
			fr2.dest_city_name = 'Boston, MA'
		group by fr2."year", fr2.airline_code
	) t2
where
	t1."year" = t2."year" and t1.airline_code = t2.airline_code and
	(t2.boston_flight_count::float*100)/t1.total_flights::float > 1
order by t1."year" asc, t1.airline_code asc;