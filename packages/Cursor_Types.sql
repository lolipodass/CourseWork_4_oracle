CREATE OR REPLACE PACKAGE cursor_Types AS
    TYPE BOOK_TYPE IS RECORD
                      (
                          ID          INT,
                          title       VARCHAR2(200),
                          description VARCHAR2(1000),
                          cover       BLOB,
                          rating      NUMBER(3, 2),
                          "VIEWS"     INT,
                          status      INT,
                          created_at  DATE
                      );
    TYPE CHAPTER_TYPE IS RECORD
                         (
                             ID         INT,
                             title      VARCHAR2(200),
                             content    NCLOB,
                             "number"   INT,
                             created_at DATE DEFAULT sysdate,
                             book_Id    NUMBER
                         );


    TYPE chapter_cursor IS REF CURSOR RETURN CHAPTER%ROWTYPE;
    TYPE genre_cursor IS REF CURSOR RETURN GENRE%ROWTYPE;
    TYPE author_cursor IS REF CURSOR RETURN AUTHOR%ROWTYPE;
    TYPE comment_cursor IS REF CURSOR RETURN "COMMENT"%ROWTYPE;
    TYPE rate_cursor IS REF CURSOR RETURN RATE%ROWTYPE;
    TYPE book_cursor IS REF CURSOR RETURN BOOK%ROWTYPE;
    TYPE comment_rate_cursor IS REF CURSOR RETURN COMMENT_RATE%ROWTYPE;
    TYPE saved_book_cursor IS REF CURSOR RETURN SAVED_BOOK%ROWTYPE;
    TYPE folder_saved_cursor IS REF CURSOR RETURN FOLDER_SAVED_BOOK%ROWTYPE;

END cursor_Types;

