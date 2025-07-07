
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."EXTRACT_NUMBER" (in_varchar varchar2) return number is
begin
--   return regexp_replace(in_varchar, '[^[:digit:]]', '');
  return regexp_replace(in_varchar, '[^0-9]', '');
end;
/