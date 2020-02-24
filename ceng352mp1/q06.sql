select
	daily_averages.day_id as weekday_id,
	w.weekday_name,
	daily_averages.avg_delay
from	
		weekdays w,
		(
		select 
				relevant_flights.day_id,
				avg(relevant_flights.total_delay) as avg_delay
		from 
				(
				select
						fr.weekday_id as day_id,
						fr.origin_city_name as dpt_city,
						fr.dest_city_name dst_city,
						(fr.departure_delay + fr.arrival_delay ) as total_delay
				from flight_reports fr
				where
					fr.is_cancelled = 0 and 
					fr.origin_city_name = 'San Francisco, CA' and
					fr.dest_city_name = 'Boston, MA'
				) as relevant_flights
		group by relevant_flights.day_id
		) as daily_averages
where
	w.weekday_id = daily_averages.day_id and
	daily_averages.avg_delay <= all (
	
	select
			avg(relevant_flights.total_delay) as avg_delay
		from 
			(
			select
					fr.weekday_id as day_id,
					fr.origin_city_name as dpt_city,
					fr.dest_city_name dst_city,
					(fr.departure_delay + fr.arrival_delay ) as total_delay
			from flight_reports fr
			where
				fr.is_cancelled = 0 and 
				fr.origin_city_name = 'San Francisco, CA' and
				fr.dest_city_name = 'Boston, MA'
			) as relevant_flights
		group by relevant_flights.day_id
		);