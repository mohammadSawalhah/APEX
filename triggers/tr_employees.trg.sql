
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_EMPLOYEES" BEFORE
    INSERT OR UPDATE OR DELETE ON EMPLOYEES    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := EMPLOYEES_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
    IF updating THEN    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
END;

/
ALTER TRIGGER "MOBASHER"."TR_EMPLOYEES" ENABLE;