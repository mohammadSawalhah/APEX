
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_SUB_CATEGORIES" BEFORE    
    INSERT OR UPDATE OR DELETE ON SUB_CATEGORIES    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := SUB_CATEGORIES_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);
    ELSIF updating THEN    
        :new.modified_date := SYSDATE;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END;


/
ALTER TRIGGER "MOBASHER"."TR_SUB_CATEGORIES" ENABLE;