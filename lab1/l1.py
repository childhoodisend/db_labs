import psycopg2
import numpy as np

conn = psycopg2.connect(
    database="db_lab", user='pahpan', password='2000', host='127.0.0.1', port='5432'
)
conn.autocommit = True
cursor = conn.cursor()

types = np.array(['king', 'queen', 'rock', 'bishop', 'knight', 'pawn'])
colors = np.array(['black', 'white'])


def init_chessman_table():
    print("init_chessman_table() called\n")


    cursor.execute('''ALTER SEQUENCE chessman_cid_seq RESTART WITH 1''')
    cursor.execute('''TRUNCATE TABLE chessman CASCADE''')


    for type in types:
        for color in colors:
            cursor.execute('''INSERT INTO CHESSMAN(type, color) VALUES ('{}', '{}')'''.format(type, color))

    conn.commit()
    print("\n")

def init_chessboard_table():
    print("init_chessboard_table() called\n")

    cursor.execute('''TRUNCATE TABLE chessboard CASCADE''')

    cursor.execute('''INSERT INTO Chessboard (cid, x, y) VALUES
    (5,  'a', 8), (9,  'b', 8), (7,  'c', 8), (3,  'd', 8), (1,  'e', 8), (7,  'f', 8), (9,  'g', 8), (5,  'h', 8),
    (11, 'a', 7), (11, 'b', 7), (11, 'c', 7), (11, 'd', 7), (11, 'e', 7), (11, 'f', 7), (11, 'g', 7), (11, 'h', 7),

    (12, 'a', 2), (12, 'b', 2), (12, 'c', 2), (12, 'd', 2), (12, 'e', 2), (12, 'f', 2), (12, 'g', 2), (12, 'h', 2),
    (6,  'a', 1), (10, 'b', 1), (8,  'c', 1), (4,  'd', 1), (2,  'e', 1), (8,  'f', 1), (10, 'g', 1), (6,  'h', 1)''')

    conn.commit()
    print("\n")


def count_all_figures():
    print("count_all_figures() called\n")

    cursor.execute('''SELECT COUNT(*) as count FROM CHESSBOARD''')
    res = cursor.fetchall()
    print("count all = {}".format(res[0][0]))

    conn.commit()
    print("\n")


def named_from_k():
    print("named_from_k() called\n")

    cursor.execute('''SELECT * FROM CHESSMAN WHERE TYPE LIKE 'k%' ''')
    result = cursor.fetchall()
    cids = [row[0] for row in result]
    names = [row[1] for row in result]
    print("names from 'k' = {}".format(names))

    for cid in cids:
        cursor.execute('''SELECT COUNT(*) FROM CHESSBOARD WHERE CID={}'''.format(cid))
        res = cursor.fetchall()
        print("cid = {}, count = {}".format(cid, res[0][0]))

    conn.commit()
    print("\n")


def types_and_count():
    print("types_and_count() called\n")

    cursor.execute('''SELECT * FROM CHESSMAN''')
    result = cursor.fetchall()
    cids = [row[0] for row in result]

    print("all cids = {}".format(cids))

    for cid in cids:
        cursor.execute('''SELECT COUNT(*) FROM CHESSBOARD WHERE CID={}'''.format(cid))
        result = cursor.fetchall()
        print("cid = {}, count = {}".format(cid, result[0][0]))

    conn.commit()
    print("\n")


def l1():

    init_chessman_table()
    init_chessboard_table()

    # a
    count_all_figures()

    # b
    named_from_k()

    # c
    types_and_count()

    conn.close()
