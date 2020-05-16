select ac.airport_desc
from
(
	(select fr.dest_airport_code, count(*) as incco
	from flight_reports fr
	where is_cancelled = 0
	group by fr.dest_airport_code) as t1
join
	(select fr.origin_airport_code, count(*) as outco
	from flight_reports fr
	where is_cancelled = 0
	group by fr.origin_airport_code) as t2 on t1.dest_airport_code = t2.origin_airport_code
) t3, airport_codes ac
where t3.dest_airport_code = ac.airport_code
order by (incco+outco) desc
limit 5;