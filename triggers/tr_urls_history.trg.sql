
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_URLS_HISTORY" 
  BEFORE INSERT OR UPDATE  
  ON URLS_HISTORY 
  FOR EACH ROW  
    BEGIN  
        IF INSERTING THEN  
            IF :new.ID IS NULL THEN
                :new.ID := URLS_HISTORY_SEQ.nextval;     
            END IF; 
            IF :new.CREATED_BY IS NULL THEN
                :new.CREATED_BY := nvl(v('APP_USER'), user); 
            END IF; 
            IF :new.MODIFIED_BY IS NULL THEN
                :new.MODIFIED_BY := nvl(v('APP_USER'), user);   
            END IF; 
           :new.CREATED_DATE := SYSDATE;    
           :new.MODIFIED_DATE := SYSDATE;     
        END IF;  
 
        IF updating THEN     
            :new.MODIFIED_DATE := SYSDATE; 
            IF :new.MODIFIED_BY IS NULL THEN
                :new.MODIFIED_BY := nvl(v('APP_USER'), user);   
            END IF; 
        END IF; 
    END;

/
ALTER TRIGGER "MOBASHER"."TR_URLS_HISTORY" ENABLE;