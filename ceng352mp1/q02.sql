select ac.airport_code, ac.airport_desc, count(*) as cancel_count
from flight_reports fr, airport_codes ac, cancellation_reasons cr 
where ac.airport_code = fr.origin_airport_code and fr.cancellation_reason = cr.reason_code and cr.reason_desc = 'Security'
group by ac.airport_code
order by cancel_count desc, airport_code asc;