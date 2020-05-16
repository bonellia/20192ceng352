SELECT F.field_name
FROM (SELECT DISTINCT field_name FROM FIELD) AS F 
WHERE NOT EXISTS (
	(SELECT DISTINCT P.PUB_TYPE 
	FROM PUB P)
	EXCEPT
	(SELECT DISTINCT P2.PUB_TYPE 
	FROM FIELD F2, PUB P2
	WHERE F2.PUB_KEY = P2.PUB_KEY AND F.FIELD_NAME = F2.FIELD_NAME )
)
ORDER BY F.field_name ASC;