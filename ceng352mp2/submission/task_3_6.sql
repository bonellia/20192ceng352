WITH year_author_count AS(
	SELECT year, author_id, count(*)
	FROM publication p, authored a
	WHERE p.pub_id = a.pub_id
	GROUP BY year, author_id
	HAVING year >= 1940 AND year <=1990),
	max_count_per_year AS(
	SELECT yac.year, MAX(count) as highest
	FROM year_author_count yac
	GROUP BY yac.year),
	year_authorid_count AS(
	SELECT T1.year, T1.author_id, T2.highest
	FROM year_author_count T1, max_count_per_year T2
	WHERE T1.year = T2.year AND T1.count = T2.highest)
SELECT yaic.year, A.name, yaic.highest as count
FROM year_authorid_count AS yaic, Author A
WHERE yaic.author_id = A.author_id;