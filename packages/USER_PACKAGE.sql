CREATE OR REPLACE PACKAGE USER_PACKAGE AS


    FUNCTION get_books_by_genre_id(p_id GENRE.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor;
    FUNCTION get_books_by_author_id(p_id AUTHOR.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor;

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

    FUNCTION find_book(p_name IN VARCHAR2)
        RETURN BOOK.ID%TYPE;
    FUNCTION get_book(p_id IN INT)
        RETURN CURSOR_TYPES.BOOK_TYPE;

    PROCEDURE create_comment(
        p_book_id IN "COMMENT".BOOK_ID%TYPE,
        p_user_id IN "COMMENT".USER_ID%TYPE,
        p_content IN "COMMENT".CONTENT%TYPE,
        p_chapter_id IN "COMMENT".CHAPTER_ID%TYPE DEFAULT NULL,
        p_created_at IN "COMMENT".CREATED_AT%TYPE DEFAULT SYSDATE);

    PROCEDURE create_comment_rate(
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE,
        p_user_id IN COMMENT_RATE.USER_ID%TYPE,
        p_rate IN COMMENT_RATE.RATE%TYPE DEFAULT 10
    );
    PROCEDURE create_rate(
        p_book_id IN RATE.BOOK_ID%TYPE,
        p_user_id IN RATE.USER_ID%TYPE,
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
END USER_PACKAGE;



CREATE OR REPLACE PACKAGE BODY USER_PACKAGE AS
    FUNCTION get_books_by_genre_id(p_id GENRE.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor IS
        p_cur CURSOR_TYPES.BOOK_CURSOR;
    BEGIN
        p_cur := PKG_BOOK.GET_BOOKS_BY_GENRE_ID(p_id);
        RETURN p_cur;
    END;

    FUNCTION get_books_by_author_id(p_id AUTHOR.ID%TYPE)
        RETURN CURSOR_TYPES.book_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_BOOKS_BY_AUTHOR_ID(p_id);
    END;

    FUNCTION get_chapters_by_book_id(p_id BOOK.ID%TYPE)
        RETURN CURSOR_TYPES.chapter_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_CHAPTERS_BY_BOOK_ID(p_id);
    END;

    FUNCTION get_genres_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.genre_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_GENRES_BY_BOOK_ID(p_id);
    END;

    FUNCTION get_authors_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.author_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_AUTHORS_BY_BOOK_ID(p_id);
    END;

    FUNCTION get_comments_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_COMMENTS_BY_BOOK_ID(p_id);
    END;

    FUNCTION get_rates_by_book_id(p_id BOOK.ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.rate_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_RATES_BY_BOOK_ID(p_id);
    END;

    FUNCTION get_genres_by_name(p_name GENRE.NAME%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.genre_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_GENRES_BY_NAME(p_name);
    END;

    FUNCTION get_authors_by_name(p_name AUTHOR.FIRST_NAME%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.author_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_AUTHORS_BY_NAME(p_name);
    END;

    FUNCTION get_rates_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.rate_cursor IS
    BEGIN
        RETURN PKG_BOOK.GET_RATES_BY_BOOK_ID(p_id);
    END;

    FUNCTION get_comments_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_cursor IS
    BEGIN
        RETURN PKG_USER.GET_COMMENTS_BY_USER_ID(p_id);
    END;

    FUNCTION get_comments_rate_by_comment_id(p_id "COMMENT".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.comment_rate_cursor IS
    BEGIN
        RETURN PKG_USER.GET_COMMENTS_RATE_BY_COMMENT_ID(p_id);
    END;

    FUNCTION get_saved_books_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.saved_book_cursor IS
    BEGIN
        RETURN PKG_USER.GET_SAVED_BOOKS_BY_USER_ID(p_id);
    END;

    FUNCTION get_folder_saved_books_by_user_id(p_id BOOKSSYS."USER".ID%TYPE DEFAULT NULL)
        RETURN CURSOR_TYPES.folder_saved_cursor IS
    BEGIN
        RETURN PKG_USER.GET_FOLDER_SAVED_BOOKS_BY_USER_ID(p_id);
    END;


    FUNCTION find_book(p_name IN VARCHAR2)
        RETURN BOOK.ID%TYPE IS
        v_id BOOK.ID%TYPE;
    BEGIN
        v_id := PKG_BOOK.FIND_BOOK_ID_BY_TITLE(p_name);
        IF v_id IS NOT NULL THEN RETURN v_id; END IF;
        v_id := PKG_BOOK.FIND_BOOK_ID_BY_DESCRIPTION(p_name);
        IF v_id IS NOT NULL THEN RETURN v_id; END IF;
        v_id := PKG_BOOK.FIND_BOOK_ID_BY_DESCRIPTION_QUERY(p_name);
        IF v_id IS NOT NULL THEN RETURN v_id; END IF;
        v_id := PKG_BOOK.FIND_BOOK_ID_BY_TITLE_LIKE(p_name);
        IF v_id IS NOT NULL THEN RETURN v_id; END IF;

        RETURN NULL;
    END;

    FUNCTION get_book(p_id IN INT)
        RETURN CURSOR_TYPES.BOOK_TYPE IS
        p_book CURSOR_TYPES.BOOK_TYPE;
    BEGIN
        PKG_BOOK.READ_BOOK(p_id, p_book);
        RETURN p_book;
    END;

    PROCEDURE create_comment_rate(
        p_comment_id IN COMMENT_RATE.COMMENT_ID%TYPE,
        p_user_id IN COMMENT_RATE.USER_ID%TYPE,
        p_rate IN COMMENT_RATE.RATE%TYPE DEFAULT 10
    ) AS
    BEGIN
        PKG_USER.CREATE_COMMENT_RATE(p_comment_id, p_user_id, p_rate);
    END;

    PROCEDURE create_saved_book(
        p_book_id IN SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN SAVED_BOOK.USER_ID%TYPE,
        p_type IN SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    ) AS
    BEGIN
        PKG_USER.CREATE_SAVED_BOOK(p_book_id, p_user_id, p_type);
    END;

    PROCEDURE create_folder_saved_book(
        p_book_id IN FOLDER_SAVED_BOOK.BOOK_ID%TYPE,
        p_user_id IN FOLDER_SAVED_BOOK.USER_ID%TYPE,
        p_folder_name IN FOLDER_SAVED_BOOK.SAVE_TYPE%TYPE DEFAULT 1
    ) AS
    BEGIN
        PKG_USER.CREATE_FOLDER_SAVED_BOOK(p_book_id, p_user_id, p_folder_name);
    END;

    PROCEDURE create_comment(
        p_book_id IN "COMMENT".BOOK_ID%TYPE,
        p_user_id IN "COMMENT".USER_ID%TYPE,
        p_content IN "COMMENT".CONTENT%TYPE,
        p_chapter_id IN "COMMENT".CHAPTER_ID%TYPE DEFAULT NULL,
        p_created_at IN "COMMENT".CREATED_AT%TYPE DEFAULT SYSDATE) AS
    BEGIN
        PKG_USER.CREATE_COMMENT(p_book_id, p_user_id,
                                p_content, p_chapter_id, p_created_at);
    END;

    PROCEDURE create_rate(
        p_book_id IN RATE.BOOK_ID%TYPE,
        p_user_id IN RATE.USER_ID%TYPE,
        p_rate IN COMMENT_RATE.RATE%TYPE DEFAULT 10
    ) AS
    BEGIN
        PKG_USER.CREATE_RATE(p_book_id,p_user_id,p_rate);
    END;


END USER_PACKAGE;