CREATE TABLE IF NOT EXISTS ActiveAuthors (name text);

INSERT INTO ActiveAuthors(name)
SELECT DISTINCT A."name"
FROM Publication P, Authored AD, Author A
WHERE P.year >= 2018 AND P.pub_id = AD.pub_id AND AD.author_id = A.author_id;

CREATE TRIGGER InsertNewActiveAuthor
	AFTER INSERT ON Authored
	REFERENCING NEW ROW AS NewAuthor
	FOR EACH ROW
	WHEN (NewAuthor.name NOT IN
		(SELECT name FROM ActiveAuthors))
	INSERT INTO ActiveAuthors(name)
		VALUES(NewAuthor.name);