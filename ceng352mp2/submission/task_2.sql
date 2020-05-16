--Author (author_id serial primary key, name text)

INSERT INTO Author(name)
SELECT DISTINCT field.field_value
FROM field
WHERE FIELD_NAME = 'author';

--Publication (pub_id serial primary key, pub_key text, title text, year int)
INSERT INTO Publication(pub_key, title, year)
SELECT T.pub_key, T.title, T.year::INTEGER
FROM (
	SELECT *
	FROM
		((SELECT DISTINCT f1.pub_key
		FROM field f1) AS T1
		LEFT JOIN
		(SELECT DISTINCT f2.pub_key as pub_key2, f2.field_value as title
		FROM field f2
		WHERE f2.FIELD_NAME = 'title') AS T2 ON T1.pub_key = T2.pub_key2) AS T3
		LEFT JOIN
		(SELECT DISTINCT f3.pub_key as pub_key3, f3.field_value as year
		FROM field f3
		WHERE f3.FIELD_NAME = 'year') AS T4 ON T3.pub_key = T4.pub_key3
	) AS T;
	
--Article (pub_id int primary key, journal text, month text, volume text, number text)
INSERT INTO Article(pub_id, journal, month, volume, number)
SELECT T6.pub_id, T6.f1_field_value as journal, T6.f2_field_value as month, T6.f3_field_value as volume, T6.f4_field_value as number
FROM (
	SELECT *
	FROM
		(((((SELECT p2.pub_id, p2.pub_key AS t1_pub_key FROM pub p1, publication p2 WHERE p1.pub_type = 'article' AND p1.pub_key = p2.pub_key) AS T1
		LEFT JOIN
		(SELECT pub_key AS f1_pub_key, field_name AS f1_field_name, field_value as f1_field_value FROM field WHERE field_name = 'journal') AS F1
			ON T1.t1_pub_key = F1.f1_pub_key) AS T2
		LEFT JOIN
		(SELECT pub_key AS f2_pub_key, field_name AS f2_field_name, field_value as f2_field_value FROM field WHERE field_name = 'month') AS F2
			ON T2.t1_pub_key = F2.f2_pub_key) AS T3
		LEFT JOIN
		(SELECT pub_key AS f3_pub_key, field_name AS f3_field_name, field_value as f3_field_value FROM field WHERE field_name = 'volume') AS F3
			ON T3.t1_pub_key = F3.f3_pub_key) AS T4
		LEFT JOIN
		(SELECT pub_key AS f4_pub_key, field_name AS f4_field_name, field_value as f4_field_value FROM field WHERE field_name = 'number') AS F4
			ON T4.t1_pub_key = F4.f4_pub_key) AS T5
		) AS T6;

--Book (pub_id int primary key, publisher text, isbn text)
INSERT INTO Book(pub_id, publisher, isbn)
SELECT T4.pub_id, T4.f1_field_value as publisher, T4.f2_field_value as isbn
FROM (
	SELECT *
	FROM
		(((SELECT p2.pub_id, p2.pub_key AS t1_pub_key FROM pub p1, publication p2 WHERE p1.pub_type = 'book' AND p1.pub_key = p2.pub_key) AS T1
		LEFT JOIN
		(SELECT pub_key AS f1_pub_key, field_name AS f1_field_name, field_value as f1_field_value FROM field WHERE field_name = 'publisher') AS F1
			ON T1.t1_pub_key = F1.f1_pub_key) AS T2
		LEFT JOIN
		(SELECT t.f2_pub_key, MAX(t.f2_field_value) as  f2_field_value
		FROM (SELECT pub_key AS f2_pub_key, field_name AS f2_field_name, field_value as f2_field_value FROM field WHERE field_name = 'isbn') as t
		GROUP BY t.f2_pub_key) AS F2
			ON T2.t1_pub_key = F2.f2_pub_key) AS T3
		) AS T4;

--Incollection (pub_id int primary key, book_title text, publisher text, isbn text)
INSERT INTO Incollection(pub_id, book_title, publisher, isbn)
SELECT T5.pub_id, T5.f1_field_value as book_title, T5.f2_field_value as publisher, T5.f3_field_value as isbn
FROM (
	SELECT *
	FROM
		((((SELECT p2.pub_id, p2.pub_key AS t1_pub_key FROM pub p1, publication p2 WHERE p1.pub_type = 'incollection' AND p1.pub_key = p2.pub_key) AS T1
		LEFT JOIN
		(SELECT pub_key AS f1_pub_key, field_name AS f1_field_name, field_value as f1_field_value FROM field WHERE field_name = 'booktitle') AS F1
			ON T1.t1_pub_key = F1.f1_pub_key) AS T2
		LEFT JOIN
		(SELECT pub_key AS f2_pub_key, field_name AS f2_field_name, field_value as f2_field_value FROM field WHERE field_name = 'publisher') AS F2
			ON T2.t1_pub_key = F2.f2_pub_key) AS T3
		LEFT JOIN
		(SELECT T.f3_pub_key, MAX(T.f3_field_value) as f3_field_value
		FROM (SELECT pub_key AS f3_pub_key, field_name AS f3_field_name, field_value as f3_field_value FROM field WHERE field_name = 'isbn') as T
		GROUP BY T.f3_pub_key) AS F3
			ON T3.t1_pub_key = F3.f3_pub_key) AS T4
		) AS T5;

--Inproceedings (pub_id int primary key, book_title text, editor text)

INSERT INTO Inproceedings(pub_id, book_title, editor)
SELECT T4.pub_id, T4.f1_field_value as book_title, T4.f2_field_value as editor
FROM (
	SELECT *
	FROM
		(((SELECT p2.pub_id, p2.pub_key AS t1_pub_key FROM pub p1, publication p2 WHERE p1.pub_type = 'inproceedings' AND p1.pub_key = p2.pub_key) AS T1
		LEFT JOIN
		(SELECT pub_key AS f1_pub_key, field_name AS f1_field_name, field_value as f1_field_value FROM field WHERE field_name = 'booktitle') AS F1
			ON T1.t1_pub_key = F1.f1_pub_key) AS T2
		LEFT JOIN
		(SELECT pub_key AS f2_pub_key, field_name AS f2_field_name, field_value as f2_field_value FROM field WHERE field_name = 'editor') AS F2
			ON T2.t1_pub_key = F2.f2_pub_key) AS T3		
		) AS T4;

--Authored (author_id int, pub_id int)
INSERT INTO Authored(author_id, pub_id)
SELECT T4.author_id, T4.t1_pub_id
FROM (
	SELECT *
	FROM
	((SELECT p1.pub_key as t1_pub_key, p2.pub_id as t1_pub_id
	FROM pub p1, publication p2
	WHERE p1.pub_key = p2.pub_key) as T1
	JOIN
	(SELECT pub_key as t2_pub_key, field_value as t2_field_value
	FROM field
	WHERE field_name = 'author') as T2
	ON T1.t1_pub_key = T2.t2_pub_key ) as T3
	JOIN
	Author ON T3.t2_field_value = Author."name") as T4;
