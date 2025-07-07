
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_TRANSPORTATION_USERS" 
  BEFORE INSERT OR UPDATE  
  ON  TRANSPORTATION_USERS 
  FOR EACH ROW  
    BEGIN  
        IF INSERTING THEN  
          IF :new.ID IS NULL THEN     
               :new.ID := TRANSPORTATION_USERS_SEQ.nextval;     
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
ALTER TRIGGER "MOBASHER"."TR_TRANSPORTATION_USERS" ENABLE;