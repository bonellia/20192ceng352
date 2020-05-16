--This query ran in 5.8 seconds, again it wasn't too long so I skipped temporary tables.
SELECT A.name, T5.pub_count
FROM
	(SELECT *
	FROM
		(SELECT T3.author_id, COUNT(*) as pub_count
			FROM
				((SELECT *
				FROM(
					SELECT f.field_value as journal, p.pub_id
					FROM field f, publication p
					WHERE f.field_name = 'journal' AND f.pub_key = p.pub_key) as T1
				WHERE T1.journal = 'IEEE Trans. Wireless Communications') AS T2
				JOIN
				Authored ON T2.pub_id = Authored.pub_id) AS T3
			GROUP BY T3.author_id
			HAVING COUNT(*) >= 10) AS T4
	WHERE T4.author_id NOT IN
		(SELECT T5.author_id
			FROM
				((SELECT *
				FROM(
					SELECT f.field_value as journal, p.pub_id
					FROM field f, publication p
					WHERE f.field_name = 'journal' AND f.pub_key = p.pub_key) as T1
				WHERE T1.journal = 'IEEE Wireless Commun. Letters') AS T2
				JOIN
				Authored ON T2.pub_id = Authored.pub_id) AS T5
			GROUP BY T5.author_id
			HAVING COUNT(*) > 0))AS T5, Author A
WHERE T5.author_id = A.author_id
ORDER BY T5.pub_count DESC, A.name ASC;