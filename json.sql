CREATE OR REPLACE PROCEDURE TO_JSON
    IS
BEGIN
    DECLARE
        output_file UTL_FILE.FILE_TYPE;
        json_data   CLOB;
        CURSOR p_cursor IS
            SELECT JSON_OBJECT(
                           'USER_ID' VALUE USER_ID,
                           'BOOK_ID' VALUE BOOK_ID,
                           'CONTENT' VALUE CONTENT
                       ) AS json_data
            FROM "COMMENT"
            WHERE ROWNUM < 10;
    BEGIN


            output_file := UTL_FILE.FOPEN('UTL_DIR', 'com.json', 'W');

            FOR com IN p_cursor
                LOOP
                    json_data := com.json_data;
                    UTL_FILE.PUT_LINE(output_file, json_data);
                END LOOP;

            UTL_FILE.FCLOSE(output_file);
        END;
    END;


    CREATE OR REPLACE PROCEDURE FROM_JSON
AS BEGIN
    INSERT INTO "COMMENT"(USER_ID, BOOK_ID, CONTENT)
     SELECT USER_ID, BOOK_ID, CONTENT
FROM   JSON_TABLE(BFILENAME('UTL_DIR', 'com.json'), '$[*]'
                  COLUMNS (
                    USER_ID VARCHAR2(50) PATH '$.USER_ID',
                    BOOK_ID VARCHAR2(50) PATH '$.BOOK_ID',
                    CONTENT VARCHAR2(500) PATH '$.CONTENT'
                  )
                 );
end;


    DECLARE
    BEGIN
        TO_JSON;
    END;

    BEGIN
        FROM_JSON;
    END;


    CREATE
    DIRECTORY utl_dir AS 'C:\oracle\Export';
    GRANT READ, WRITE ON DIRECTORY utl_dir TO PUBLIC;


    SELECT * FROM ALL_DIRECTORIES;