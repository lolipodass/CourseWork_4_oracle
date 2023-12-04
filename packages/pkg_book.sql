CREATE OR REPLACE PACKAGE pkg_book AS
    wrong_record EXCEPTION;
    null_parameter EXCEPTION;
    DATA_NOT_FOUND EXCEPTION;

    PROCEDURE sync_indexes;

    PROCEDURE create_book(
        p_title IN book.title%TYPE,
        p_description IN book.description%TYPE DEFAULT NULL,
        p_cover IN BOOK.cover%TYPE DEFAULT NULL,
        p_status IN book.status%TYPE DEFAULT 1,
        p_created_at IN book.created_at%TYPE DEFAULT SYSDATE,
        p_id OUT book.id%TYPE
    );
    PROCEDURE read_book(
        p_id IN book.id%TYPE,
        p_record OUT BOOK%ROWTYPE
    );
    PROCEDURE update_book(
        p_id IN book.id%TYPE,
        p_record IN BOOK%ROWTYPE
    );
    PROCEDURE delete_book(
        p_id IN book.id%TYPE,
        p_record OUT BOOK%ROWTYPE
    );

    FUNCTION find_book_id_by_title(
        p_title IN book.title%TYPE
    ) RETURN book.id%TYPE;
    FUNCTION find_book_id_by_title_like(
        p_title IN book.title%TYPE
    ) RETURN book.id%TYPE;
    FUNCTION find_book_id_by_description(
        p_description IN book.DESCRIPTION%TYPE
    ) RETURN book.id%TYPE;
    FUNCTION find_book_id_by_description_query(
        p_description VARCHAR2
    ) RETURN book.id%TYPE;

    FUNCTION get_chapters_by_book_id(p_id BOOK.ID%TYPE)
        RETURN CURSOR_TYPES.chapter_cursor;
    FUNCTION get_genres_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.genre_cursor;
    FUNCTION get_authors_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.author_cursor;
    FUNCTION get_comments_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_cursor;
    FUNCTION get_rates_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.rate_cursor;

    FUNCTION get_genres_by_name(p_name GENRE.NAME%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.genre_cursor;
    FUNCTION get_authors_by_name(p_name AUTHOR.FIRST_NAME%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.author_cursor;

    FUNCTION get_books_by_genre_id(p_id GENRE.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor;
    FUNCTION get_books_by_author_id(p_id AUTHOR.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor;

    PROCEDURE compute_book_avg(p_id BOOK.ID%TYPE);

    PROCEDURE create_genre(
        p_name IN genre.NAME%TYPE
    );
    PROCEDURE create_author(
        p_first_name IN AUTHOR.FIRST_NAME%TYPE,
        p_last_name IN AUTHOR.LAST_NAME%TYPE DEFAULT NULL,
        p_bio IN AUTHOR.BIO%TYPE DEFAULT NULL,
        p_photo IN AUTHOR.PHOTO%TYPE DEFAULT NULL
    );
    PROCEDURE create_chapter(
        p_title IN CHAPTER.TITLE%TYPE,
        p_content IN CHAPTER.CONTENT%TYPE,
        p_book_id IN CHAPTER.BOOK_ID%TYPE,
        p_number IN CHAPTER."NUMBER"%TYPE,
        p_create_at IN CHAPTER.CREATED_AT%TYPE DEFAULT SYSDATE
    );

    PROCEDURE delete_genre(
        p_genre_id IN GENRE.ID%TYPE
    );
    PROCEDURE delete_author(
        p_author_id IN AUTHOR.ID%TYPE
    );
    PROCEDURE delete_chapter(
        p_chapter_id IN CHAPTER.ID%TYPE
    );

    PROCEDURE update_genre(
        p_genre_id IN GENRE.ID%TYPE,
        p_name IN GENRE.NAME%TYPE
    );
    PROCEDURE update_author(
        p_author_id IN AUTHOR.ID%TYPE,
        p_author_record IN AUTHOR%ROWTYPE
    );
    PROCEDURE update_chapter(
        p_chapter_id IN CHAPTER.ID%TYPE,
        p_chapter_record IN CHAPTER%ROWTYPE
    );

    PROCEDURE add_book_genre(
        p_book_id IN BOOK_GENRE.BOOK_ID%TYPE,
        p_genre_id IN BOOK_GENRE.GENRE_ID%TYPE
    );
    PROCEDURE add_book_author(
        p_book_id IN BOOK_AUTHOR.BOOK_ID%TYPE,
        p_author_id IN BOOK_AUTHOR.AUTHOR_ID%TYPE
    );

    PROCEDURE delete_book_genre(
        p_book_id IN BOOK_GENRE.BOOK_ID%TYPE,
        p_genre_id IN BOOK_GENRE.GENRE_ID%TYPE
    );
    PROCEDURE delete_book_author(
        p_book_id IN BOOK_AUTHOR.BOOK_ID%TYPE,
        p_author_id IN BOOK_AUTHOR.AUTHOR_ID%TYPE
    );

END pkg_book;

CREATE OR REPLACE PACKAGE BODY pkg_book AS

    PROCEDURE sync_indexes
        IS
    BEGIN
        ctx_ddl.sync_index('book_description_idx');
        ctx_ddl.sync_index('book_title_idx');
    END;

    PROCEDURE create_book(
        p_title IN book.title%TYPE,
        p_description IN book.description%TYPE DEFAULT NULL,
        p_cover IN BOOK.cover%TYPE DEFAULT NULL,
        p_status IN book.status%TYPE DEFAULT 1,
        p_created_at IN book.created_at%TYPE DEFAULT SYSDATE,
        p_id OUT book.id%TYPE
    ) IS
    BEGIN
        IF p_title IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO BOOK (TITLE, DESCRIPTION, COVER, STATUS, CREATED_AT)
        VALUES (p_title, p_description, p_cover, p_status, p_created_at)
        RETURNING id INTO p_id;
    EXCEPTION
        WHEN OTHERS THEN p_id := -1;
    END;

    PROCEDURE read_book(
        p_id IN book.id%TYPE,
        p_record OUT BOOK%ROWTYPE
    ) IS
    BEGIN
        IF p_id IS NULL THEN RAISE null_parameter; END IF;

        SELECT * INTO p_record FROM BOOK WHERE ID = p_id;
        UPDATE BOOK SET VIEWS =VIEWS+1 WHERE ID=p_id;

    EXCEPTION
        WHEN OTHERS THEN p_record := NULL;
    END;


    PROCEDURE update_book(
        p_id IN book.id%TYPE,
        p_record IN BOOK%ROWTYPE
    ) IS
        p_old_record BOOK%ROWTYPE;
    BEGIN
        IF p_id IS NULL THEN RAISE null_parameter; END IF;

        SELECT * INTO p_old_record FROM BOOK WHERE ID = p_id;

        IF p_record.TITLE IS NOT NULL THEN p_old_record.TITLE := p_record.TITLE; END IF;
        IF p_record.DESCRIPTION IS NOT NULL THEN p_old_record.DESCRIPTION := p_record.DESCRIPTION; END IF;
        IF p_record.COVER IS NOT NULL THEN p_old_record.COVER := p_record.COVER; END IF;
        IF p_record.STATUS IS NOT NULL THEN p_old_record.STATUS := p_record.STATUS; END IF;
        IF p_record.RATING IS NOT NULL THEN p_old_record.RATING := p_record.RATING; END IF;
        IF p_record.CREATED_AT IS NOT NULL THEN p_old_record.CREATED_AT := p_record.CREATED_AT; END IF;
        IF p_record."VIEWS" IS NOT NULL THEN p_old_record."VIEWS" := p_record."VIEWS"; END IF;

        UPDATE BOOK SET ROW =p_old_record WHERE ID = p_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('update book error');
        RAISE DATA_NOT_FOUND;
    END;

    PROCEDURE delete_book(
        p_id IN book.id%TYPE,
        p_record OUT BOOK%ROWTYPE
    ) IS
    BEGIN
        IF p_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE BOOK
        WHERE ID = p_id
        RETURNING ID, TITLE,DESCRIPTION,COVER,RATING,"VIEWS",STATUS,CREATED_AT INTO p_record;
    EXCEPTION
        WHEN OTHERS THEN p_record := NULL;
    END;

    FUNCTION find_book_id_by_title(p_title IN book.title%TYPE)
        RETURN book.id%TYPE IS
        v_id book.id%TYPE;
    BEGIN
        IF p_title IS NULL THEN RAISE null_parameter; END IF;

        SELECT id
        INTO v_id
        FROM BOOK
        WHERE CONTAINS(TITLE, 'ABOUT(' || p_title || ')', 1) > 0
        ORDER BY score(1) DESC FETCH FIRST 1 ROW ONLY;
        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;

    FUNCTION find_book_id_by_title_like(p_title IN book.title%TYPE)
        RETURN book.id%TYPE IS
        v_id book.id%TYPE;
    BEGIN
        IF p_title IS NULL THEN RAISE null_parameter; END IF;

        SELECT id
        INTO v_id
        FROM BOOK
        WHERE CONTAINS(TITLE, '%' || p_title || '%', 1) > 0
        ORDER BY score(1) DESC FETCH FIRST 1 ROW ONLY;
        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;

    FUNCTION find_book_id_by_description(
        p_description IN book.DESCRIPTION%TYPE
    )
        RETURN book.id%TYPE IS
        v_id book.id%TYPE;
    BEGIN
        IF p_description IS NULL THEN RAISE null_parameter; END IF;

        SELECT id
        INTO v_id
        FROM BOOK
        WHERE CONTAINS(DESCRIPTION, 'ABOUT(' || p_description || ')', 1) > 0
        ORDER BY score(1) DESC FETCH FIRST 1 ROW ONLY;
        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;

    FUNCTION find_book_id_by_description_query(
        p_description VARCHAR2
    ) RETURN book.id%TYPE IS
        v_id book.id%TYPE;
    BEGIN
        IF p_description IS NULL THEN RAISE null_parameter; END IF;

        SELECT id
        INTO v_id
        FROM BOOK
        WHERE CONTAINS(DESCRIPTION, p_description, 1) > 0
        ORDER BY score(1) DESC FETCH FIRST 1 ROW ONLY;
        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;

    FUNCTION get_chapters_by_book_id(p_id BOOK.ID%TYPE)
        RETURN CURSOR_TYPES.chapter_cursor IS
        p_cur CURSOR_TYPES.chapter_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM CHAPTER;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT *
            FROM CHAPTER
            WHERE BOOK_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_genres_by_book_id(p_id BOOK.ID%TYPE)
        RETURN CURSOR_TYPES.genre_cursor
        IS
        p_cur CURSOR_TYPES.genre_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM GENRE;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT G.*
            FROM GENRE G
                     INNER JOIN BOOK_GENRE BG ON G.ID = BG.GENRE_ID
            WHERE BG.BOOK_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_authors_by_book_id(p_id BOOK.ID%TYPE)
        RETURN CURSOR_TYPES.author_cursor
        IS
        p_cur CURSOR_TYPES.author_cursor;
    BEGIN

        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM AUTHOR;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT A.*
            FROM AUTHOR A
                     INNER JOIN BOOK_AUTHOR BA ON A.ID = BA.AUTHOR_ID
            WHERE BA.BOOK_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_comments_by_book_id(p_id BOOK.ID%TYPE)
        RETURN CURSOR_TYPES.comment_cursor
        IS
        p_cur CURSOR_TYPES.comment_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM "COMMENT";
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT *
            FROM "COMMENT"
            WHERE BOOK_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_rates_by_book_id(p_id BOOK.ID%TYPE)
        RETURN CURSOR_TYPES.rate_cursor
        IS
        p_cur CURSOR_TYPES.rate_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM RATE;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT *
            FROM RATE
            WHERE BOOK_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION get_genres_by_name(p_name GENRE.NAME%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.genre_cursor IS
        p_cur CURSOR_TYPES.genre_cursor;
    BEGIN
        IF p_name IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM GENRE;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT *
            FROM GENRE
            WHERE NAME LIKE '%' || p_name || '%';
        RETURN p_cur;
    END;

    FUNCTION get_authors_by_name(p_name AUTHOR.FIRST_NAME%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.author_cursor IS
        p_cur CURSOR_TYPES.author_cursor;
    BEGIN
        IF p_name IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM AUTHOR;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT *
            FROM AUTHOR
            WHERE FIRST_NAME LIKE '%' || p_name || '%';
        RETURN p_cur;
    END;

    FUNCTION
        get_books_by_genre_id(p_id GENRE.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor IS
        p_cur CURSOR_TYPES.book_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM BOOK;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT B.*
            FROM BOOK B
                     INNER JOIN BOOK_GENRE BG ON B.ID = BG.BOOK_ID
            WHERE BG.GENRE_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_books_by_author_id(p_id AUTHOR.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor IS
        p_cur CURSOR_TYPES.book_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT *
                FROM BOOK;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT B.*
            FROM BOOK B
                     INNER JOIN BOOK_AUTHOR BA ON B.ID = BA.BOOK_ID
            WHERE BA.AUTHOR_ID = p_id;
        RETURN p_cur;
    END;

    PROCEDURE
        create_genre(
        p_name IN genre.NAME %TYPE
    ) IS
    BEGIN
        IF p_name IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO GENRE(NAME) VALUES (p_name);
    END;

    PROCEDURE
        create_author(
        p_first_name IN AUTHOR.FIRST_NAME %TYPE,
        p_last_name IN AUTHOR.LAST_NAME %TYPE DEFAULT NULL,
        p_bio IN AUTHOR.BIO %TYPE DEFAULT NULL,
        p_photo IN AUTHOR.PHOTO %TYPE DEFAULT NULL
    ) IS
    BEGIN
        IF p_first_name IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO AUTHOR (FIRST_NAME, LAST_NAME, BIO, PHOTO) VALUES (p_first_name, p_last_name, p_bio, p_photo);
    END;

    PROCEDURE
        create_chapter(
        p_title IN CHAPTER.TITLE %TYPE,
        p_content IN CHAPTER.CONTENT %TYPE,
        p_book_id IN CHAPTER.BOOK_ID %TYPE,
        p_number IN CHAPTER."NUMBER" %TYPE,
        p_create_at IN CHAPTER.CREATED_AT %TYPE DEFAULT SYSDATE
    ) IS
    BEGIN
        IF p_title IS NULL THEN RAISE null_parameter; END IF;
        IF p_content IS NULL THEN RAISE null_parameter; END IF;
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_number IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO CHAPTER (TITLE, CONTENT, BOOK_ID, "NUMBER", CREATED_AT)
        VALUES (p_title, p_content, p_book_id, p_number, NVL(p_create_at, SYSDATE));
    END;

    PROCEDURE
        delete_genre(
        p_genre_id IN GENRE.ID %TYPE
    ) IS
    BEGIN
        IF p_genre_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM GENRE WHERE ID = p_genre_id;
    END;

    PROCEDURE
        delete_author(
        p_author_id IN AUTHOR.ID %TYPE
    ) IS
    BEGIN
        IF p_author_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM AUTHOR WHERE ID = p_author_id;
    END;

    PROCEDURE
        delete_chapter(
        p_chapter_id IN CHAPTER.ID %TYPE
    ) IS
    BEGIN
        IF p_chapter_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM CHAPTER WHERE ID = p_chapter_id;
    END;

    PROCEDURE
        update_genre(
        p_genre_id IN GENRE.ID %TYPE,
        p_name IN GENRE.NAME %TYPE
    ) IS
    BEGIN
        IF p_genre_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_name IS NULL THEN RAISE null_parameter; END IF;

        UPDATE GENRE SET NAME=p_name WHERE ID = p_genre_id;
    END;

    PROCEDURE
        update_author(
        p_author_id IN AUTHOR.ID %TYPE,
        p_author_record IN AUTHOR % ROWTYPE
    ) IS
        p_old_record BOOKSSYS.AUTHOR%ROWTYPE;
    BEGIN
        IF p_author_id IS NULL THEN RAISE null_parameter; END IF;

        SELECT * INTO p_old_record FROM AUTHOR WHERE ID = p_author_id;

        IF p_author_record.FIRST_NAME IS NOT NULL THEN p_old_record.FIRST_NAME := p_author_record.FIRST_NAME; END IF;
        IF p_author_record.LAST_NAME IS NOT NULL THEN p_old_record.LAST_NAME := p_author_record.LAST_NAME; END IF;
        IF p_author_record.BIO IS NOT NULL THEN p_old_record.BIO := p_author_record.BIO; END IF;
        IF p_author_record.RATING IS NOT NULL THEN p_old_record.RATING := p_author_record.RATING; END IF;
        IF p_author_record.PHOTO IS NOT NULL THEN p_old_record.PHOTO := p_author_record.PHOTO; END IF;

        UPDATE AUTHOR SET ROW =p_old_record WHERE ID = p_author_id;
    END;

    PROCEDURE
        update_chapter(
        p_chapter_id IN CHAPTER.ID %TYPE,
        p_chapter_record IN CHAPTER % ROWTYPE
    ) IS
        p_old_record BOOKSSYS.CHAPTER%ROWTYPE;
    BEGIN
        IF p_chapter_id IS NULL THEN RAISE null_parameter; END IF;

        SELECT * INTO p_old_record FROM CHAPTER WHERE ID = p_chapter_id;

        IF p_chapter_record.TITLE IS NOT NULL THEN p_old_record.TITLE := p_chapter_record.TITLE; END IF;
        IF p_chapter_record."NUMBER" IS NOT NULL THEN p_old_record."NUMBER" := p_chapter_record."NUMBER"; END IF;
        IF p_chapter_record.CONTENT IS NOT NULL THEN p_old_record.CONTENT := p_chapter_record.CONTENT; END IF;
        IF p_chapter_record.BOOK_ID IS NOT NULL THEN p_old_record.BOOK_ID := p_chapter_record.BOOK_ID; END IF;
        IF p_chapter_record.CREATED_AT IS NOT NULL THEN p_old_record.CREATED_AT := p_chapter_record.CREATED_AT; END IF;

        UPDATE CHAPTER SET ROW =p_chapter_record WHERE ID = p_chapter_id;
    END;

    PROCEDURE
        add_book_genre(
        p_book_id IN BOOK_GENRE.BOOK_ID %TYPE,
        p_genre_id IN BOOK_GENRE.GENRE_ID %TYPE
    ) IS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_genre_id IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO BOOK_GENRE (BOOK_ID, GENRE_ID) VALUES (p_book_id, p_genre_id);
    END;

    PROCEDURE
        add_book_author(
        p_book_id IN BOOK_AUTHOR.BOOK_ID %TYPE,
        p_author_id IN BOOK_AUTHOR.AUTHOR_ID %TYPE
    ) IS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_author_id IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO BOOK_AUTHOR (BOOK_ID, AUTHOR_ID) VALUES (p_book_id, p_author_id);
    END;

    PROCEDURE
        delete_book_genre(
        p_book_id IN BOOK_GENRE.BOOK_ID %TYPE,
        p_genre_id IN BOOK_GENRE.GENRE_ID %TYPE
    ) IS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_genre_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM BOOK_GENRE WHERE BOOK_ID = p_book_id AND GENRE_ID = p_genre_id;
    END;

    PROCEDURE
        delete_book_author(
        p_book_id IN BOOK_AUTHOR.BOOK_ID %TYPE,
        p_author_id IN BOOK_AUTHOR.AUTHOR_ID %TYPE
    ) IS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_author_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM BOOK_AUTHOR WHERE BOOK_ID = p_book_id AND AUTHOR_ID = p_author_id;
    END;

    PROCEDURE compute_book_avg(p_id BOOK.ID%TYPE)
    AS
        p_avg NUMBER(3,2);
    BEGIN
        SELECT avg(RATE) INTO p_avg FROM RATE
            WHERE BOOK_ID=p_id;
        UPDATE BOOK set RATING=p_avg WHERE ID=p_id;
    END;

    END pkg_book;

