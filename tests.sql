DECLARE
    p_cur CURSOR_TYPES.GENRE_CURSOR;
    p_rec GENRE%rowtype;
BEGIN

    p_cur := USER_PACKAGE.GET_GENRES_BY_NAME('о');
    LOOP
        FETCH p_cur INTO p_rec;
        EXIT WHEN p_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(p_rec.NAME);
    END LOOP;
    CLOSE p_cur;
end;

-- SELECT * FROM genre
DECLARE
v_Id int ;
BEGIN
        --    for v_i in 1..20
      --  loop
            PKG_BOOK.ADD_BOOK_AUTHOR(1,1);
        --end loop;
END;
--         dbms_output.PUT_LINE(v_book_record.TITLE);


DECLARE
    p_rec CHAPTER%rowtype;
    p_cur CURSOR_TYPES.CHAPTER_CURSOR;
BEGIN

    p_cur := USER_PACKAGE.GET_CHAPTERS_BY_BOOK_ID(2);
    LOOP
        FETCH p_cur INTO p_rec;
        EXIT when p_cur%notfound;
        DBMS_OUTPUT.PUT_LINE(p_rec.TITLE);
    END LOOP;
END;




DECLARE
    v_val INT;
    v_rec CURSOR_TYPES.BOOK_TYPE;
BEGIN

    v_val := USER_PACKAGE.FIND_BOOK('тест');
    v_rec := USER_PACKAGE.get_book(v_val);
    DBMS_OUTPUT.PUT_LINE(v_rec.title);

END;

DECLARE
BEGIN
--     USER_PACKAGE.CREATE_RATE(1,2,3);
    PKG_BOOK.CREATE_CHAPTER('name','some thing',1,2);
END;


SELECT * FROM BOOK;


