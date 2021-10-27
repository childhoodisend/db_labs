-- 1 Выбрать всех студентов из одной группы упорядочив по ФИО.
select * from students where group_id = 431 order by firstname;


-- 2 Упорядочить сданные кем-либо экзамены по числу сдавших.

create or replace view exam_passed as (select * from results join subjects s on results.subject_id = s.id where type = 'exam' and results.status = 'passed');
select subject_id, count(*) as passed_amount from exam_passed group by subject_id order by passed_amount;


-- 3 Каково число студентов, не получивших ни одного зачета?
create or replace view credit_passed as (select * from results join subjects s on results.subject_id = s.id where type = 'credit' and results.status = 'passed');
select count(*) from students where id not in (select student_id from credit_passed);


-- 4 Найти самую малочисленную группу. Найти студента, сдавшего больше всех экзаменов
select group_id, count(*) as cnt from students group by group_id order by cnt limit 1;
select student_id, count(*) as cnt from exam_passed group by student_id order by cnt desc limit 1;


-- 5 Найти всех студентов, сдавших все обязательные экзамены с хотя бы одним несданным зачетом
create or replace view credit_failed as (select * from results join subjects s on results.subject_id = s.id where type = 'credit' and results.status = 'failed');
create or replace view exam_passed_is_required as (select * from results join subjects s on results.subject_id = s.id where type = 'exam' and results.status = 'passed' and is_required = true);

select distinct students.id from students join credit_failed cf on students.id = cf.student_id join exam_passed_is_required epir on students.id = epir.student_id;

-- 6 Найти группу с самой большой нагрузкой (числом зачетов и экзаменов).



-- 7 Найти, сколько студентов не допущены (т.е., не получили необходимых зачетов) хотя бы к одному обязательному экзамену.
-- 8 Найти самый «сложный» экзамен (с максимальным процентом не сдавших).
-- 9 Полностью необязательные экзамены не рассматривать.
-- 10 Проверить, есть ли в базе студент, не допущенный ни к одному обязательному для его группы экзамену.