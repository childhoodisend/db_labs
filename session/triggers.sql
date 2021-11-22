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
    if (amount is null) then
        raise notice 'delete_dep() amount is null';
        return old;
    else

        raise notice 'delete_dep() delete cnt_of_req [%] / amount [%]', cnt_of_req, amount;
        if (amount < cnt_of_req) then
            raise notice 'delete_dep() delete';
            return old;
        else
            raise notice 'delete_dep() skip';
            return new;
        end if;

    end if;
end;
$tr$ language plpgsql;

create trigger del_dep before delete on dependencies for each row execute procedure delete_dep();

-- TEST
insert into dependencies (subject_id, depends_of, is_required) values (101, 99, true);
delete from dependencies where subject_id=101 and depends_of=102;
-- TEST



-- 2.2 Создать триггер на удаление студента. При удалении студента проверять, остались ли еще студенты в его группе.
-- Если студентов больше не осталось, удалить группу.


create or replace view st_groups as (select distinct group_id from students); -- all st groups


create or replace function delete_st_group() returns trigger AS $tr$
declare
    st_cnt int = (select count(*) from st_groups join students s on st_groups.group_id = s.group_id where st_groups.group_id=old.group_id);
    gr_id int = (select group_id from st_groups where st_groups.group_id=old.group_id);
begin

    raise notice 'delete_st() : st_cnt (%), gr_id (%)', st_cnt, gr_id;

    if(st_cnt = 1) then
        raise notice 'delete_st() : can delete';
        delete from st_groups where group_id=gr_id;
        return old;
    else
        raise notice 'delete_st() : st group is not deleted';
        return old;
    end if;

end; $tr$ language plpgsql;

create trigger del_st_gr before delete on students for each row execute procedure delete_st_group();

create or replace function delete_st_results() returns trigger AS $tr$
begin


    raise notice 'delete_st_results() : delete results for (%)', old.id;
    delete from results where student_id=old.id;
    return old;

end; $tr$ language plpgsql;

create trigger del_st_res before delete on students for each row execute procedure delete_st_results();


-- TEST
insert into students(id, firstname, middle_name, lastname, book, group_id) values (25, 'NAME1', 'MNAME1', 'LNAME1', 125, 12);
insert into results (student_id, subject_id, attempt, status, is_required) values (25, 18, '1', 'need', 'true');
insert into students(id, firstname, middle_name, lastname, book, group_id) values (26, 'NAME2', 'MNAME2', 'LNAME2', 126, 12);
insert into results (student_id, subject_id, attempt, status, is_required) values (26, 18, '1', 'need', 'true');
insert into students(id, firstname, middle_name, lastname, book, group_id) values (27, 'NAME3', 'MNAME3', 'LNAME3', 127, 12);
insert into results (student_id, subject_id, attempt, status, is_required) values (27, 18, '1', 'need', 'true');

delete from students where students.id in (25, 26, 27);
-- TEST


create or replace rule delete_st_group_rule as on delete to st_groups
do instead select distinct group_id from students where group_id <> old.group_id;