
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."TEST_DRIVEN" AS

    FUNCTION test_unit (   
        p_code IN VARCHAR2,
        p_link OUT VARCHAR2
    ) RETURN VARCHAR2;

END test_driven;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."TEST_DRIVEN" AS

    FUNCTION test_unit (
        p_code IN VARCHAR2,
        p_link OUT VARCHAR2
    ) RETURN VARCHAR2 IS
       v_result   NUMBER;
    BEGIN
        CASE p_code
            WHEN 'username_duplication' THEN
                SELECT count(1), 'f?p=' || V('APP_ID') || ':200:'|| V('APP_SESSION') ||':::::'
                  INTO v_result, p_link
                  FROM APP_USERS
                 WHERE NVL(ACTIVE_FLAG, 'N') = 'Y'
                   AND IS_DELETED = 0
                 GROUP BY USER_NAME
                HAVING count(1) > 1;
            WHEN 'seller_duplication' THEN
                SELECT COUNT(1), 'f?p=' || V('APP_ID') || ':16:'|| V('APP_SESSION') ||':::::'
                  INTO v_result, p_link
                  FROM SELLERS
                 WHERE NVL(IS_ACTIVE, 0) = 1
                   AND IS_DELETED = 0
                 GROUP BY IDENTITY_NUMBER
                HAVING count(1) > 1;
            WHEN 'seller_instrument_number_duplication' THEN
                SELECT COUNT(1), 'f?p=' || V('APP_ID') || ':13:'|| V('APP_SESSION') ||':::::'
                  INTO v_result, p_link
                  FROM products a;
            WHEN 'seller_vin_number_duplication' THEN
                SELECT COUNT(1), 'f?p=' || V('APP_ID') || ':11:'|| V('APP_SESSION') ||':::::'
                  INTO v_result, p_link
                  FROM products cp;
            WHEN 'prop_not_available_not_request' THEN
                SELECT COUNT(1), 'f?p=' || V('APP_ID') || ':12:'|| V('APP_SESSION') ||':::::'
                  INTO v_result, p_link
                  FROM products p;
            WHEN 'recent_ticket_not_open' THEN
                SELECT COUNT(1), 'f?p=' || V('APP_ID') || ':14:'|| V('APP_SESSION') ||':::::'
                  INTO v_result, p_link
                  FROM products;
            WHEN 'notification_failure' THEN
                SELECT COUNT(1), 'f?p=' || V('APP_ID') || ':15:'|| V('APP_SESSION') ||':::::'
                  INTO v_result, p_link
                  FROM products;
            --in the  seller sign up, let the admin sign in with the cr number (if the admin has 1 or more cr/companies number )
            ELSE
                v_result := 0;
        END CASE;

        IF v_result > 0 THEN
            RETURN 'FALSE';   
        ELSE
            RETURN 'TRUE';   
        END IF;  
        
    EXCEPTION   
        WHEN OTHERS THEN   
            SYSTEM_CONTROLS.ERROR_LOGS(p_ERROR_TYPE => 'SQL_ERROR',p_PROCESS_NAME => 'test_driven.test_unit',p_ERROR_CODE => sqlcode,p_ERROR_MESSAGE => sqlerrm , p_logger_name => user , p_OBJECT_TYPE => p_code, p_OBJECT_ID => NULL);   
            RETURN 'FALSE';         
    END test_unit;     
   
--<AWS_SECRET>//////////////////////////////////////////////////////////////////////////////////////////////////    
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

END test_driven;
/