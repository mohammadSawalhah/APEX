
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_APP_ROLE_GROUPS" BEFORE    
    INSERT OR UPDATE OR DELETE ON "SELLER_ROLE_GROUPS"    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := APP_ROLE_GROUPS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
END;


/
ALTER TRIGGER "MOBASHER"."TR_APP_ROLE_GROUPS" ENABLE;