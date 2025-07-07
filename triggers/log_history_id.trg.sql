
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."LOG_HISTORY_ID" 
before insert on SYS_LOG_HISTORY for each row 
begin 
if :NEW.LOG_HISTORY_ID is null then select nvl(max(LOG_HISTORY_ID),0)+1 into :NEW.LOG_HISTORY_ID 
from SYS_LOG_HISTORY
; end if;
if :NEW.REGUSER is null then 

:NEW.REGUSER := nvl(v('APP_USER'), 'SYSTEM');
 
 end if;
 end;


/
ALTER TRIGGER "MOBASHER"."LOG_HISTORY_ID" ENABLE;