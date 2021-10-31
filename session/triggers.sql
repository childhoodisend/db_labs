-- 2.1 Создать триггер на удаление зависимости экзамена от семинара.
-- При удалении зависимости, необходимо проверять, что количество всех обязательных семинаров для экзамена
-- не станет меньше, чем минимальное допустимое количество необходимых семинаров для экзамена, и удалять
-- только в том случае, если остается достаточное количество семинаров.


create table if not exists exam_req_amount
(
  subject_id int not null references subjects(id),
  amount int not null default 0,

  unique (subject_id, amount)
);
insert into exam_req_amount(subject_id, amount) values (53, 2);


create or replace function delete_dep() returns trigger AS $tr$
declare
    cnt_of_req int = (select count(*) from dependencies where subject_id=old.subject_id);
    amount int = (select amount from exam_req_amount where subject_id=old.subject_id);

begin
    raise notice 'delete cnt_of_req [%] / amount [%]', cnt_of_req, amount;

    if (amount < cnt_of_req) then
        raise notice 'delete';
        return old;
    else
        raise notice 'skip';
        return new;
    end if;
end;
$tr$ language plpgsql;


create trigger del_dep before delete on dependencies for each row execute procedure delete_dep();
insert into dependencies (subject_id, depends_of, is_required) values (53, 6, true);

delete from dependencies where subject_id=53 and depends_of=5;
drop function if exists delete_dep() cascade;

-- 2.2 Создать триггер на удаление студента. При удалении студента проверять, остались ли еще студенты в его группе.
-- Если студентов больше не осталось, удалить группу.


create table students_copy as (select * from students);
create table st_groups as (select distinct group_id from students);
create or replace function delete_st() returns trigger AS $tr$
declare
    st_cnt int = (select count(*) from st_groups join students_copy s on st_groups.group_id = s.group_id where st_groups.group_id=old.group_id);
    gr_id int = (select group_id from st_groups where st_groups.group_id=old.group_id);
begin

    raise notice 'st_cnt (%), gr_id (%)', st_cnt, gr_id;

    if(st_cnt = 0) then
        raise notice 'st_cnt (%), gr_id (%) : can delete', st_cnt, gr_id;
        delete from st_groups where group_id=gr_id;
        return new;
    else
        raise notice 'nothing to delete';
        return old;
    end if;

end;
$tr$ language plpgsql;


create trigger del_st after delete on students_copy for each row execute procedure delete_st();
insert into students_copy(id, firstname, middle_name, lastname, book, group_id) values (27, 'testtt', 'tsdsdt', 'sdfds', 2124, 1);
insert into st_groups(group_id) values (1);
delete from students_copy where id=24;

select count(*) from st_groups join students_copy s on st_groups.group_id = s.group_id where st_groups.group_id=1;
