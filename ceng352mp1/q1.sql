select ac.airline_name, fr.airline_code, avg(fr.departure_delay) as avg_delay
from airline_codes ac, flight_reports fr
where ac.airline_code = fr.airline_code and fr.is_cancelled <> 1 and fr."year" = 2018
group by fr.airline_code, ac.airline_name
order by avg_delay asc, ac.airline_name asc;