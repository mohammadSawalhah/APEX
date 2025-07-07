
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_PROPERTY_SERVICES" BEFORE
    INSERT OR UPDATE OR DELETE ON PROPERTY_SERVICES    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := PROPERTY_SERVICES_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
END;


/
ALTER TRIGGER "MOBASHER"."TR_PROPERTY_SERVICES" ENABLE;