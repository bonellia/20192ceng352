select ac.airline_name, count(*) as flight_count
from flight_reports fr, airline_codes ac 
where
	fr.airline_code = ac.airline_code and
	fr.is_cancelled = 0 and
	fr.plane_tail_number in
							(
								(
								select distinct fr1.plane_tail_number 
								from flight_reports fr1, world_area_codes wac1
								where
									fr1.dest_wac_id = wac1.wac_id and
									wac1.wac_name = 'Texas'
								)
								except
								(
								select distinct fr2.plane_tail_number 
								from flight_reports fr2, world_area_codes wac2
								where
									fr2.dest_wac_id = wac2.wac_id and
									wac2.wac_name <> 'Texas'
								)
							)
group by ac.airline_name;