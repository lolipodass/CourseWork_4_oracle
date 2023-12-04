-- alter table BOOK_STATUS modify id generated always as identity (start with 1);

--     insert all
-- into BOOK_STATUS (TYPE) values ('ongoing')
-- into BOOK_STATUS (TYPE) values ('dropped')
-- into BOOK_STATUS (TYPE) values ('completed')
-- select * from dual;

alter table "COMMENT" modify id generated always as identity (start with 1 nocache);

delete
from GENRE;

insert into BOOK_STATUS(TYPE) values ('ongoing');
insert into BOOK_STATUS(TYPE) values ('dropped');
insert into BOOK_STATUS(TYPE) values ('completed');
select * from BOOK_STATUS;

insert into SAVE_BOOK_TYPE (NAME) values ('Читаю');
insert into SAVE_BOOK_TYPE (NAME) values ('В планах');
insert into SAVE_BOOK_TYPE (NAME) values ('Брошено');
insert into SAVE_BOOK_TYPE (NAME) values ('Прочитано');
insert into SAVE_BOOK_TYPE (NAME) values ('Любимые');
select * from SAVE_BOOK_TYPE;


insert into GENRE (NAME) values ('фэнтези');
insert into GENRE (NAME) values ('романтика');
insert into GENRE (NAME) values ('приключения');
insert into GENRE (NAME) values ('драма');
insert into GENRE (NAME) values ('комедия');
insert into GENRE (NAME) values ('боевик');
insert into GENRE (NAME) values ('ужасы');
insert into GENRE (NAME) values ('триллер');


select * from GENRE;


insert into USER_ROLE(TYPE) values ('пользователь');
insert into USER_ROLE(TYPE) values ('администратор');
insert into USER_ROLE(TYPE) values ('email подтвержден');

select * from USER_ROLE;

