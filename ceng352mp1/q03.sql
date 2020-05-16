select T1.plane_tail_number, T1."year", AVG(T1.daily_flight_count) as daily_avg
from (
	SELECT plane_tail_number, "year", month, day, COUNT(*) as daily_flight_count
	FROM flight_reports fr
	WHERE is_cancelled = 0
	GROUP BY plane_tail_number, "year", month, day
	) as T1
group by T1.plane_tail_number, T1."year"
having AVG(T1.daily_flight_count) > 5
order by T1.plane_tail_number asc, T1."year" asc;