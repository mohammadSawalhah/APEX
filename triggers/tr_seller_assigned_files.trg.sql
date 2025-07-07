
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_SELLER_ASSIGNED_FILES" BEFORE
    INSERT OR UPDATE OR DELETE ON SELLER_ASSIGNED_FILES    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := SELLER_ASSIGNED_FILES_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ELSIF updating then
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END;

/
ALTER TRIGGER "MOBASHER"."TR_SELLER_ASSIGNED_FILES" ENABLE;