
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_ATTACHMENTS" BEFORE 
  INSERT OR UPDATE ON INDIVIDUAL_REALESTATE_ATTACHMENTS
  FOR EACH ROW
BEGIN 
    IF INSERTING THEN    
        IF :new.ID IS NULL THEN    
           :new.ID := INDIVIDUAL_REALESTATE_ATTACHMENTS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ELSIF UPDATING THEN
        :new.modified_date := SYSDATE;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END TR_INDIVIDUAL_REALESTATE_ATTACHMENTS;


/
ALTER TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_ATTACHMENTS" ENABLE;