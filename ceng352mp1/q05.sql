select
	((fr1."day"::text) || '/' || (fr1."month"::text) || '/' || (fr1."year"::text)) as flight_date,
	fr1.plane_tail_number,
	fr1.arrival_time as flight1_arrival_time,
	fr2.departure_time as flight2_departure_time,
	fr1.origin_city_name,
	fr1.dest_city_name as stop_city_name,
	fr2.dest_city_name,
	(fr1.flight_time + fr1.taxi_out_time + fr2.taxi_in_time + fr2.flight_time ) as total_time,
	(fr1.flight_distance + fr2.flight_distance) as total_distance
from flight_reports fr1, flight_reports fr2
where
	fr1.report_id <> fr2.report_id and
	fr1.plane_tail_number = fr2.plane_tail_number and
	(fr1."year"*10000+fr1."month"*100+fr1."day") = (fr2."year"*10000+fr2."month"*100+fr2."day") and
	fr1.is_cancelled = 0 and
	fr1.origin_city_name = 'Seattle, WA' and
	fr1.dest_city_name = fr2.origin_city_name and
	fr2.dest_city_name = 'Boston, MA' and
	fr1.arrival_time < fr2.departure_time
order by
	total_time asc,
	total_distance asc,
	plane_tail_number asc,
	stop_city_name asc;