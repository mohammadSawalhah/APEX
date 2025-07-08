
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_EVALUATED_REQUESTS" 
      BEFORE INSERT OR UPDATE  
      ON INDIVIDUAL_REALESTATE_EVALUATED_REQUESTS 
      FOR EACH ROW  
        BEGIN  
            IF INSERTING THEN  
              IF :new.ID IS NULL THEN     
                   :new.ID := INDIVIDUAL_REALESTATE_EVALUATED_REQUESTS_SEQ.nextval;     
               END IF; 
               :new.CREATED_DATE := SYSDATE;  
               :new.CREATED_BY := nvl(v('APP_USER'), user); 
               :new.MODIFIED_DATE := SYSDATE;     
               :new.MODIFIED_BY := nvl(v('APP_USER'), user);   
            END IF;  
 
            IF updating THEN     
             :new.MODIFIED_DATE := SYSDATE;     
             :new.MODIFIED_BY := nvl(v('APP_USER'), user);   
            END IF; 
        END; 
     
    -- IF SQL%rowcount = 0 THEN ROLLBACK; END IF;


/
ALTER TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_EVALUATED_REQUESTS" ENABLE;