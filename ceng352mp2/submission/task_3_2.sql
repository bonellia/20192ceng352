-- Query runs in less than 5 seconds, so I see no reason to create temporary tables.
SELECT A.name as author_name, T4.pub_count
FROM
	(SELECT T3.author_id, COUNT(*) AS pub_count
	FROM
		((SELECT *
		FROM(
			SELECT f.field_value as journal, p.pub_id
			FROM field f, publication p
			WHERE f.field_name = 'journal' AND f.pub_key = p.pub_key) as T1
		WHERE T1.journal LIKE '%IEEE%') AS T2
		JOIN
		Authored ON T2.pub_id = Authored.pub_id) AS T3
	GROUP BY T3.author_id
	ORDER BY pub_count DESC
	LIMIT 50) AS T4, Author A
WHERE T4.author_id = A.author_id;