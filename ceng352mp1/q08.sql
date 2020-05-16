select distinct lfr.plane_tail_number, lfr.airline_code as first_owner, rfr.airline_code as second_owner
from
	(select distinct fr1.plane_tail_number, fr1.airline_code, ac1.airline_name, (fr1."year"*10000+fr1."month"*100+fr1."day") as old_date 
	from flight_reports fr1, airline_codes ac1
	where fr1.airline_code = ac1.airline_code) as lfr
	join
	(select distinct fr2.plane_tail_number, fr2.airline_code, ac2.airline_name, (fr2."year"*10000+fr2."month"*100+fr2."day") as new_date
	from flight_reports fr2, airline_codes ac2
	where fr2.airline_code = ac2.airline_code) as rfr
		on
			lfr.plane_tail_number = rfr.plane_tail_number and
			lfr.airline_code <> rfr.airline_code and
			lfr.old_date < rfr.new_date
order by lfr.plane_tail_number asc;