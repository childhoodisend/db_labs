-- #1
create or replace function add_exam(_exam char(64), _credit char(64)) returns int as $$
declare
    id_ex int;
    id_credit int;
    exam_subj int = (select id from subjects where name=_exam);
    credit_subj int = (select id from subjects where name=_credit);
    depend_exam int = (select subject_id from dependencies join subjects on subjects.name = _exam);
    depend_credit int = (select depends_of from dependencies join subjects on subjects.name = _credit);
begin

    if(exam_subj is null) then
        id_ex = (select count(*) from subjects) + 1;
        insert into subjects(id, name, type) values (cast(id_ex as int), _exam, 'exam');
    end if;

    if(credit_subj is null) then
        id_credit = (select count(*) from subjects) + 1;
        insert into subjects(id, name, type) values (cast(id_credit as int), _credit, 'credit');
    end if;

    if(depend_exam is null and depend_credit is null) then
        insert into dependencies(subject_id, depends_of, is_required) values (id_ex, id_credit, true);
    end if;

    if(id_ex is not null) then
        return id_ex;
    else
        return 0;
    end if;


end;
$$ language plpgsql;

select add_exam('TEST EXAM', 'TEST CREDIT');



-- #2
create or replace function transfer(book int, group_id_last int, group_id_new int) returns table(subject_id int) as $$
declare
    cnt_same_subj int = (select count(distinct group_subj.subject_id) from group_subj where group_id in (group_id_last, group_id_new) and is_required=true);
    cnt_subj_new_all int = (select count(group_subj.subject_id) from group_subj where group_id in (group_id_new));
    cnt_subj_new_req int = (select count(group_subj.subject_id) from group_subj where group_id in (group_id_new) and is_required=true);
begin
    if(abs(cnt_subj_new_req - cnt_same_subj) <= 0.1 * cnt_subj_new_all) then
        raise notice 'OK';
        return query (select group_subj.subject_id from group_subj where group_subj.subject_id not in (select group_subj.subject_id from group_subj where group_id=group_id_last and is_required=true) and group_id=group_id_new);
    else
        raise notice 'can not transfer to (%)', group_id_new;
    end if;
end;
$$ language plpgsql;

insert into students(id, firstname, middle_name, lastname, book, group_id) values (26, 'Test', 'Test', 'Test', 1488, 228); -- -> 229
insert into group_subj(group_id, subject_id, is_required) values (228, 1, true), (228, 2, true), (228, 3, false);
insert into group_subj(group_id, subject_id, is_required) values (229, 1, true), (229, 2, true), (229, 3, true), (229, 4, true);
select transfer(1488, 228, 229);


-- #3
create or replace function check_passed(_group_id int, _new_group_id int) returns int as $$
declare
    req_subj_cnt int = (select count(*) from group_subj where group_subj.group_id=_group_id and is_required=true);
    ids int[];
begin
    ids := array((select sic.student_id
           from (select student_id, count(*) as cnt
                 from results join students s on results.student_id = s.id
                 where group_id = _group_id
                   and results.status = 'passed'
                   and results.is_required = true
                 group by student_id) as sic where cnt=req_subj_cnt));

    for i in 1..array_length(ids, 1) loop
        raise notice 'can not transfer to (%)', ids[i];
        update students set group_id=_new_group_id where students.id=ids[i];
    end loop;


    return array_length(ids, 1);
end;
$$ language plpgsql;


insert into students(id, firstname, middle_name, lastname, book, group_id) values (27, 'Test1', 'Test1', 'Test1', 1489, 228);
insert into results(student_id, subject_id, attempt, status, is_required) values (26, 1, 1, 'passed', true), (26, 2, 1, 'passed', true);
insert into results(student_id, subject_id, attempt, status, is_required) values (27, 1, 1, 'passed', true), (27, 2, 1, 'passed', true), (27, 3, 2, 'passed', false);
select check_passed(228, 333);
drop function check_passed;