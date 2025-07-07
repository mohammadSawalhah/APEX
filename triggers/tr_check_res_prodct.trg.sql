
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_CHECK_RES_PRODCT" AFTER     
    UPDATE ON SELLER_ASSIGNED_FILES_DETAILS  
DECLARE
    l_count   NUMBER;
    l_result  NUMBER;
    l_message VARCHAR2(1000);
    l_product_response VARCHAR2(32000);
BEGIN
    BEGIN
        SELECT 1
          INTO l_count
          FROM SELLER_ASSIGNED_FILES_DETAILS
         WHERE RES_PRODUCT_ID IS NULL
           AND CREATED_DATE = SYSDATE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_count := NULL;
    END;

    IF l_count <> 0 THEN
        SELECT LISTAGG('id: ' || ID || ' Master: ' || MASTER_ID, ',')
          INTO l_product_response
          FROM SELLER_ASSIGNED_FILES_DETAILS
         WHERE RES_PRODUCT_ID IS NULL
           AND CREATED_DATE = SYSDATE;
           
        l_result := SYSTEM_CONTROLS.send_email ( 
                        p_to       => 'a.awad@mobasher.sa',
                        p_subject  => '💥 Elhaauna Ya gamaah al khair!💥',
                        p_html     => 'Call 911 because Response product id is null in ' || l_product_response,
                        p_message  => l_message
                    );    
    END IF;

    -- IF :new.RES_PRODUCT_ID IS NULL THEN
        -- l_result := SYSTEM_CONTROLS.send_email ( 
        --                 p_to       => 'mEeral.albokari@mobasher.sa',
        --                 p_subject  => '💥 Elhaauna Ya gamaah al khair!💥',
        --                 p_html     => 'Call 911 because Response product id is null in master id: ' || :new.MASTER_ID
        --                               || ' and APEX product id is: ' || :new.ID,
        --                 p_message  => l_message
        --             );    
    -- END IF;
END;

/
ALTER TRIGGER "MOBASHER"."TR_CHECK_RES_PRODCT" DISABLE;