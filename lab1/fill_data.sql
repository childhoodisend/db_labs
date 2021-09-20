TRUNCATE TABLE Chessboard;
TRUNCATE TABLE Chessman CASCADE;
ALTER SEQUENCE chessman_cid_seq RESTART WITH 1;
ALTER SEQUENCE chessboard_uid_seq RESTART WITH 1;


INSERT INTO Chessman (type, color) VALUES
('king',	'black'), -- 1
('king', 	'white'), -- 2
('queen', 	'black'), -- 3
('queen', 	'white'), -- 4
('rock', 	'black'), -- 5  ладья
('rock', 	'white'), -- 6
('bishop', 	'black'), -- 7  слон
('bishop', 	'white'), -- 8
('knight', 	'black'), -- 9  конь
('knight', 	'white'), -- 10 
('pawn', 	'black'), -- 11 пешка
('pawn', 	'white'); -- 12


INSERT INTO Chessboard (cid, x, y) VALUES

(5,  'a', 8), (9,  'b', 8), (7,  'c', 8), (3,  'd', 8), (1,  'e', 8), (7,  'f', 8), (9,  'g', 8), (5,  'h', 8),
(11, 'a', 7), (11, 'b', 7), (11, 'c', 7), (11, 'd', 7), (11, 'e', 7), (11, 'f', 7), (11, 'g', 7), (11, 'h', 7),


(12, 'a', 2), (12, 'b', 2), (12, 'c', 2), (12, 'd', 2), (12, 'e', 2), (12, 'f', 2), (12, 'g', 2), (12, 'h', 2),
(6,  'a', 1), (10, 'b', 1), (8,  'c', 1), (4,  'd', 1), (2,  'e', 1), (8,  'f', 1), (10, 'g', 1), (6,  'h', 1);
