
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_AFTER_ASSIGNED" 
  BEFORE INSERT OR UPDATE 
  ON INDIVIDUAL_REALESTATE_after_assigned
  FOR EACH ROW 
    BEGIN 
        IF INSERTING THEN 
          IF :new.ID IS NULL THEN    
               :new.ID := INDIVIDUAL_REALESTATE_after_assigned_SEQ.nextval;    
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

/
ALTER TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_AFTER_ASSIGNED" ENABLE;