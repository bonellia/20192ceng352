from customer import Customer

import psycopg2

from config import read_config
from messages import *

POSTGRESQL_CONFIG_FILE_NAME = "database.cfg"

"""
    Connects to PostgreSQL database and returns connection object.
"""


def connect_to_db():
    db_conn_params = read_config(filename=POSTGRESQL_CONFIG_FILE_NAME, section="postgresql")
    conn = psycopg2.connect(**db_conn_params)
    conn.autocommit = False
    return conn


"""
    Splits given command string by spaces and trims each token.
    Returns token list.
"""


def tokenize_command(command):
    tokens = command.split(" ")
    return [t.strip() for t in tokens]


"""
    Prints list of available commands of the software.
"""


def help():
    # prints the choices for commands and parameters
    print("\n*** Please enter one of the following commands ***")
    print("> help")
    print("> sign_up <email> <password> <first_name> <last_name> <plan_id>")
    print("> sign_in <email> <password>")
    print("> sign_out")
    print("> show_plans")
    print("> show_subscription")
    print("> subscribe <plan_id>")
    print("> watched_movies <movie_id_1> <movie_id_2> <movie_id_3> ... <movie_id_n>")
    print("> search_for_movies <keyword_1> <keyword_2> <keyword_3> ... <keyword_n>")
    print("> suggest_movies")
    print("> quit")


"""
    Saves customer with given details.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def sign_up(conn, email, password, first_name, last_name, plan_id):
    # TODO: Implement this function
    try:
        cur = conn.cursor()
        cur.execute("INSERT INTO Customer(email, password, first_name, last_name, session_count, plan_id) VALUES (%s, %s, %s, %s, %s, %s);",
                    (email, password, first_name, last_name, 0, plan_id))
        conn.commit()
        return (True, CMD_EXECUTION_SUCCESS)
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)


"""
    Retrieves customer information if email and password is correct and customer's session_count < max_parallel_sessions.
    - Return type is a tuple, 1st element is a customer object and 2nd element is the response message from messages.py.
    - If email or password is wrong, return tuple (None, USER_SIGNIN_FAILED).
    - If session_count < max_parallel_sessions, commit changes (increment session_count) and return tuple (customer, CMD_EXECUTION_SUCCESS).
    - If session_count >= max_parallel_sessions, return tuple (None, USER_ALL_SESSIONS_ARE_USED).
    - If any exception occurs; rollback, do nothing on the database and return tuple (None, USER_SIGNIN_FAILED).
"""


def sign_in(conn, email, password):
    # TODO: Implement this function
    cur = conn.cursor()
    try:
        cur.execute("SELECT * FROM Customer WHERE email = %s AND password = %s;", (email, password))
        customer = cur.fetchone()
        if customer == None:
            return None, USER_SIGNIN_FAILED
        else:
            cur.execute("SELECT C.session_count, P.max_parallel_sessions FROM Customer C, Plan P WHERE C.plan_id = P.plan_id AND C.email = %s;", (email,))
            session_result = cur.fetchone()
            current_session_count = session_result[0]
            max_session_count = session_result[1]
            if current_session_count >= max_session_count:
                return (None, USER_ALL_SESSIONS_ARE_USED)
            else:
                cur.execute("UPDATE Customer SET session_count = session_count + 1 WHERE email = %s;", (email,))
                conn.commit()
                return (f"{customer[3]} {customer[4]} ({customer[1]})", CMD_EXECUTION_SUCCESS)
    except Exception:
        conn.rollback()
        return (None, CMD_EXECUTION_FAILED)



"""
    Signs out from given customer's account.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - Decrement session_count of the customer in the database.
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def sign_out(conn, customer):
    # TODO: Implement this function
    cur = conn.cursor()
    # Need to parse user's email since apparently the parameter customer is just a string.
    email = customer.split()[-1][1:-1]
    try:
        cur.execute("SELECT session_count FROM Customer WHERE email = %s;", (email,))
        current_session_count = cur.fetchone()[0]
        if current_session_count >= 1:
            cur.execute("UPDATE Customer SET session_count = session_count - 1 WHERE email = %s;", (email,))
            conn.commit()
            return (True, CMD_EXECUTION_SUCCESS)            
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)


"""
    Quits from program.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - Remember to sign authenticated user out first.
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def quit(conn, customer):
    # TODO: Implement this function
    try:
        if customer:
            # I was going to copy-paste what sign_out does here.
            # But apparently just calling it does the job.
            # Since it already commits/rollbacks, no need to commit below.
            sign_out(conn, customer)
        return (True, CMD_EXECUTION_SUCCESS)
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)


"""
    Retrieves all available plans and prints them.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If the operation is successful; print available plans and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).

    Output should be like:
    #|Name|Resolution|Max Sessions|Monthly Fee
    1|Basic|720P|2|30
    2|Advanced|1080P|4|50
    3|Premium|4K|10|90
"""


def show_plans(conn):
    # TODO: Implement this function
    cur = conn.cursor()
    try:
        cur.execute("SELECT * FROM Plan;")
        plans = cur.fetchall()
        print(f"#|Name|Resolution|Max Sessions|Monthly Fee")
        for plan in plans:
            print(f"{plan[1]}|{plan[2]}|{plan[3]}|{plan[4]}")
        return (True, CMD_EXECUTION_SUCCESS)
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)


"""
    Retrieves authenticated user's plan and prints it. 
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If the operation is successful; print the authenticated customer's plan and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).

    Output should be like:
    #|Name|Resolution|Max Sessions|Monthly Fee
    1|Basic|720P|2|30
"""


def show_subscription(conn, customer):
    # TODO: Implement this function
    cur = conn.cursor()
    # Need to parse user's email since apparently the parameter customer is just a string.
    email = customer.split()[-1][1:-1]
    try:
        cur.execute("SELECT plan_id FROM Customer WHERE email = %s;", (email,))
        current_plan_id = cur.fetchone()[0]
        cur.execute("SELECT * FROM Plan WHERE plan_id = %s;", (current_plan_id,))
        plan = cur.fetchone()
        print(f"#|Name|Resolution|Max Sessions|Monthly Fee")
        print(f"{plan[0]}|{plan[1]}|{plan[2]}|{plan[3]}|{plan[4]}")
        conn.commit()
        return (True, CMD_EXECUTION_SUCCESS)            
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)

"""
    Insert customer-movie relationships to Watched table if not exists in Watched table.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - If a customer-movie relationship already exists, do nothing on the database and return (True, CMD_EXECUTION_SUCCESS).
    - If the operation is successful, commit changes and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any one of the movie ids is incorrect; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
    - If any exception occurs; rollback, do nothing on the database and return tuple (False, CMD_EXECUTION_FAILED).
"""


def watched_movies(conn, customer, movie_ids):
    # TODO: Implement this function
    cur = conn.cursor()
    email = customer.split()[-1][1:-1]
    try:
        cur.execute("SELECT * FROM Customer WHERE email = %s;", (email,))
        customer_row = cur.fetchone()
        customer_id = customer_row[0]
        for movie in movie_ids:
            cur.execute("SELECT * FROM Movies WHERE movie_id = %s;", (movie,))
            movie_row = cur.fetchone()
            if movie_row == None:
                print(f"movie with the id {movie} not found")
                conn.rollback()
                return (False, CMD_EXECUTION_FAILED)
            else:
                cur.execute("SELECT * FROM Watched WHERE customer_id = %s AND movie_id = %s;", (customer_id, movie))
                watched_row = cur.fetchone()
                if watched_row != None:
                    print("watched record already exists")
                    continue
                else:
                    print("adding new watched record")
                    cur.execute("INSERT INTO Watched(customer_id, movie_id) VALUES (%s, %s);", (customer_id, movie))
        conn.commit()
        return (True, CMD_EXECUTION_SUCCESS)
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)


"""
    Subscribe authenticated customer to new plan.
    - Return type is a tuple, 1st element is a customer object and 2nd element is the response message from messages.py.
    - If target plan does not exist on the database, return tuple (None, SUBSCRIBE_PLAN_NOT_FOUND).
    - If the new plan's max_parallel_sessions < current plan's max_parallel_sessions, return tuple (None, SUBSCRIBE_MAX_PARALLEL_SESSIONS_UNAVAILABLE).
    - If the operation is successful, commit changes and return tuple (customer, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; rollback, do nothing on the database and return tuple (None, CMD_EXECUTION_FAILED).
"""


def subscribe(conn, customer, plan_id):
    # TODO: Implement this function
    cur = conn.cursor()
    # Need to parse user's email since apparently the parameter customer is just a string.
    email = customer.split()[-1][1:-1]
    try:
        cur.execute("SELECT * FROM Plan WHERE plan_id = %s;", (plan_id,))
        current_plan = cur.fetchone()
        cur.execute("SELECT plan_id FROM Customer WHERE email = %s;", (email,))
        current_plan_id = cur.fetchone()[0]
        if current_plan == None:
            return None, SUBSCRIBE_PLAN_NOT_FOUND
        else:
            cur.execute("SELECT max_parallel_sessions FROM Plan WHERE plan_id = %s;", (plan_id,))
            new_plan_mps = cur.fetchone()[0]
            cur.execute("SELECT max_parallel_sessions FROM Plan WHERE plan_id = %s;", (current_plan_id,))
            old_plan_mps = cur.fetchone()[0]
            if new_plan_mps >= old_plan_mps:
                cur.execute("UPDATE Customer SET plan_id = %s WHERE email = %s;", (plan_id, email))
                conn.commit()
                return (customer, CMD_EXECUTION_SUCCESS)
            else:
                conn.rollback()
                return (None, SUBSCRIBE_MAX_PARALLEL_SESSIONS_UNAVAILABLE)                  
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)

"""
    Searches for movies with given search_text.
    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.
    - Print all movies whose titles contain given search_text IN CASE-INSENSITIVE MANNER.
    - If the operation is successful; print movies found and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).

    Output should be like:
    Id|Title|Year|Rating|Votes|Watched
    "tt0147505"|"Sinbad: The Battle of the Dark Knights"|1998|2.200000|149|0
    "tt0468569"|"The Dark Knight"|2008|9.000000|2021237|1
    "tt1345836"|"The Dark Knight Rises"|2012|8.400000|1362116|0
    "tt3153806"|"Masterpiece: Frank Millers The Dark Knight Returns"|2013|7.800000|28|0
    "tt4430982"|"Batman: The Dark Knight Beyond"|0|0.000000|0|0
    "tt4494606"|"The Dark Knight: Not So Serious"|2009|0.000000|0|0
    "tt4498364"|"The Dark Knight: Knightfall - Part One"|2014|0.000000|0|0
    "tt4504426"|"The Dark Knight: Knightfall - Part Two"|2014|0.000000|0|0
    "tt4504908"|"The Dark Knight: Knightfall - Part Three"|2014|0.000000|0|0
    "tt4653714"|"The Dark Knight Falls"|2015|5.400000|8|0
    "tt6274696"|"The Dark Knight Returns: An Epic Fan Film"|2016|6.700000|38|0
"""


def search_for_movies(conn, customer, search_text):
    # TODO: Implement this function
    cur = conn.cursor()
    email = customer.split()[-1][1:-1]
    try:
        cur.execute("SELECT * FROM Movies WHERE LOWER(title) LIKE LOWER(%s) ORDER BY movie_id;", (f"%{search_text}%",))
        movies = cur.fetchall()
        print(movies)
        cur.execute("SELECT * FROM Customer WHERE email = %s;", (email,))
        customer_row = cur.fetchone()
        customer_id = customer_row[0]
        print("Id|Title|Year|Rating|Votes|Watched")
        for movie in movies:
            movie_id = movie[0]
            cur.execute("SELECT * FROM Watched WHERE customer_id = %s AND movie_id = %s;", (customer_id, movie_id))
            watched_row = cur.fetchone()
            if watched_row == None:
                print(f"{movie[0]}|{movie[1]}|{movie[2]}|{movie[3]}|{movie[4]}|0")
            else:
                print(f"{movie[0]}|{movie[1]}|{movie[2]}|{movie[3]}|{movie[4]}|1")
        conn.commit()
        return (True, CMD_EXECUTION_SUCCESS)
    except Exception:
        conn.rollback
        return (False, CMD_EXECUTION_FAILED)


"""
    Suggests combination of these movies:
        1- Find customer's genres. For each genre, find movies with most number of votes among the movies that the customer didn't watch.

        2- Find top 10 movies with most number of votes and highest rating, such that these movies are released 
           after 2010 ( [2010, today) ) and the customer didn't watch these movies.
           (descending order for votes, descending order for rating)

        3- Find top 10 movies with votes higher than the average number of votes of movies that the customer watched.
           Disregard the movies that the customer didn't watch.
           (descending order for votes)

    - Return type is a tuple, 1st element is a boolean and 2nd element is the response message from messages.py.    
    - Output format and return format are same with search_for_movies.
    - Order these movies by their movie id, in ascending order at the end.
    - If the operation is successful; print movies suggested and return tuple (True, CMD_EXECUTION_SUCCESS).
    - If any exception occurs; return tuple (False, CMD_EXECUTION_FAILED).
"""


def suggest_movies(conn, customer):
    # TODO: Implement this function
    cur = conn.cursor()
    email = customer.split()[-1][1:-1]
    try:
        cur.execute("SELECT * FROM Customer WHERE email = %s;", (email,))
        customer_row = cur.fetchone()
        customer_id = customer_row[0]
        cur.execute("""
        (WITH movies_customer_watched AS (
            SELECT movie_id
            FROM Watched
            WHERE customer_id = %s),
            genres_customer_watched AS (
            SELECT DISTINCT G.genre_name
            FROM Genres G, Watched W
            WHERE G.movie_id = W.movie_id AND W.customer_id = %s),
            genres_with_votes AS(
            SELECT DISTINCT G.genre_name, MAX(M.votes) AS vote_count
            FROM Genres G, Movies M
            WHERE G.movie_id = M.movie_id AND G.genre_name in (SELECT * FROM genres_customer_watched) AND m.movie_id NOT IN (SELECT * FROM movies_customer_watched)
            GROUP BY G.genre_name)
        SELECT T1.movie_id
        FROM
            (genres_with_votes AS gwv
            LEFT JOIN Movies ON gwv.vote_count = Movies.votes) AS T1
        )
        UNION
        (
        WITH movies_customer_watched AS (
            SELECT movie_id
            FROM Watched
            WHERE customer_id = %s),
            votes_with_ratings AS(
            SELECT M.votes AS vote_count, MAX(M.rating)
            FROM Movies M
            WHERE M.movie_year >= '2010' AND m.movie_id NOT IN (SELECT * FROM movies_customer_watched)
            GROUP BY M.votes
            ORDER BY M.votes DESC
            LIMIT 10)
        SELECT T2.movie_id
        FROM
            (votes_with_ratings AS vwr
            LEFT JOIN Movies ON vwr.vote_count = Movies.votes) AS T2
        ORDER BY vote_count DESC
        )
        UNION
        (
        WITH movies_customer_watched AS (
            SELECT movie_id
            FROM Watched
            WHERE customer_id = %s),
            watched_avg_votes AS (
            SELECT AVG(M.votes) AS vote_count
            FROM Watched W, Movies M
            WHERE W.movie_id = M.movie_id AND W.customer_id = %s)
        SELECT M.movie_id
        FROM Movies M, watched_avg_votes wav
        WHERE M.votes > wav.vote_count AND M.movie_id NOT IN (SELECT * FROM movies_customer_watched)
        ORDER BY M.votes DESC
        );""", (customer_id, customer_id, customer_id, customer_id, customer_id))
        movie_ids = cur.fetchall()
        print("Id|Title|Year|Rating|Votes")
        for movie in movie_ids:
            movie_id = movie[0]
            cur.execute("SELECT * FROM Movies WHERE movie_id = %s;", (movie_id,))
            movie_row = cur.fetchone()
            print(f"{movie_row[0]}|{movie_row[1]}|{movie_row[2]}|{movie_row[3]}|{movie_row[4]}")
        conn.commit()
        return (True, CMD_EXECUTION_SUCCESS)
    except Exception:
        conn.rollback()
        return (False, CMD_EXECUTION_FAILED)
