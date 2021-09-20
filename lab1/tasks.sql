-- Сколько фигур стоит на доске? Вывести количество
SELECT COUNT(*) as count FROM CHESSBOARD;

-- Вывести id фигур, чьи названия начинаются на букву k.
SELECT * FROM CHESSMAN WHERE TYPE LIKE 'k%';

-- Какие типы фигур бывают и по сколько штук? Вывести тип и количество.

SELECT type, count(*) from chessman group by type;

-- Вывести  id  белых пешек , стоящих на доске?

SELECT uid from chessboard where cid=12;

-- Какие фигуры стоят на главной диагонали? Вывести их тип и цвет.
select type, color from chessman where cid in (select cid from chessboard where (x, y) in (('a', 1), ('b', 2), ('c', 3), ('d', 4), ('e', 5), ('f', 6), ('g', 7), ('h', 8)));

-- Найдите общее количество фигур, оставшихся у каждого игрока. Вывести цвет и количество.
select color, count(*) from chessman join chessboard on chessman.cid = chessboard.cid group by color;

-- Какие фигуры черных имеются на доске? Вывести тип.

select type from chessman where cid in (select cid from chessboard where cid in (1, 3, 5, 7, 9, 11));
-- select type from chessman join chessboard c on chessman.cid = c.cid and chessman.color='black' group by type;

-- Какие фигуры черных имеются на доске? Вывести тип и количество.
select type, count(*) from chessman join chessboard c on chessman.cid = c.cid and chessman.color='black' group by type;

-- Найдите типы фигур (любого цвета), которых осталось, по крайней мере, не меньше двух на доске.
select type, count(*) from chessman join chessboard c on chessman.cid = c.cid group by type having count(c.cid) > 2;


-- Вывести цвет фигур, которых на доске больше.

select color, count(*) as cnt from chessboard as c join chessman on chessman.cid = c.cid group by color order by cnt desc limit 1;

-- Найдите фигуры, которые стоят на возможном пути движения ладьи (rock) (Любой ладьи любого цвета). (Ладья может двигаться по горизонтали или по вертикали относительно своего положения на доске в любом направлении.).

-- У каких игроков (цвета) еще остались ВСЕ пешки (pawn)?

-- Пусть отношения board1 и board2 представляют собой два последовательных состояние игры (Chessboard). Какие фигуры (cid) изменили свою позицию (за один ход это может быть передвигаемая фигура и возможно еще фигура, которая была “съедена”)?

-- Вывести id фигуры, если она стоит в «опасной близости» от черного короля? «опасной близостью» будем считать квадрат 5х5 с королем в центре.

-- Найти фигуру, ближе всех стоящую к белому королю (расстояние считаем по метрике L1 – разница координат по X + разница координат по Y.

