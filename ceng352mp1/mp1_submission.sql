-- 1. Find airlines and their average departure delay in 2018. Show airline name in ascending
-- order, airline code and average departure delay in ascending order. Remember to disregard
-- cancelled flights. (18 rows)

SELECT ac.airline_name, fr.airline_code, AVG(fr.departure_delay) AS avg_delay
FROM airline_codes ac, flight_reports fr
WHERE ac.airline_code = fr.airline_code AND fr.is_cancelled <> 1 AND fr."year" = 2018
GROUP BY fr.airline_code, ac.airline_name
ORDER BY avg_delay ASC, ac.airline_name ASC;

-- 2. List airports and the number of cancelled flights with ’Security’ reason. Show airport code,
-- airport description and cancelled flight count in descending order. (53 rows)

SELECT ac.airport_code, ac.airport_desc, COUNT(*) AS cancel_count
FROM flight_reports fr, airport_codes ac, cancellation_reasons cr 
WHERE ac.airport_code = fr.origin_airport_code AND fr.cancellation_reason = cr.reason_code AND cr.reason_desc = 'Security'
GROUP BY ac.airport_code
ORDER BY cancel_count DESC, airport_code ASC;

-- 3.  List planes that received maintenance at the end of the year. 
-- When a plane has more than5 flights per day in a yearly period, it receives maintenance. 
-- Show plane tail number, year,daily flight average.  Remember to disregard cancelled flights.  (3821 rows)
-- ***CLARIFICATION:You need to find the number of non-cancelled flights of planes foreach day. 
-- Then you need to check yearly flight count averages considering daily flight counts that you previously found. 
-- If the yearly average is more than 5, then the plane went undermaintenance.

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

-- 4. Find airlines that goes to ALL of ’Boston, MA’, ’New York, NY’, ’Portland, ME’, ’Washington, DC’, ’Philadelphia, PA’ cities, in 2018 or 2019. 
-- You should disregard the ones thatalready flying these cities in 2016 or 2017.  You should also ignore cancelled flights. 
-- Showairline names only.  (5 rows)

select ac.airline_name 
from airline_codes ac
where ac.airline_code in (
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

-- 5. Find all non-cancelled travels from Seattle to Boston with one stop. 
-- Flights should happenin the same day (flight1:  Seattle =>Destination, flight2:  Destination =>Boston). 
-- order flights by their total time, in ascending order.
-- Total time = flight1(flight_time) + flight1(taxi_out_time)+ flight2(taxi_in_time) + flight2(flight_time)
-- Total distance = flight1(flight_distance) + flight2(flight_distance)
-- Remember to check thatflight1(arrivaltime)<flight2(departuretime).
-- Show flightdate  as  ”DD/MM/YYYY”  string,  plane  tail  number,  flight1  arrivaltime,  
-- flight2  depar-turetime,  flight1  origincityname,  stopcityname,  flight2  destcityname,  totaltime,  to-taldistance.  (253 rows)

select
	((fr1."day"::text) || '/' || (fr1."month"::text) || '/' || (fr1."year"::text)) as flight_date,
	fr1.plane_tail_number,
	fr1.arrival_time as flight1_arrival_time,
	fr2.departure_time as flight2_departure_time,
	fr1.origin_city_name,
	fr1.dest_city_name as stop_city_name,
	fr2.dest_city_name,
	(fr1.flight_time + fr1.taxi_out_time + fr2.taxi_in_time + fr2.flight_time ) as total_time,
	(fr1.flight_distance + fr2.flight_distance) as total_distance
from flight_reports fr1, flight_reports fr2
where
	fr1.report_id <> fr2.report_id and
	fr1.plane_tail_number = fr2.plane_tail_number and
	(fr1."year"*10000+fr1."month"*100+fr1."day") = (fr2."year"*10000+fr2."month"*100+fr2."day") and
	fr1.is_cancelled = 0 and
	fr1.origin_city_name = 'Seattle, WA' and
	fr1.dest_city_name = fr2.origin_city_name and
	fr2.dest_city_name = 'Boston, MA' and
	fr1.arrival_time < fr2.departure_time
order by
	total_time asc,
	total_distance asc,
	plane_tail_number asc,
	stop_city_name asc;
	
-- 6. Find best weekday for flights from San Francisco to Boston.
-- Best weekday is the day that has least ”departure delay + arrival delay” daily average.
-- Show weekday id, weekday name,average delay.  (1 row only, the best one)
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
		)

-- 7. Find all airlines that had more than 10% of their flights out of Boston are cancelled.
-- Return the airline name and the percentage of canceled flights out of Boston.
-- Order the results by the percentage of canceled flights in descending order.  (2 rows)
select
	ac.airline_name ,
	(100*a.count)/b.count as percentage
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
where a.count > (b.count)*0.1

-- 8. Sometimes an airline can buy planes from another airline and re-brand it. 
-- Find sold and re-branded planes.  Display plane tail number, first owner airline code and second owner airlinecode.
-- You need to check same plane tail number for different airlines.
-- Airline A can use plane X in 2016 and airline B can use same plane in 2018, 2019.
-- Therefore(’X’, ’A’, ’B’) should be in the query result.  (189 rows)

select distinct lfr.plane_tail_number, lfr.airline_name as first_owner, rfr.airline_name as second_owner
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
order by lfr.plane_tail_number asc

-- 9. Find average speed of planes that flew ONLY weekends of January 2016. 
-- Show plane tailnumber and average speed. 
-- Results should have an descending order on average speed.  (15rows)

select fr.plane_tail_number, avg(fr.flight_distance/fr.flight_time) as avg_speed
from flight_reports fr
where
	fr.is_cancelled = 0 and
	fr.report_id not in 
		(
		select fr.report_id 
		from flight_reports fr
		where
			fr.weekday_id <> 6 or
			fr.weekday_id <> 7 or
			fr."year" <> 2016 or
			fr."month" <> 1
		)
group by fr.plane_tail_number 

select *
from
	(
	select fr.report_id
	from flight_reports fr
	where fr.report_id not in 
			(
			select fr.report_id 
			from flight_reports fr
			where
				fr."year" <> 2016
			)
	)
	union 
	(
	select fr.report_id
	from flight_reports fr
	where fr.report_id not in 
			(
			select fr.report_id 
			from flight_reports fr
			where
				fr."month" <> 1
			)
	)
	union 
	(
	select fr.report_id
	from flight_reports fr
	where fr.report_id not in 
			(
			select fr.report_id 
			from flight_reports fr
			where
				fr."month" <> 6 or fr."month" <> 7
			)
	)