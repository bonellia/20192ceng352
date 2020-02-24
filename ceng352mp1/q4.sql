select ac.airline_name 
from airline_codes ac
where ac.airline_code in
(
						select fr.airline_code
						from flight_reports fr
						where  (fr.is_cancelled = 0 and
								fr."year" = 2018 or fr."year" = 2019) and
								fr.dest_city_name in (
											select distinct fr.dest_city_name 
											from flight_reports fr
											where 
													dest_city_name = 'Boston, MA' or 
													dest_city_name = 'New York, NY' or 
													dest_city_name = 'Portland, ME' or 
													dest_city_name = 'Washington, DC' or 
													dest_city_name = 'Philadelphia, PA'
											) 
						group by fr.airline_code
						having count(distinct fr.dest_city_name) = 5
	)
	and
	ac.airline_code not in (
						select fr.airline_code
						from flight_reports fr
						where  (fr.is_cancelled = 0 and
								fr."year" = 2016 or fr."year" = 2017) and
								fr.dest_city_name in (
											select distinct fr.dest_city_name 
											from flight_reports fr
											where 
													dest_city_name = 'Boston, MA' or 
													dest_city_name = 'New York, NY' or 
													dest_city_name = 'Portland, ME' or 
													dest_city_name = 'Washington, DC' or 
													dest_city_name = 'Philadelphia, PA'
											) 
						group by fr.airline_code
						having count(distinct fr.dest_city_name) = 5
);