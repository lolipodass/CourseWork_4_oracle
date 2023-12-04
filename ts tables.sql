-- tablespaces
CREATE TABLESPACE TS_Books
    DATAFILE 'C:\oracle\tablespaces/books/books01.dbf' SIZE 500 m AUTOEXTEND ON
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
--default storage ( initial 1m maxextents unlimited )
    ONLINE;

CREATE TABLESPACE TS_USERS
    DATAFILE 'C:\oracle\tablespaces/users/users01.dbf' SIZE 100 m AUTOEXTEND ON
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
--default storage ( initial 1m maxextents unlimited )
    ONLINE;


-- tables
-- ts_books
CREATE TABLE book_status
(
    id   INT GENERATED ALWAYS AS IDENTITY (START WITH 1 NOCACHE),
    type NVARCHAR2(20) NOT NULL,

    CONSTRAINT pk_book_status_id PRIMARY KEY (id)
) TABLESPACE TS_BOOKS;

CREATE TABLE book
(
    id          INT GENERATED ALWAYS AS IDENTITY (START WITH 1 CACHE 3),
    title       VARCHAR2(200)          NOT NULL,
    description VARCHAR2(1000),
    cover       BLOB,
    rating      NUMBER(3, 2) DEFAULT 0 NOT NULL,
    views       INT          DEFAULT 0 NOT NULL,
    status      INT                    NOT NULL,
    created_at  DATE         DEFAULT SYSDATE,

    CONSTRAINT pk_book_id PRIMARY KEY (id),
    CONSTRAINT fk_book_status FOREIGN KEY (status)
        REFERENCES book_status (id),
    CONSTRAINT ck_book_rating_positive CHECK ( rating >= 0),
    CONSTRAINT ck_book_views_positive CHECK ( views >= 0 )
) TABLESPACE TS_BOOKS;

CREATE TABLE chapter
(
    id         INT GENERATED ALWAYS AS IDENTITY,
    book_id    INT            NOT NULL,
    title      NVARCHAR2(100) NOT NULL,
    content    NCLOB          NOT NULL,
    "NUMBER"   INT            NOT NULL,
    created_at DATE DEFAULT SYSDATE,

    CONSTRAINT pk_chapter_id PRIMARY KEY (id),
    CONSTRAINT fk_chapter_book_id FOREIGN KEY (id)
        REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT ck_chapter_number_positive CHECK ( "NUMBER" >= 0 )
) TABLESPACE TS_BOOKS;

CREATE TABLE genre
(
    id   NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 NOCACHE),
    name NVARCHAR2(50) NOT NULL,

    CONSTRAINT pk_genre_id PRIMARY KEY (id)
) TABLESPACE TS_BOOKS;

CREATE TABLE book_genre
(
    book_id  INT NOT NULL,
    genre_id INT NOT NULL,

    CONSTRAINT pk_book_genre
        PRIMARY KEY (book_id, genre_id),
    CONSTRAINT fk_book_genre_book_id FOREIGN KEY (book_id)
        REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_book_genre_genre_id FOREIGN KEY (genre_id)
        REFERENCES genre (id) ON DELETE CASCADE
) TABLESPACE TS_BOOKS;

-- alter table author modify (rating visible);

CREATE TABLE author
(
    id         INT GENERATED ALWAYS AS IDENTITY (START WITH 1 CACHE 5),
    first_name NVARCHAR2(50)          NOT NULL,
    last_name  NVARCHAR2(50),
    bio        NVARCHAR2(1000),
    photo      BLOB,
    rating     NUMBER(3, 2) DEFAULT 0 NOT NULL,

    CONSTRAINT pk_author_id PRIMARY KEY (id),
    CONSTRAINT ck_author_rating_positive CHECK ( rating >= 0)
) TABLESPACE TS_BOOKS;

CREATE TABLE book_author
(
    book_id   INT NOT NULL,
    author_id INT NOT NULL,

    CONSTRAINT pk_book_author
        PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_author_bok_id FOREIGN KEY (book_id)
        REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_book_author_author_id FOREIGN KEY (author_id)
        REFERENCES author (id) ON DELETE CASCADE
) TABLESPACE TS_BOOKS;

-- ts_users
CREATE TABLE user_role
(
    id   INT GENERATED ALWAYS AS IDENTITY (START WITH 1 NOCACHE),
    type NVARCHAR2(20) NOT NULL,

    CONSTRAINT pk_user_type_id PRIMARY KEY (id)
) TABLESPACE TS_USERS;


CREATE TABLE "USER"
(
    id           INT GENERATED ALWAYS AS IDENTITY,
    display_name NVARCHAR2(50) NOT NULL,
    email        VARCHAR2(100) NOT NULL,
    login        VARCHAR2(50)  NOT NULL,
    password     RAW(65)       NOT NULL,
    avatar       BLOB,
    role         INT           NOT NULL,
    created_at   DATE DEFAULT SYSDATE,

    CONSTRAINT pk_user_id PRIMARY KEY (id),
    CONSTRAINT uq_user_email UNIQUE (email),
    CONSTRAINT uq_user_login UNIQUE (login),
    CONSTRAINT fk_user_role FOREIGN KEY (role)
        REFERENCES user_role (id)
) TABLESPACE TS_USERS;


CREATE TABLE "COMMENT"
(
    id         INT GENERATED ALWAYS AS IDENTITY,
    book_id    INT            NOT NULL,
    user_id    INT            NOT NULL,
    chapter_id INT,
    content    NVARCHAR2(500) NOT NULL,
    created_at DATE DEFAULT SYSDATE,
    votes      INT  DEFAULT 0 NOT NULL,

    CONSTRAINT pk_comment_id PRIMARY KEY (id),
    CONSTRAINT fk_comment_book_id FOREIGN KEY (book_id)
        REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_user_id FOREIGN KEY (user_id)
        REFERENCES BOOKSSYS."USER" (id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_chapter_id FOREIGN KEY (chapter_id)
        REFERENCES chapter (id) ON DELETE CASCADE
) TABLESPACE TS_USERS;


CREATE TABLE comment_rate
(
    comment_id INT NOT NULL,
    user_id    INT NOT NULL,
    rate       NUMBER(1),

    CONSTRAINT pk_comment_user PRIMARY KEY (comment_id, user_id),
    CONSTRAINT fk_comment_rate_comment_id FOREIGN KEY (comment_id)
        REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_rate_user_id FOREIGN KEY (user_id)
        REFERENCES "USER" (id) ON DELETE CASCADE,
    CONSTRAINT ck_rate CHECK ( rate IN (0, 1))
) TABLESPACE TS_USERS;

CREATE TABLE rate
(
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    rate    INT NOT NULL,

    CONSTRAINT pk_book_user PRIMARY KEY (book_id, user_id),
    CONSTRAINT fk_rate_book_id FOREIGN KEY (book_id)
        REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_rate_user_id FOREIGN KEY (user_id)
        REFERENCES "USER" (id) ON DELETE CASCADE,
    CONSTRAINT ck_rate_range CHECK ( rate > 0 AND rate <= 10)
) TABLESPACE TS_USERS;

CREATE TABLE save_book_type
(
    id   INT GENERATED ALWAYS AS IDENTITY (START WITH 1 NOCACHE),
    name NVARCHAR2(50) NOT NULL,

    CONSTRAINT pk_save_book_type_id PRIMARY KEY (id)
) TABLESPACE TS_USERS;

CREATE TABLE saved_book
(
    user_id   INT NOT NULL,
    book_id   INT NOT NULL,
    save_type INT NOT NULL,

    CONSTRAINT pk_saved_book PRIMARY KEY (user_id, book_id),
    CONSTRAINT fk_saved_book_user_id FOREIGN KEY (user_id)
        REFERENCES "USER" (id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_book_book_id FOREIGN KEY (book_id)
        REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_book_save_type FOREIGN KEY (save_type)
        REFERENCES save_book_type (id)
) TABLESPACE TS_USERS;

CREATE TABLE folder_saved_book
(
    user_id   INT            NOT NULL,
    book_id   INT            NOT NULL,
    save_type NVARCHAR2(100) NOT NULL,

    CONSTRAINT pk_folder_save_book
        PRIMARY KEY (user_id, book_id, save_type),
    CONSTRAINT fk_folder_saved_book_user_id FOREIGN KEY (user_id)
        REFERENCES "USER" (id) ON DELETE CASCADE,
    CONSTRAINT fk_folder_saved_book_book_id FOREIGN KEY (book_id)
        REFERENCES book (id) ON DELETE CASCADE
) TABLESPACE TS_USERS;

-- create type saved_book as object(
-- book_id int,
--     status varchar2(20) );
-- create type saved_book_table as table of saved_book;