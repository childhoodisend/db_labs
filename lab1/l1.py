import psycopg2
import numpy as np

conn = psycopg2.connect(
    database="db_lab", user='postgres', password='root', host='127.0.0.1', port='5432'
)
conn.autocommit = True
cursor = conn.cursor()

types = np.array(['king', 'queen', 'rock', 'bishop', 'knight', 'pawn'])
colors = np.array(['black', 'white'])


def init_chessman_table():
    print("init_chessman_table() called\n")

    cid = 1
    for type in types:
        for color in colors:
            cursor.execute('''INSERT INTO CHESSMAN(cid, type, color) VALUES ({},'{}', '{}')'''.format(cid, type, color))
            cid += 1

    conn.commit()
    print("\n")


def init_chessboard_table():
    print("init_chessboard_table() called\n")

    x = np.fromiter((i for i in range(8)), dtype=int)
    y = x
    cids = np.fromiter((i for i in range(1, 13, 1)), dtype=int)
    for xx in x:
        for yy in y:
            for cid in cids:
                cursor.execute('''INSERT INTO CHESSBOARD(cid, x, y) VALUES ({}, {}, {})'''.format(cid, xx, yy))

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
    # init_chessman_table()
    # init_chessboard_table()

    # a
    count_all_figures()

    # b
    named_from_k()

    # c
    types_and_count()

    conn.close()
