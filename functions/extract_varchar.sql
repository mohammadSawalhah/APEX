
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."EXTRACT_VARCHAR" (in_varchar varchar2) return varchar2 is
begin

  return regexp_replace(in_varchar, '[^a-z and ^A-Z and ء-ي and +]', '');
end;
/