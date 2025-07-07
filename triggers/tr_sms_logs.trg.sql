
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_SMS_LOGS" BEFORE 
  INSERT OR UPDATE ON SMS_LOGS
  FOR EACH ROW
BEGIN 
    IF INSERTING THEN    
        IF :new.ID IS NULL THEN    
           :new.ID := SMS_LOGS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        -- :new.modified_date := SYSDATE;    
        -- :new.modified_by := nvl(v('APP_USER'), user);  
    ELSIF UPDATING THEN
        :new.modified_date := SYSDATE;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END TR_SMS_LOGS;

/
ALTER TRIGGER "MOBASHER"."TR_SMS_LOGS" ENABLE;