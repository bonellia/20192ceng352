select ac.airline_name, tnf."year", tnf.total_num_flights, cf.cancelled_flights
from

	(
		select fr.airline_code, fr."year", count(*) as total_num_flights
		from flight_reports fr
		where fr.airline_code in
		(
			(
				select t2016.airline_code
				from
				(
					select t1.airline_code, t1.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2016
						) as t1
					group by t1.airline_code, t1.flight_date
				)as t2016
				group by t2016.airline_code
				having avg(daily_flight_count) > 2000
			)
			intersect
			(
				select t2017.airline_code
				from
				(
					select t2.airline_code, t2.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2017
						) as t2
					group by t2.airline_code, t2.flight_date
				)as t2017
				group by t2017.airline_code
				having avg(t2017.daily_flight_count) > 2000
			)
			intersect
			(
				select t2018.airline_code
				from
				(
					select t3.airline_code, t3.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2018
						) as t3
					group by t3.airline_code, t3.flight_date
				)as t2018
				group by t2018.airline_code
				having avg(t2018.daily_flight_count) > 2000
			)
			intersect
			(
				select t2019.airline_code
				from
				(
					select t4.airline_code, t4.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2019
						) as t4
					group by t4.airline_code, t4.flight_date
				)as t2019
				group by t2019.airline_code
				having avg(t2019.daily_flight_count) > 2000
			)
		)
		group by fr.airline_code, fr."year"
	) as tnf
	,
	(
		select fr.airline_code, fr."year", count(*) as cancelled_flights
		from flight_reports fr
		where fr.airline_code in
		(
			(
				select t2016.airline_code
				from
				(
					select t1.airline_code, t1.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2016
						) as t1
					group by t1.airline_code, t1.flight_date
				)as t2016
				group by t2016.airline_code
				having avg(daily_flight_count) > 2000
			)
			intersect
			(
				select t2017.airline_code
				from
				(
					select t2.airline_code, t2.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2017
						) as t2
					group by t2.airline_code, t2.flight_date
				)as t2017
				group by t2017.airline_code
				having avg(t2017.daily_flight_count) > 2000
			)
			intersect
			(
				select t2018.airline_code
				from
				(
					select t3.airline_code, t3.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2018
						) as t3
					group by t3.airline_code, t3.flight_date
				)as t2018
				group by t2018.airline_code
				having avg(t2018.daily_flight_count) > 2000
			)
			intersect
			(
				select t2019.airline_code
				from
				(
					select t4.airline_code, t4.flight_date, count(*) as daily_flight_count
					from
						(
							select fr.airline_code, fr.report_id, (fr."year"*10000+fr."month"*100+fr."day") as flight_date
							from flight_reports fr
							where fr."year" = 2019
						) as t4
					group by t4.airline_code, t4.flight_date
				)as t2019
				group by t2019.airline_code
				having avg(t2019.daily_flight_count) > 2000
			)
		)
		and fr.is_cancelled = 1
		group by fr.airline_code, fr."year"
	) as cf
	,
	airline_codes ac
where
	 tnf.airline_code = cf.airline_code and
	 tnf."year" = cf."year" and
	 tnf.airline_code = ac.airline_code;
