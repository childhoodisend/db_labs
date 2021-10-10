-- 1 Сколько фигур стоит на доске? Вывести количество
SELECT COUNT(*) as count FROM CHESSBOARD;


-- 2 Вывести id фигур, чьи названия начинаются на букву k.
SELECT * FROM CHESSMAN WHERE TYPE LIKE 'k%';


-- 3 Какие типы фигур бывают и по сколько штук? Вывести тип и количество.
SELECT type, count(*) from chessman group by type;


-- 4 Вывести  id  белых пешек , стоящих на доске?
SELECT uid from chessboard where cid=12;


-- 5 Какие фигуры стоят на главной диагонали? Вывести их тип и цвет.
select type, color from chessman where cid in (select cid from chessboard where (x, y) in (('a', 1), ('b', 2), ('c', 3), ('d', 4), ('e', 5), ('f', 6), ('g', 7), ('h', 8)));


-- 6 Найдите общее количество фигур, оставшихся у каждого игрока. Вывести цвет и количество.
select color, count(*) from chessman join chessboard on chessman.cid = chessboard.cid group by color;


-- 7 Какие фигуры черных имеются на доске? Вывести тип.
select type from chessman where cid in (select cid from chessboard where cid in (1, 3, 5, 7, 9, 11));
--select type from chessman join chessboard c on chessman.cid = c.cid and chessman.color='black' group by type;


-- 8 Какие фигуры черных имеются на доске? Вывести тип и количество.
select type, count(*) from chessman join chessboard c on chessman.cid = c.cid and chessman.color='black' group by type;


-- 9 Найдите типы фигур (любого цвета), которых осталось, по крайней мере, не меньше двух на доске.
select type, count(*) from chessman join chessboard c on chessman.cid = c.cid group by type having count(c.cid) > 2;


-- 10 Вывести цвет фигур, которых на доске больше.
-- select color, count(*) as cnt from chessboard as c join chessman on chessman.cid = c.cid group by color order by cnt desc limit 1;
select color from chessboard join chessman on chessboard.cid = chessman.cid group by color
having count(*) = (select MAX(cnt) from (select count(*) as cnt from chessboard join chessman on chessboard.cid = chessman.cid group by color) as tabl);


-- 11 Найдите фигуры, которые стоят на возможном пути движения ладьи (rock) (Любой ладьи любого цвета). (Ладья может двигаться по горизонтали или по вертикали относительно своего положения на доске в любом направлении.).
select * from chessboard where x in (select x from chessboard where cid in (5, 6)) OR y in (select y from chessboard where cid in (5, 6));


-- 12 У каких игроков (цвета) еще остались ВСЕ пешки (pawn)?
select color from chessboard join chessman on chessboard.cid = chessman.cid group by color, chessman.type having count(chessman.cid) = 8 AND chessman.type = 'pawn';


-- 13 Пусть отношения board1 и board2 представляют собой два последовательных состояние игры (Chessboard). Какие фигуры (cid) изменили свою позицию (за один ход это может быть передвигаемая фигура и возможно еще фигура, которая была “съедена”)?
DROP TABLE IF EXISTS board1, board2;
SELECT * INTO board1 FROM chessboard;
SELECT * INTO board2 FROM chessboard;
DELETE FROM board2 WHERE cid = 11 and (x, y) = ('a', 7); -- pawn black delete
UPDATE board2 SET y = 7 WHERE x = 'a' and cid = 6; -- rock black move to ('a', 7)
SELECT * FROM board1;
SELECT * from board2;
DROP TABLE board1, board2;

-- 14 Вывести id фигуры, если она стоит в «опасной близости» от черного короля? «опасной близостью» будем считать квадрат 5х5 с королем в центре.
select uid from chessboard join chessman on chessboard.cid = chessman.cid where
    ABS(y - (select y
    from chessboard join chessman on chessboard.cid = chessman.cid
    where chessman.color = 'black' AND chessman.type = 'king'
    )) <= 2
AND
    ABS(ASCII(x) - (select ASCII(x)
    from chessboard join chessman on chessboard.cid = chessman.cid
    where chessman.color = 'black' AND chessman.type = 'king'
    )) <= 2
AND
    NOT(chessman.color = 'black' AND chessman.type = 'king');


-- 15 Найти фигуру, ближе всех стоящую к белому королю (расстояние считаем по метрике L1 – разница координат по X + разница координат по Y.
drop table if exists all_info;
select chessboard.cid, x, y, color, type into all_info from (chessboard join chessman on chessboard.cid = chessman.cid);
select * from all_info; -- create all info table

select ai1.cid FROM all_info as ai1, all_info as ai2 where ai2.type = 'king' AND ai2.color = 'white' AND ABS(ai1.y - ai2.y) + ABS(ASCII(ai1.x) - ASCII(ai2.x)) =
(select MIN(ABS(ai1.y - ai2.y) + ABS(ASCII(ai1.x) - ASCII(ai2.x))) from all_info as ai1, all_info as ai2 where (ai2.type = 'king' and ai2.color = 'white') and (ai1.type != 'king' or ai1.color != 'white'));

drop table all_info;
