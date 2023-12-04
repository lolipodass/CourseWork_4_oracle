DECLARE
    p_book_id NUMBER := 1;
    p_user_id NUMBER := 2;
    p_content VARCHAR2(500);
BEGIN

    FOR v_i IN 1..100000
        LOOP
            p_content := DBMS_RANDOM.STRING('P', 300);

            PKG_USER.CREATE_COMMENT(p_book_id, p_user_id, p_content);

            p_book_id := p_book_id + 1;
            p_user_id := p_user_id + 1;

            IF (p_book_id > 20) THEN p_book_id := 1; END IF;
            IF (p_user_id > 5) THEN p_user_id := 1; END IF;

            IF (MOD(v_i, 1000) = 0) THEN
                dbms_output.PUT_LINE(v_i);
            END IF;

        END LOOP;

    COMMIT;
END;


SELECT *
FROM "COMMENT";


SELECT *
          FROM "COMMENT" WHERE ((ID>180000 AND ID<200000) OR BOOK_ID>14) AND (BOOK_ID=12  OR  USER_ID=9);
BEGIN
--     PKG_USER.CHANGE_PASSWORD(P_ID => 1, P_OLD_PASSWORD => 'SOME', P_NEW_PASSWORD => 'SOMETHINK');

        PKG_USER.CREATE_USER(P_LOGIN => 'SER', P_EMAIL => 'some@gmail.com', P_AVATAR => NULL, P_DISPLAY_NAME => 'JOR',
                         P_PASSWORD => 'SOME');
    PKG_USER.CREATE_USER(P_LOGIN => 'JONER', P_EMAIL => 'sodfmer@gmail.com', P_AVATAR => NULL, P_DISPLAY_NAME => 'JdfORE',
                         P_PASSWORD => 'SOME');
    PKG_USER.CREATE_USER(P_LOGIN => 'GON', P_EMAIL => 'ANY@gmail.com', P_AVATAR => NULL, P_DISPLAY_NAME => 'JOR',
                         P_PASSWORD => 'SOME');
    PKG_USER.CREATE_USER(P_LOGIN => 'SERA', P_EMAIL => 'some@gail.com', P_AVATAR => NULL, P_DISPLAY_NAME =>NULL,
                         P_PASSWORD => 'SOME');
    PKG_USER.CREATE_USER(P_LOGIN => 'GERA', P_EMAIL => 'Dome@gmail.com', P_AVATAR => NULL, P_DISPLAY_NAME => 'DA',
                         P_PASSWORD => 'SOME');

END;
