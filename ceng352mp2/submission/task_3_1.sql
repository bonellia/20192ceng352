SELECT T3.name, T3.pub_count
FROM
	((SELECT T1.author_id, T1.pub_count
	FROM
		(SELECT a.author_id, count(*) as pub_count
		FROM authored a
		GROUP BY a.author_id) as T1
	WHERE T1.pub_count>= 150 AND T1.pub_count< 200) AS T2
	LEFT JOIN
	Author ON T2.author_id = Author.author_id) as T3
ORDER BY T3.pub_count ASC, T3.name ASC;