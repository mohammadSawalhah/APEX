
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_TICKET_CHAT" BEFORE  
  INSERT OR UPDATE ON TICKET_CHAT 
  FOR EACH ROW 
BEGIN  
    IF INSERTING THEN     
        IF :new.ID IS NULL THEN     
           :new.ID := TICKET_CHAT_SEQ.nextval;     
        END IF; 
        :new.created_date := SYSDATE;     
        -- :new.created_by := nvl(v('APP_USER'), user); 
    ELSIF UPDATING THEN 
        :new.modified_date := SYSDATE; 
        :new.modified_by := nvl(v('APP_USER'), user); 
    ENd IF; 
END TR_TICKET_CHAT;

/
ALTER TRIGGER "MOBASHER"."TR_TICKET_CHAT" ENABLE;