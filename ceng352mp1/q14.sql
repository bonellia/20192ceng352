select t2."year", t2.weekday_name, t3.reason_desc, t2.number_of_cancellations
from 

	(
	select t1."year", t1.weekday_name, max(number_of_cancellations) as number_of_cancellations
	from
		(
		select fr."year", w.weekday_name, cr.reason_desc, count(*) as number_of_cancellations
		from flight_reports fr, cancellation_reasons cr, weekdays w
		where
			fr.cancellation_reason = cr.reason_code and
			fr.weekday_id = w.weekday_id
		group by fr."year", fr.weekday_id, w.weekday_name, cr.reason_desc
		order by fr."year" asc, fr.weekday_id asc
		) as t1
	group by t1.year, t1.weekday_name
	) t2,
	(
	select fr."year", w.weekday_name, cr.reason_desc, count(*) as number_of_cancellations
		from flight_reports fr, cancellation_reasons cr, weekdays w
		where
			fr.cancellation_reason = cr.reason_code and
			fr.weekday_id = w.weekday_id
		group by fr."year", fr.weekday_id, w.weekday_name, cr.reason_desc
		order by fr."year" asc, fr.weekday_id asc
	) t3
where
	t2."year" = t3."year" and
	t2.weekday_name = t3.weekday_name and
	t2.number_of_cancellations = t3.number_of_cancellations;