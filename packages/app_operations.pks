
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."APP_OPERATIONS" AS

    TYPE function_result IS RECORD (
        code    NUMBER,
        message VARCHAR2(256)
    );

    FUNCTION CREATE_NOTES (
        p_user_id         IN NUMBER,
        -- p_emp_id          IN NUMBER,
        p_app_id          IN NUMBER DEFAULT v('APP_ID'),
        p_page_id         IN NUMBER DEFAULT v('APP_PAGE_ID'),
        p_object_id       IN NUMBER,
        p_operation_type  IN NUMBER,
        p_note            IN VARCHAR2,
        p_lang            IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER;


END APP_OPERATIONS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."APP_OPERATIONS" AS
    FUNCTION CREATE_NOTES (
        p_user_id         IN NUMBER,
        -- p_emp_id          IN NUMBER,
        p_app_id          IN NUMBER DEFAULT v('APP_ID'),
        p_page_id         IN NUMBER DEFAULT v('APP_PAGE_ID'),
        p_object_id       IN NUMBER,
        p_operation_type  IN NUMBER,
        p_note            IN VARCHAR2,
        p_lang            IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER AS
        -- v_category_id     NUMBER;
        v_note_id         NUMBER;
    BEGIN 
        IF p_object_id IS NULL OR p_operation_type IS NULL OR p_note IS NULL OR p_user_id IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF; 

        INSERT INTO APP_NOTES(APP_ID, PAGE_ID, OBJECT_ID, OPERATION_TYPE, NOTE, USER_ID)
            VALUES (v('APP_ID'), v('APP_PAGE_ID'), p_object_id, p_operation_type, p_note, p_user_id)
            RETURNING ID INTO v_note_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
            ROLLBACK;
        END IF;

        RETURN 1;         
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SQL_ERROR', p_PROCESS_NAME => 'APP_OPERATIONS.create_notes', p_ERROR_CODE => sqlcode, p_ERROR_MESSAGE => sqlerrm,
                                        p_logger_name => user, p_OBJECT_TYPE => '', p_OBJECT_ID => v_note_id);
            RETURN -1;
    END CREATE_NOTES;

END APP_OPERATIONS;
/