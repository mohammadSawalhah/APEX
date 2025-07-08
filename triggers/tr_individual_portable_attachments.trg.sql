
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_INDIVIDUAL_PORTABLE_ATTACHMENTS" BEFORE 
  INSERT OR UPDATE ON INDIVIDUAL_PORTABLE_ATTACHMENTS
  FOR EACH ROW
BEGIN 
    IF INSERTING THEN    
        IF :new.ID IS NULL THEN    
           :new.ID := INDIVIDUAL_PORTABLE_ATTACHMENTS_SEQ.nextval;    
        END IF;
        IF :new.created_by IS NULL THEN   
           :new.created_by := nvl(v('APP_USER'), user); 
        END IF;
        IF :new.modified_by IS NULL THEN  
           :new.modified_by := nvl(v('APP_USER'), user);
        END IF;
        :new.created_date := SYSDATE;    
        :new.modified_date := SYSDATE;    
    ELSIF UPDATING THEN
        :new.modified_date := SYSDATE;
        
        IF :new.modified_by IS NULL THEN  
           :new.modified_by := nvl(v('APP_USER'), user);
        END IF;
    ENd IF;
END TR_INDIVIDUAL_PORTABLE_ATTACHMENTS;

/
ALTER TRIGGER "MOBASHER"."TR_INDIVIDUAL_PORTABLE_ATTACHMENTS" ENABLE;