select
	ac.airline_name ,
	(100*a.count)::float/b.count as percentage
from 
	(
	select
		fr.airline_code,
		count(*)
	from flight_reports fr
	where
		fr.origin_city_name = 'Boston, MA' and
		fr.is_cancelled = 1
	group by fr.airline_code
	) as a
	left join
	(
	select
		fr.airline_code,
		count(*)
	from flight_reports fr
	where
		fr.origin_city_name = 'Boston, MA'
	group by fr.airline_code
	) as b on a.airline_code = b.airline_code
	left join
	airline_codes as ac on a.airline_code = ac.airline_code 
where a.count > (b.count)::float*0.1
order by percentage desc;