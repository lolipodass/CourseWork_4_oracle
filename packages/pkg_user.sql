CREATE OR REPLACE PACKAGE pkg_user AS
    wrong_record EXCEPTION;
    wrong_password EXCEPTION;
    null_parameter EXCEPTION;


    PROCEDURE change_password(
        p_id BOOKSSYS."USER".ID%TYPE,
        p_old_password VARCHAR2,
        p_new_password VARCHAR2
    );
    PROCEDURE confirm_email(
        p_user_id IN BOOKSSYS."USER".ID%TYPE
    );

    PROCEDURE create_user(
        p_email IN BOOKSSYS."USER".EMAIL%TYPE,
        p_login IN BOOKSSYS."USER".LOGIN%TYPE,
        p_password IN VARCHAR2,
        p_display_name IN BOOKSSYS."USER".DISPLAY_NAME%TYPE DEFAULT NULL,
        p_avatar IN BOOKSSYS."USER".AVATAR%TYPE DEFAULT NULL
    );
    PROCEDURE read_user(
        p_id IN BOOKSSYS."USER".ID%TYPE,
        p_record OUT BOOKSSYS."USER"%ROWTYPE
    );
    PROCEDURE update_user(
        p_id IN BOOKSSYS."USER".ID%TYPE,
        p_record IN BOOKSSYS."USER"%ROWTYPE
    );
    PROCEDURE delete_user(
        p_id IN BOOKSSYS."USER".ID%TYPE,
        p_record OUT BOOKSSYS."USER"%ROWTYPE
    );

    PROCEDURE create_rate(
        p_book_id IN rate.BOOK_ID%TYPE,
        p_user_id IN rate.USER_ID%TYPE,
        p_rate IN rate.RATE%TYPE DEFAULT 10
    );
    PROCEDURE create_comment(
        p_book_id IN "COMMENT".BOOK_ID%TYPE,
        p_user_id IN "COMMENT".USER_ID%TYPE,
        p_content IN "COMMENT".CONTENT%TYPE,
        p_chapter_id IN "COMMENT".CHAPTER_ID%TYPE DEFAULT NULL,
        p_created_at IN "COMMENT".CREATED_AT%TYPE DEFAULT SYSDATE
    );
    PROCEDURE create_comment_rate(
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE,
        p_user_id IN COMMENT_RATE.USER_ID%TYPE,
        p_rate IN COMMENT_RATE.RATE%TYPE DEFAULT 10
    );
    PROCEDURE create_saved_book(
        p_book_id IN SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN SAVED_BOOK.USER_ID%TYPE,
        p_type IN SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    );
    PROCEDURE create_folder_saved_book(
        p_book_id IN FOLDER_SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN FOLDER_SAVED_BOOK.USER_ID%TYPE,
        p_folder_name IN FOLDER_SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    );

    PROCEDURE delete_rate(
        p_book_id IN rate.BOOK_ID%TYPE,
        p_user_id IN rate.USER_ID%TYPE
    );
    PROCEDURE delete_comment(
        p_comment_id IN "COMMENT".ID%TYPE
    );
    PROCEDURE delete_comment_rate(
        p_user_id IN rate.USER_ID%TYPE,
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE
    );
    PROCEDURE delete_saved_book(
        p_book_id IN SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN SAVED_BOOK.USER_ID%TYPE
    );
    PROCEDURE delete_folder_saved_book(
        p_book_id IN FOLDER_SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN FOLDER_SAVED_BOOK.USER_ID%TYPE
    );

    PROCEDURE update_rate(
        p_book_id IN rate.BOOK_ID%TYPE,
        p_user_id IN rate.USER_ID%TYPE,
        p_rate IN rate.RATE%TYPE
    );
    PROCEDURE update_comment(
        p_comment_id IN "COMMENT".ID%TYPE,
        p_comment_record IN "COMMENT"%ROWTYPE
    );
    PROCEDURE update_comment_rate(
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE,
        p_user_id IN COMMENT_RATE.USER_ID%TYPE,
        p_rate IN COMMENT_RATE.RATE%TYPE
    );
    PROCEDURE update_saved_book(
        p_book_id IN SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN SAVED_BOOK.USER_ID%TYPE,
        p_type IN SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    );
    PROCEDURE update_folder_saved_book(
        p_book_id IN FOLDER_SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN FOLDER_SAVED_BOOK.USER_ID%TYPE,
        p_folder_name IN FOLDER_SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    );


    FUNCTION get_rates_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.rate_cursor;
    FUNCTION get_comments_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_cursor;
    FUNCTION get_comments_rate_by_comment_id(p_id "COMMENT".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_rate_cursor;
    FUNCTION get_saved_books_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.saved_book_cursor;
    FUNCTION get_folder_saved_books_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.folder_saved_cursor;

END pkg_user;



CREATE OR REPLACE PACKAGE BODY pkg_user AS
    FUNCTION hash(p_password IN VARCHAR2)
        RETURN RAW
    AS
    BEGIN
        IF p_password IS NULL THEN RETURN NULL; END IF;
        RETURN DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(p_password), DBMS_CRYPTO.HASH_SH512);
    END;

    PROCEDURE confirm_email(
        p_user_id IN BOOKSSYS."USER".ID%TYPE
    ) AS
    BEGIN
        UPDATE "USER" SET ROLE =3 WHERE ID = p_user_id AND ROLE = 1;
    END;

    PROCEDURE change_password(
        p_id BOOKSSYS."USER".ID%TYPE,
        p_old_password VARCHAR2,
        p_new_password VARCHAR2
    ) IS
        CURSOR p_cur IS SELECT PASSWORD
                        FROM BOOKSSYS."USER"
                        WHERE ID = p_id FOR UPDATE;
        p_pass              RAW(65);
        p_new_hash_password RAW(65) := hash(p_new_password);
    BEGIN
        IF p_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_old_password IS NULL THEN RAISE null_parameter; END IF;
        IF p_new_password IS NULL THEN RAISE null_parameter; END IF;

        OPEN p_cur;
        FETCH p_cur INTO p_pass;

        IF UTL_RAW.COMPARE(hash(p_old_password), p_pass) != 0 THEN
            RAISE wrong_password;
        END IF;

        UPDATE BOOKSSYS."USER" SET PASSWORD= p_new_hash_password WHERE CURRENT OF p_cur;
        CLOSE p_cur;
    END;

    PROCEDURE create_user(
        p_email IN BOOKSSYS."USER".EMAIL%TYPE,
        p_login IN BOOKSSYS."USER".LOGIN%TYPE,
        p_password IN VARCHAR2,
        p_display_name IN BOOKSSYS."USER".DISPLAY_NAME%TYPE DEFAULT NULL,
        p_avatar IN BOOKSSYS."USER".AVATAR%TYPE DEFAULT NULL
    ) AS
        hash_password RAW(65) := hash(p_password);
    BEGIN
        IF p_login IS NULL THEN RAISE null_parameter; END IF;
        IF p_email IS NULL THEN RAISE null_parameter; END IF;
        IF p_password IS NULL THEN RAISE null_parameter; END IF;


        INSERT INTO BOOKSSYS."USER" (DISPLAY_NAME, EMAIL, LOGIN, PASSWORD, AVATAR, ROLE)
        VALUES (NVL(p_display_name, p_login), UPPER(p_email), p_login, hash_password, p_avatar, 1);
    END;


    PROCEDURE read_user(
        p_id IN BOOKSSYS."USER".ID%TYPE,
        p_record OUT BOOKSSYS."USER"%ROWTYPE
    ) AS
    BEGIN
        IF p_id IS NULL THEN RAISE null_parameter; END IF;

        SELECT * INTO p_record FROM BOOKSSYS."USER" WHERE ID = p_id;
    END;

    PROCEDURE update_user(
        p_id IN BOOKSSYS."USER".ID%TYPE,
        p_record IN BOOKSSYS."USER"%ROWTYPE
    )
    AS
        p_old_record BOOKSSYS."USER"%ROWTYPE;
    BEGIN
        IF p_id IS NULL THEN RAISE null_parameter; END IF;

        SELECT * INTO p_old_record FROM BOOKSSYS."USER" WHERE ID = p_id;

        IF p_record.DISPLAY_NAME IS NOT NULL THEN p_old_record.DISPLAY_NAME := p_record.DISPLAY_NAME; END IF;
        IF p_record.EMAIL IS NOT NULL THEN p_old_record.EMAIL := p_record.EMAIL; END IF;
        IF p_record.LOGIN IS NOT NULL THEN p_old_record.LOGIN := p_record.LOGIN; END IF;
        IF p_record.AVATAR IS NOT NULL THEN p_old_record.AVATAR := p_record.AVATAR; END IF;
        IF p_record.ROLE IS NOT NULL THEN p_old_record.ROLE := p_record.ROLE; END IF;
        IF p_record.CREATED_AT IS NOT NULL THEN p_old_record.CREATED_AT := p_record.CREATED_AT; END IF;

        UPDATE BOOKSSYS."USER" SET ROW =p_old_record WHERE ID = p_id;
    END;

    PROCEDURE delete_user(
        p_id IN BOOKSSYS."USER".ID%TYPE,
        p_record OUT BOOKSSYS."USER"%ROWTYPE
    ) AS
    BEGIN
        IF p_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE BOOKSSYS."USER"
        WHERE ID = p_id
        RETURNING ID,DISPLAY_NAME,EMAIL,LOGIN,PASSWORD,AVATAR,ROLE,CREATED_AT INTO p_record;
    END;

    PROCEDURE create_rate(
        p_book_id IN rate.BOOK_ID%TYPE,
        p_user_id IN rate.USER_ID%TYPE,
        p_rate IN rate.RATE%TYPE DEFAULT 10
    ) AS
    BEGIN
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_rate IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO RATE (BOOK_ID, USER_ID, RATE)
        VALUES (p_book_id, p_user_id, p_rate);
    END;

    PROCEDURE create_comment(
        p_book_id IN "COMMENT".BOOK_ID%TYPE,
        p_user_id IN "COMMENT".USER_ID%TYPE,
        p_content IN "COMMENT".CONTENT%TYPE,
        p_chapter_id IN "COMMENT".CHAPTER_ID%TYPE DEFAULT NULL,
        p_created_at IN "COMMENT".CREATED_AT%TYPE DEFAULT SYSDATE
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_content IS NULL THEN RAISE null_parameter; END IF;


        INSERT INTO "COMMENT" (BOOK_ID, USER_ID, CHAPTER_ID, CONTENT, CREATED_AT)
        VALUES (p_book_id, p_user_id, p_chapter_id, p_content, NVL(p_created_at, SYSDATE));
    END;

    PROCEDURE create_comment_rate(
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE,
        p_user_id IN COMMENT_RATE.USER_ID%TYPE,
        p_rate IN COMMENT_RATE.RATE%TYPE DEFAULT 10
    ) AS
    BEGIN
        IF p_comment_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_rate IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO COMMENT_RATE (COMMENT_ID, USER_ID, RATE)
        VALUES (p_comment_id, p_user_id, p_rate);
    END;

    PROCEDURE create_saved_book(
        p_book_id IN SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN SAVED_BOOK.USER_ID%TYPE,
        p_type IN SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_type IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO SAVED_BOOK (BOOK_ID, USER_ID, SAVE_TYPE)
        VALUES (p_book_id, p_user_id, p_type);
    END;

    PROCEDURE create_folder_saved_book(
        p_book_id IN FOLDER_SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN FOLDER_SAVED_BOOK.USER_ID%TYPE,
        p_folder_name IN FOLDER_SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_folder_name IS NULL THEN RAISE null_parameter; END IF;

        INSERT INTO FOLDER_SAVED_BOOK (BOOK_ID, USER_ID, SAVE_TYPE)
        VALUES (p_book_id, p_user_id, p_folder_name);
    END;

    PROCEDURE delete_rate(
        p_book_id IN rate.BOOK_ID%TYPE,
        p_user_id IN rate.USER_ID%TYPE
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM RATE WHERE USER_ID = p_book_id AND USER_ID = p_user_id;
    END;

    PROCEDURE delete_comment(
        p_comment_id IN "COMMENT".ID%TYPE
    ) AS
    BEGIN
        IF p_comment_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM "COMMENT" WHERE ID = p_comment_id;
    END;

    PROCEDURE delete_comment_rate(
        p_user_id IN rate.USER_ID%TYPE,
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE
    ) AS
    BEGIN
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_comment_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM COMMENT_RATE WHERE USER_ID = p_user_id AND COMMENT_ID = p_comment_id;
    END;

    PROCEDURE delete_saved_book(
        p_book_id IN SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN SAVED_BOOK.USER_ID%TYPE
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM SAVED_BOOK WHERE USER_ID = p_user_id AND BOOK_ID = p_book_id;
    END;

    PROCEDURE delete_folder_saved_book(
        p_book_id IN FOLDER_SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN FOLDER_SAVED_BOOK.USER_ID%TYPE
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;

        DELETE FROM FOLDER_SAVED_BOOK WHERE USER_ID = p_user_id AND BOOK_ID = p_book_id;
    END;

    PROCEDURE update_rate(
        p_book_id IN rate.BOOK_ID%TYPE,
        p_user_id IN rate.USER_ID%TYPE,
        p_rate IN rate.RATE%TYPE
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_rate IS NULL THEN RAISE null_parameter; END IF;

        UPDATE RATE SET RATE=p_rate WHERE USER_ID = p_user_id AND BOOK_ID = p_book_id;
    END;

    PROCEDURE update_comment(
        p_comment_id IN "COMMENT".ID%TYPE,
        p_comment_record IN "COMMENT"%ROWTYPE
    ) AS
        p_old_record BOOKSSYS."COMMENT"%ROWTYPE;
    BEGIN
        IF p_comment_id IS NULL THEN RAISE null_parameter; END IF;

        SELECT * INTO p_old_record FROM "COMMENT" WHERE ID = p_comment_id;

        IF p_comment_record.CONTENT IS NOT NULL THEN p_old_record.CONTENT := p_comment_record.CONTENT; END IF;
        IF p_comment_record.CREATED_AT IS NOT NULL THEN p_old_record.CREATED_AT := p_comment_record.CREATED_AT; END IF;
        IF p_comment_record.VOTES IS NOT NULL THEN p_old_record.VOTES := p_comment_record.VOTES; END IF;

        UPDATE "COMMENT" SET ROW = p_comment_record WHERE ID = p_comment_id;
    END;

    PROCEDURE update_comment_rate(
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE,
        p_user_id IN COMMENT_RATE.USER_ID%TYPE,
        p_rate IN COMMENT_RATE.RATE%TYPE
    ) AS
    BEGIN
        IF p_comment_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_rate IS NULL THEN RAISE null_parameter; END IF;

        UPDATE COMMENT_RATE SET RATE = p_rate WHERE COMMENT_ID = p_comment_id AND USER_ID = p_user_id;
    END;

    PROCEDURE update_saved_book(
        p_book_id IN SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN SAVED_BOOK.USER_ID%TYPE,
        p_type IN SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_type IS NULL THEN RAISE null_parameter; END IF;

        UPDATE SAVED_BOOK SET SAVE_TYPE = p_type WHERE BOOK_ID = p_book_id AND USER_ID = p_user_id;
    END;

    PROCEDURE update_folder_saved_book(
        p_book_id IN FOLDER_SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN FOLDER_SAVED_BOOK.USER_ID%TYPE,
        p_folder_name IN FOLDER_SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    ) AS
    BEGIN
        IF p_book_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_user_id IS NULL THEN RAISE null_parameter; END IF;
        IF p_folder_name IS NULL THEN RAISE null_parameter; END IF;

        UPDATE FOLDER_SAVED_BOOK SET SAVE_TYPE = p_folder_name WHERE BOOK_ID = p_book_id AND USER_ID = p_user_id;
    END;

    FUNCTION
        get_rates_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.rate_cursor IS
        p_cur CURSOR_TYPES.rate_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT * FROM RATE;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT * FROM RATE WHERE USER_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_comments_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_cursor IS
        p_cur CURSOR_TYPES.comment_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT * FROM "COMMENT";
            RETURN p_cur;

        END IF;

        OPEN p_cur FOR
            SELECT * FROM "COMMENT" WHERE USER_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_comments_rate_by_comment_id(p_id "COMMENT".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_rate_cursor IS
        p_cur CURSOR_TYPES.comment_rate_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT * FROM COMMENT_RATE;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT * FROM COMMENT_RATE WHERE COMMENT_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_saved_books_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.saved_book_cursor IS
        p_cur CURSOR_TYPES.saved_book_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT * FROM SAVED_BOOK;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT * FROM SAVED_BOOK WHERE USER_ID = p_id;
        RETURN p_cur;
    END;

    FUNCTION
        get_folder_saved_books_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.folder_saved_cursor IS
        p_cur CURSOR_TYPES.folder_saved_cursor;
    BEGIN
        IF p_id IS NULL THEN
            OPEN p_cur FOR
                SELECT * FROM FOLDER_SAVED_BOOK;
            RETURN p_cur;
        END IF;

        OPEN p_cur FOR
            SELECT * FROM FOLDER_SAVED_BOOK WHERE USER_ID = p_id;
        RETURN p_cur;
    END;

END pkg_user;