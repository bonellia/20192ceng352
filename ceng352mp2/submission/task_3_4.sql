--My hairline is already agressively receeding, this question made it worse.
WITH years_with_count AS (
	SELECT year, count(*) as annual_pub_count
	FROM publication
	GROUP BY year
	HAVING year >= 1940)
SELECT ywc1.year::text || '-' || (ywc1.year+10)::text, SUM(ywc2.annual_pub_count)
FROM years_with_count ywc1 
INNER JOIN years_with_count ywc2 ON ywc2.year - ywc1.year <= 9 AND ywc2.year - ywc1.year >= 0
GROUP BY ywc1.year
ORDER BY ywc1.year;