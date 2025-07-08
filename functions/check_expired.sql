
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."CHECK_EXPIRED" (p_app_user VARCHAR2) 
 RETURN NUMBER AS 
    l_return NUMBER; 
BEGIN 
    BEGIN 
        SELECT 1 
          INTO l_return 
          FROM APP_USERS 
         WHERE UPPER(USER_NAME) = UPPER(p_app_user) 
           AND CHANGE_PASS_NEXT_LOGIN = 'Y'  
           AND ALLOW_CHANGE_PASS = 'Y'; 
        
        RETURN l_return; 
    EXCEPTION 
        WHEN no_data_found THEN 
            l_return := 0; 
    END;

    RETURN l_return; 
END check_expired;
/