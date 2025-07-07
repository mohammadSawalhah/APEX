
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_PROPERTY_DIMENSIONS" BEFORE
    INSERT OR UPDATE OR DELETE ON PROPERTY_DIMENSIONS    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := PROPERTY_DIMENSIONS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
END;


/
ALTER TRIGGER "MOBASHER"."TR_PROPERTY_DIMENSIONS" ENABLE;