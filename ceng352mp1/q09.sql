select myt.plane_tail_number, avg(myt.flight_distance/myt.flight_time) as avg_speed
from flight_reports myt
where myt.plane_tail_number in
							(
								(
								select distinct fr1.plane_tail_number
								from flight_reports fr1
								where
									fr1.is_cancelled = 0 and
									fr1."year" = 2016 and
									fr1."month" = 1 and
									(fr1.weekday_id = 6 or fr1.weekday_id = 7)
								)
								except
								(
								select distinct fr2.plane_tail_number
								from flight_reports fr2
								where
									fr2.is_cancelled = 0 and
									fr2."year" = 2016 and
									fr2."month" = 1 and
									(fr2.weekday_id = 1 or
									fr2.weekday_id = 2 or
									fr2.weekday_id = 3 or
									fr2.weekday_id = 4 or
									fr2.weekday_id = 5)
								)
							)
group by myt.plane_tail_number
order by avg_speed desc;