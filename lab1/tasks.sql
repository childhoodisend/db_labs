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

-- TASK 3

-- 1 Процедура – «сделать ход». Параметры - идентификатор фигуры и новые координаты (для одного типа фигуры). Проверить, соответствует ли ход правилам, и если да, то сделать ход.


create or replace function one_step_pawn(x_next char, y_next smallint) returns boolean
language plpgsql
as $$
declare
    figure_cid smallint = (select cid from chessboard as c where c.x = x_next and c.y = y_next);
begin
    if (figure_cid is null) then
        return true;
    else
        return false;
    end if;
end;
$$;

create or replace function two_step_pawn(x_next char, y_next smallint) returns boolean
language plpgsql
as $$

declare
    figure_cid smallint = (select cid from chessboard as c where c.x = x_next and c.y = y_next);
begin

    if (one_step_pawn(x_next, cast(y_next - 1 as smallint)) and figure_cid is null) then
        return true;
    else
        return false;
    end if;

end;
$$;

create or replace procedure pawn_move(_uid smallint, _x char, _y smallint)
language plpgsql
as $$
declare
    x_cur char = (select x from chessboard as c where c.uid = _uid);
    y_cur smallint = (select y from chessboard as c where c.uid = _uid);
    cid_cur smallint = (select cid from chessboard as c where c.uid = _uid);
begin
    if cid_cur in (11 , 12) then
        if (x_cur = _x and y_cur + 1 = _y) then
            if (one_step_pawn( _x, _y)) then
                update chessboard as c set x = _x, y = _y where c.x = x_cur and c.y = y_cur;
                return;
            end if;
        end if;
        if (x_cur = _x and y_cur + 2 = _y) then
            if (two_step_pawn( _x, _y)) then
                update chessboard as c set x = _x, y = _y where c.x = x_cur and c.y = y_cur;
                return;
            end if;
        end if;

        if (ascii(x_cur) + 1 = ascii(_x) and y_cur + 1 = _y) then
            call pawn_eat(cast(_uid as smallint), cast(_x as char), cast(_y as smallint));
            return;
        end if;

    else
        raise notice 'is not pawn! ';
    end if;
end;
$$;


create or replace procedure pawn_eat(_uid smallint, _x char, _y smallint)
language plpgsql
as $$
declare
    color_enemy char(5) = (select color from chessboard c join chessman on chessman.cid = c.cid and c.x = _x and c.y = _y and c.uid <> _uid);
    color_cur char(5) = (select color from chessboard c join chessman on chessman.cid = c.cid and c.x = _x and c.y = _y and c.uid = _uid);
    x_cur char = (select x from chessboard as c where c.uid = _uid);
    y_cur smallint = (select y from chessboard as c where c.uid = _uid);
begin
    if (color_enemy is not null) then
        if (color_cur = color_enemy) then
            raise notice 'the same colors! can not eat friend';
            return;
        else
            if (ascii(x_cur) + 1 = ascii(_x) and y_cur + 1 = _y) then
                delete from chessboard where x = _x and y = _y;
                update chessboard as c set x = _x, y = _y where c.x = x_cur and c.y = y_cur;
            end if;
        end if;
    else
        raise notice 'nothing to eat';
    end if;

end;
$$;



-- simple move case:
insert into chessboard (cid, x, y) values (12, 'b', 4);
call pawn_move(cast(17 as smallint), cast('a' as char), cast(3 as smallint)); --pawn (a, 2) -> (a, 3)
call pawn_move(cast(17 as smallint), cast('b' as char), cast(4 as smallint)); --pawn (a, 2) -> (a, 3)
update chessboard set x = 'a', y = 2 where uid = 17; -- return pawn to start point


-- drop procedure pawn_move(_uid smallint, _x char, _y smallint);
-- drop function one_step_pawn(_uid smallint, x_prev char, y_prev smallint, x_next char, y_next smallint);
-- drop function two_step_pawn(_uid smallint, x_prev char, y_prev smallint, x_next char, y_next smallint);


-- eat case :
insert into chessboard (cid, x, y) values (12, 'b', 3);
call pawn_eat(cast(17 as smallint), cast('b' as char), cast(3 as smallint)); -- pawn (a, 3) eat pawn (b, 4)
update chessboard set x = 'a', y = 2 where uid = 17; -- return pawn to start point
-- drop procedure pawn_eat(_uid smallint, _x char, _y smallint);


-- 2 Триггер1 на изменение положения фигуры. Если мы ходим на клетку, где стоит фигура другого цвета, то «съесть» ее, если своего, то такой ход делать нельзя.
create or replace function pawn_triggered() returns trigger as
$$
declare
    pawn_clr char(5);
begin
    RAISE NOTICE 'trigger worked';
    RAISE NOTICE 'found change in % % %',new.cid, new.x, new.y ;
select color into pawn_clr from chessman where chessman.cid = cid;
case
    when exists (select c.cid from chessboard as c join chessman as ch on c.cid = ch.cid where  c.x = new.x and c.y = NEW.y and c.cid != new.cid and ch.color != pawn_clr) then
        raise notice 'enemy!';
        delete from chessboard as r WHERE r.x = NEW.x and r.y = new.y and r.cid != new.cid;
        return new;
    when exists (select c.cid FROM chessboard as c join chessman as ch on c.cid = ch.cid where  c.x = new.x and c.y = new.y and c.cid != new.cid and ch.color = pawn_clr) then
        raise notice 'not enemy!';
        return old;
    else
        return new;
end case;
end;
$$ language plpgsql;


create trigger pawn_move before update on chessboard for each row when (old.x is distinct from new.x  or  old.y is distinct from new.y) execute procedure pawn_triggered();
-- drop trigger if exists pawn_move on chessboard;
call pawn_move(cast(17 as smallint), cast('a' as char), cast(3 as smallint)); --pawn (a, 2) -> (a, 3)
update chessboard set x = 'a', y = 2 where uid = 17; -- return pawn to start point

-- 3 Триггер2 – вести файл, в который записываются все ходы.

CREATE TABLE IF NOT EXISTS LOGTABLE
(
    cid smallint NOT NULL,
    x_old char NOT NULL,
    x_new char NOT NULL,
    y_old smallint NOT NULL,
    y_new smallint NOT NULL,
    CONSTRAINT x_old_chk CHECK (x_old in ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h')),
    CONSTRAINT x_new_chk CHECK (x_new in ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h')),
    CONSTRAINT y_old_chk CHECK (y_old in (1, 2, 3, 4, 5, 6, 7, 8)),
    CONSTRAINT y_new_chk CHECK (y_new in (1, 2, 3, 4, 5, 6, 7, 8))
);

create or replace function logger() returns trigger
language plpgsql as $$
begin
    if (new.x <> old.x and new.y <> old.y) then
        insert into LOGTABLE (cid, x_old, x_new, y_old, y_new) values(old.cid, old.x, new.x, old.y, new.y);
        return new;
    end if;
    if (new.x <> old.x) then
        insert into LOGTABLE (cid, x_old, x_new, y_old, y_new) values(old.cid, old.x, new.x, old.y, old.y);
        return new;
    end if;
    if (new.y <> old.y) then
        insert into LOGTABLE (cid, x_old, x_new, y_old, y_new) values(old.cid, old.x, old.x, old.y, new.y);
        return new;
    end if;
    return old;

end;
$$;

create trigger log_update after update on chessboard for each row execute procedure logger();
-- drop trigger if exists log_update on chessboard;

update chessboard set x = 'a', y = 2 where uid = 17; -- return pawn to ('a', 2) point
call pawn_move(cast(17 as smallint), cast('a' as char), cast(3 as smallint)); --pawn (a, 2) -> (a, 3)
