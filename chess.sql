DROP TABLE IF EXISTS Chessboard;
DROP TABLE IF EXISTS Chessman;

CREATE TABLE IF NOT EXISTS Chessman (
	cid SERIAL PRIMARY KEY,
	type VARCHAR (6) NOT NULL,
	color CHAR (5) NOT NULL,
	CONSTRAINT chk_type CHECK (type in ('king','queen', 'pawn', 'rook', 'bishop', 'knight', 'pawn')),
	CONSTRAINT chk_color CHECK (color in ('white', 'black'))
);

CREATE UNIQUE INDEX chk_unique_king ON Chessman(type, color)
    WHERE (type = 'king' and (color = 'white' or color = 'black'));


INSERT INTO Chessman(type, color) VALUES 
('pawn', 'white'), 
('pawn', 'white'),
('pawn', 'white'),
('pawn', 'white'),
('pawn', 'white'),
('pawn', 'white'),
('pawn', 'white'),
('pawn', 'white'),
('pawn', 'black'),
('pawn', 'black'),
('pawn', 'black'),
('pawn', 'black'),
('pawn', 'black'),
('pawn', 'black'),
('pawn', 'black'),
('pawn', 'black'),
('knight', 'white'),
('knight', 'white'),
('knight', 'black'),
('knight', 'black'),
('bishop', 'white'),
('bishop', 'white'),
('bishop', 'black'),
('bishop', 'black'),
('rook', 'white'),
('rook', 'white'),
('rook', 'black'),
('rook', 'black'),
('queen', 'white'),
('queen', 'black'),
('king', 'white'),
('king', 'black');




CREATE TABLE IF NOT EXISTS Chessboard (
	cid SMALLINT REFERENCES Chessman(cid),
	x CHAR (1) NOT NULL,
	y SMALLINT NOT NULL,
	UNIQUE(x,y),
	CONSTRAINT chk_x CHECK (x in ('a','b', 'c', 'd', 'e', 'f', 'g', 'h')),
	CONSTRAINT chk_y CHECK (y in (1, 2, 3, 4, 5, 6, 7, 8))
);

INSERT INTO Chessboard(cid, x, y) VALUES 
(1,'a',2),
(2,'b',2),
(3,'c',2),
(4,'d',2),
(5,'e',2),
(6,'f',2),
(7,'g',2),
(8,'h',2),
(9,'a',7),
(10,'b',7),
(11,'c',7),
(12,'d',7),
(13,'e',7),
(14,'f',7),
(15,'g',7),
(16,'h',7),

(17,'b',1),
(18,'g',1),
(19,'b',8),
(20,'g',8),

(21,'c',1),
(22,'f',1),
(23,'c',8),
(24,'f',8),

(25,'h',1),
(26,'a',1),
(27,'h',8),
(28,'a',8),

(29,'d',1),
(30,'d',8),

(31,'e',1),
(32,'e',8);



-- 1. Сколько фигур стоит на доске? Вывести количество. 
SELECT count(*) AS exact_count FROM Chessboard;


-- 2. Вывести id фигур, чьи названия начинаются на букву k. 
SELECT cid AS id_starting_k FROM Chessman 
WHERE (substring(type,1,1) = 'k');


-- 3. Какие типы фигур бывают и по сколько штук? Вывести тип и количество. 
SELECT type, COUNT(*) FROM Chessman
GROUP BY type;


-- 4. Вывести  id  белых пешек, стоящих на доске? 
SELECT Chessboard.cid AS id_white_pawn
FROM Chessboard JOIN Chessman ON Chessboard.cid = Chessman.cid 
WHERE Chessman.color = 'white';

-- 5. Какие фигуры стоят на главной диагонали? Вывести их тип и цвет.
SELECT type, color FROM Chessman 
WHERE cid in 
(SELECT cid FROM Chessboard WHERE (x, y) in
 (('a', 1), ('b', 2), ('c', 3), ('d', 4), ('e', 5), ('f', 6), ('g', 7), ('h', 8)));
 
 
-- 6. Найдите общее количество фигур, оставшихся у каждого игрока. Вывести цвет и количество. 
SELECT Chessman.type, Chessman.color, COUNT(*) 
FROM Chessboard JOIN Chessman ON Chessboard.cid = Chessman.cid
GROUP BY Chessman.type, Chessman.color;


-- 7. Какие фигуры черных имеются на доске? Вывести тип. 
SELECT Chessman.type
FROM Chessboard JOIN Chessman ON Chessboard.cid = Chessman.cid and Chessman.color = 'black'
GROUP BY Chessman.type;


-- 8. Какие фигуры черных имеются на доске? Вывести тип и количество. 
SELECT Chessman.type, COUNT(*)
FROM Chessboard JOIN Chessman ON Chessboard.cid = Chessman.cid and Chessman.color = 'black'
GROUP BY Chessman.type;


-- 9. Найдите типы фигур (любого цвета), которых осталось, по крайней мере, не меньше двух на доске. 
SELECT Chessman.type
FROM Chessboard JOIN Chessman ON Chessboard.cid = Chessman.cid
GROUP BY Chessman.type HAVING Count(*) > 1;

-- 10. Вывести цвет фигур, которых на доске больше.
SELECT Chessman.color
FROM Chessboard JOIN Chessman ON Chessboard.cid = Chessman.cid
GROUP BY Chessman.color
ORDER BY COUNT(*) DESC
LIMIT 1

-- 11. Найдите фигуры, которые стоят на возможном пути движения ладьи (rock) (Любой ладьи любого цвета). (Ладья может двигаться по горизонтали или по вертикали относительно своего положения на доске в любом направлении.).  

-- 12. У каких игроков (цвета) еще остались ВСЕ пешки (pawn)? 

-- 13. Пусть отношения board1 и board2 представляют собой два последовательных состояние игры (Chessboard). Какие фигуры (cid) изменили свою позицию (за один ход это может быть передвигаемая фигура и возможно еще фигура, которая была “съедена”)? 

