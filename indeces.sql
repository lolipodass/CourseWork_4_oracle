CREATE INDEX book_description_idx ON book (DESCRIPTION)
    INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ( 'SYNC (EVERY "SYSDATE+1/24")' );
--     INDEXTYPE IS CTXSYS.CONTEXT;

CREATE INDEX book_title_idx ON book (TITLE)
    INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ( 'SYNC (EVERY "SYSDATE+1/24")' );

CREATE INDEX chapter_book_id_number_idx on CHAPTER(BOOK_ID,"NUMBER");
CREATE INDEX comment_book_id_idx on "COMMENT"(BOOK_ID);
CREATE INDEX comment_user_id_idx on "COMMENT"(USER_ID);
CREATE INDEX rate_user_id_idx on "RATE"(USER_ID);
CREATE INDEX folder_saved_book_book_id_idx on FOLDER_SAVED_BOOK(BOOK_ID);
CREATE BITMAP INDEX book_genre_bitmap_idx on BOOK_GENRE(GENRE_ID);

DROP INDEX book_title_idx;
DROP INDEX book_description_idx;

BEGIN

--         ctx_ddl.sync_index(upper('comment_book_id_idx'));
--         ctx_ddl.sync_index(upper('comment_user_id_idx'));
END;



SELECT *
FROM user_indexes
WHERE table_name = 'BOOK';

-- DROP INDEX book_description_idx;
