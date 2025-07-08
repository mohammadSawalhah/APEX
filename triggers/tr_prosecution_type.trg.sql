
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_PROSECUTION_TYPE" BEFORE    
    INSERT OR UPDATE OR DELETE ON "INFATH_PROSECUTION_TYPE"    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := PROSECUTION_TYPE_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
END;
-- '||CHR(0)||';

/
ALTER TRIGGER "MOBASHER"."TR_PROSECUTION_TYPE" ENABLE;