
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."ARRAYTOSTR" (
    pJSONArray  varchar2,
    pDelim      varchar2 := ','
) return varchar2 is
  vJA       JSON_Array_T;
  vResult   varchar2(4000 byte);
begin
  if pJSONArray is not null then
    vJA := JSON_Array_T(pJSONArray);
    
    for vIndex in 0..vJA.get_Size - 1
    loop
      vResult := vResult || case when vIndex > 0 then pDelim end || vJA.get_String(vIndex);
    end loop;
  end if;
  return vResult;
end;
/