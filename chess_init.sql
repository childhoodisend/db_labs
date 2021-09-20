DROP TABLE IF EXISTS Chessboard cascade;
DROP TABLE IF EXISTS Chessman;

CREATE TABLE IF NOT EXISTS Chessman
(
	cid serial NOT NULL PRIMARY KEY, 
	type VARCHAR(6) NOT NULL,
    color CHAR(5) NOT NULL,
    CONSTRAINT type_chk CHECK (type in ('king', 'queen', 'rock', 'bishop', 'knight', 'pawn')),
    CONSTRAINT color_chk CHECK (color in ('black', 'white')),
	UNIQUE(type, color)
);

CREATE TABLE IF NOT EXISTS Chessboard
(
	cid smallint NOT NULL REFERENCES Chessman (cid),
    x char NOT NULL,
    y smallint NOT NULL,
    CONSTRAINT x_chk CHECK (x in ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h')),
    CONSTRAINT y_chk CHECK (y in (1, 2, 3, 4, 5, 6, 7, 8)),
	UNIQUE(x, y, cid)
);

