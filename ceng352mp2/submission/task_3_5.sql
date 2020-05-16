WITH top_thousand AS (
	SELECT A1.author_id, COUNT(DISTINCT A2.author_id) AS collab_count
	FROM Authored A1, Authored A2
	WHERE A1.pub_id = A2.pub_id AND A1.author_id <> A2.author_id
	GROUP BY A1.author_id
	ORDER BY collab_count DESC
	LIMIT 1000)
SELECT T2.name, T2.collab_count
FROM
	(top_thousand AS TT
	LEFT JOIN Author ON TT.author_id = Author.author_id) AS T2;