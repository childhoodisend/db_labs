create table if not exists subjects
(
    id serial not null primary key, -- id
    name char(64) not null,         -- название
    type char(6) not null,

    unique(name, type),
    unique(id, name, type),
    constraint type_chk check (type in ('exam', 'credit'))
);


create table if not exists students
(
    id serial not null primary key, -- id
    firstname char(64) not null,    -- имя
    middle_name char(64) not null,  -- отчетсво
    lastname char(64) not null,     -- фамилия
    book int not null,              -- зачетная книжка
    group_id int not null,          -- номер группы

    unique (id, book, group_id),
    unique (id, group_id),
    unique (id)
);


create table if not exists results
(
    student_id int not null references students(id), -- id студента
    subject_id int not null references subjects(id), -- id предмета
    attempt int not null default 1,
    status char(6) not null default 'need',
    is_required bool not null default false,

    constraint status_chk check (status in ('passed', 'failed', 'need')),
    constraint attempt_chk check (attempt in (1, 2, 3)),

    unique (student_id, subject_id, attempt)
);

create table if not exists dependencies
(
	subject_id int not null references subjects(id),
	depends_of int not null references subjects(id),
	is_required bool not null default false
);

create table if not exists group_subj
(
    group_id int not null,
    subject_id int not null references subjects(id),
    is_required bool not null default false,

    constraint group_chk check ( group_id in (431, 433, 244, 1))
);