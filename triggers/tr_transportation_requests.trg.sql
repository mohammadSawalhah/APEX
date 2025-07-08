
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_TRANSPORTATION_REQUESTS" 
  BEFORE INSERT OR UPDATE  
  ON  TRANSPORTATION_REQUESTS 
  FOR EACH ROW  
    BEGIN  
        IF INSERTING THEN  
          IF :new.ID IS NULL THEN     
               :new.ID := TRANSPORTATION_REQUESTS_SEQ.nextval;     
           END IF; 
           :new.CREATED_DATE := SYSDATE;  
           :new.CREATED_BY := nvl(v('APP_USER'), user); 
        END IF;  
 
        IF updating THEN     
         :new.MODIFIED_DATE := SYSDATE;     
         :new.MODIFIED_BY := nvl(v('APP_USER'), user);   
        END IF; 
END;


/
ALTER TRIGGER "MOBASHER"."TR_TRANSPORTATION_REQUESTS" ENABLE;