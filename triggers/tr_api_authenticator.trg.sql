
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_API_AUTHENTICATOR" BEFORE    
    INSERT OR UPDATE OR DELETE ON API_AUTHENTICATOR    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := API_AUTHENTICATOR_SEQ.nextval;    
        END IF;
        :new.generated_date := SYSDATE;
        :new.expired_date := SYSDATE + 5 / (24 * 60);
    ELSIF updating THEN
        :new.generated_date := SYSDATE;
        :new.expired_date := SYSDATE + 5 / (24 * 60);
    END IF;
END;

/
ALTER TRIGGER "MOBASHER"."TR_API_AUTHENTICATOR" ENABLE;