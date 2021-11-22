-- #1
-- Написать функцию для занесения в базу данных информации об экзамене.
-- Входные параметры: название экзамена, название семинара, который является необходимым для сдачи этого экзамена.
-- Функция должна вернуть id нового экзамена, в случае если он был успешно создан.
-- Перед добавлением экзамена необходимо проверить, занесена ли в базу информация о необходимом семинаре.
-- В случае если нет – добавить сначала семинар. Добавить связь между экзаменом и семинаром в таблицу ExamRequirements1.


create or replace function add_exam(_exam char(64), _credit char(64)) returns int as $$
declare
    id_ex int;
    id_credit int;
    exam_subj int = (select id from subjects where name=_exam and type='exam');
    credit_subj int = (select id from subjects where name=_credit and type='credit');
    depend_exam int = (select subject_id from dependencies join subjects on  subject_id=id and subjects.name = _exam);
    depend_credit int = (select depends_of from dependencies join subjects on subject_id=id and subjects.name = _credit);
begin
    if(exam_subj is not null and credit_subj is not null) then
        raise notice 'add_exam() exam_subj is not null and credit_subj is not null';
        return exam_subj;
    end if;

    if(exam_subj is null) then
        raise notice 'add_exam() exam_subj is null';
        id_ex = (select count(*) from subjects) + 1;
        insert into subjects(id, name, type) values (cast(id_ex as int), _exam, 'exam');
    end if;

    if(credit_subj is null) then
        raise notice 'add_exam() credit_subj is null';
        id_credit = (select count(*) from subjects) + 1;
        insert into subjects(id, name, type) values (cast(id_credit as int), _credit, 'credit');
    end if;

    if(depend_exam is null and depend_credit is null) then
         raise notice 'add_exam() depend_exam is null and depend_credit is null';

         if (id_ex is null) then
             raise notice 'add_exam() id_ex is null';
             id_ex = exam_subj;
         end if;

         if (id_credit is null) then
             raise notice 'add_exam() id_credit is null';
             id_credit = credit_subj;
         end if;

        insert into dependencies(subject_id, depends_of, is_required) values (id_ex, id_credit, true);
    end if;

    if(id_ex is not null) then
        return id_ex;
    else
        return 0;
    end if;
end; $$ language plpgsql;

select add_exam('test_add_exam', 'test_add_exam');


-- #2
-- Написать функцию для перевода студента из группы в группу.
-- Функция должна вернуть таблицу из экзаменов, которые необходимо сдать студенту, чтобы ликвидировать разницу в программе.
-- Входные параметры: номер зачетной книжки студента, старый и новый номера группы. Студент может быть переведен из группы
-- в группу, если разница в программе (количество обязательных семинаров и экзаменов для новой группы по сравнению с
-- количеством обязательных семинаров и экзаменов в старой) составляет не более 10% от общего количества семинаров и
-- экзаменов новой группы. Если разница превышает этот порог, должно быть возвращено исключение.

create or replace function transfer(book_ int, group_id_last int, group_id_new int) returns table(subject_id int) as $$
declare
    cnt_same_subj int = (select count(distinct group_subj.subject_id) from group_subj where group_id in (group_id_last, group_id_new) and is_required=true);
    cnt_subj_new_all int = (select count(group_subj.subject_id) from group_subj where group_id in (group_id_new));
    cnt_subj_new_req int = (select count(group_subj.subject_id) from group_subj where group_id in (group_id_new) and is_required=true);
    st_id int = (select id from students where students.book=book_);
begin
    if(group_id_last in (select group_id from st_groups)) then
        if(abs(cnt_subj_new_req - cnt_same_subj) <= 0.1 * cnt_subj_new_all) then
            raise notice 'transfer() : can transfer';
            update students set group_id = group_id_new where id = st_id;
            return query (select group_subj.subject_id from group_subj where group_subj.subject_id not in (select group_subj.subject_id from group_subj where group_id=group_id_last and is_required=true) and group_id=group_id_new);
        else
            raise notice 'transfer() : can not transfer to (%)', group_id_new;
        end if;
    else
        raise notice 'transfer() : group_id_new = (%) does not exist', group_id_last;
    end if;

end;
$$ language plpgsql;

insert into students(id, firstname, middle_name, lastname, book, group_id) values (25, 'Test_transfer', 'Test_transfer', 'Test_transfer', 1488, 228); -- -> 229
insert into group_subj(group_id, subject_id, is_required) values (228, 1, true), (228, 2, true), (228, 3, false);
insert into group_subj(group_id, subject_id, is_required) values (229, 1, true), (229, 2, true), (229, 3, true), (229, 4, true);
select transfer(1488, 228, 229);

-- Transferred student with 1488 book from 228 to 229 group

-- #3
-- Написать процедуру для перевода всех студентов, успешно сдавших все обязательные экзамены на следующий курс.
-- Входные параметры: текущий номер группы, номер группы на следующем курсе.
-- Выходной параметр: количество переведенных студентов.


create or replace function check_passed(_group_id int, _new_group_id int) returns int as $$
declare
    req_subj_cnt int = (select count(*) from group_subj where group_subj.group_id=_group_id and is_required=true);
    ids int[];
begin
    if(_group_id in (select group_id from st_groups)) then
        ids := array((select sic.student_id
               from (select student_id, count(*) as cnt
                     from results join students s on results.student_id = s.id
                     where group_id = _group_id
                       and results.status = 'passed'
                       and results.is_required = true
                     group by student_id) as sic where cnt=req_subj_cnt));

        if(array_length(ids,1) > 0) then
        for i in 1..array_length(ids, 1) loop
            raise notice 'check_passed() : transfer (%) from (%) to (%)', ids[i], _group_id, _new_group_id;
            update students set group_id=_new_group_id where students.id=ids[i];
        end loop;
        return array_length(ids, 1);
        else
             raise notice 'check_passed() : array is empty';
             return 0;
        end if;
    else
        raise notice 'check_passed() : _group_id = (%) does not exist', _group_id;
        return 0;
    end if;
end;
$$ language plpgsql;

insert into students(id, firstname, middle_name, lastname, book, group_id) values (26, 'Test_check_passed', 'Test_check_passed', 'Test_check_passed', 1489, 228);
insert into students(id, firstname, middle_name, lastname, book, group_id) values (27, 'Test_check_passed', 'Test_check_passed', 'Test_check_passed', 1490, 228);
insert into students(id, firstname, middle_name, lastname, book, group_id) values (28, 'Test_check_passed', 'Test_check_passed', 'Test_check_passed', 1491, 228);


insert into results(student_id, subject_id, attempt, status, is_required) values (26, 1, 1, 'passed', true), (26, 2, 1, 'passed', true);
insert into results(student_id, subject_id, attempt, status, is_required) values (27, 1, 1, 'passed', true), (27, 2, 1, 'passed', true), (27, 3, 2, 'passed', false);
insert into results(student_id, subject_id, attempt, status, is_required) values (28, 1, 1, 'failed', true), (28, 2, 1, 'failed', true);

select check_passed(228, 333);

-- 26, 27 were transferred, 28 was not