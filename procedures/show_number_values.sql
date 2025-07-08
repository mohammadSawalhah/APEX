
  CREATE OR REPLACE EDITIONABLE PROCEDURE "MOBASHER"."SHOW_NUMBER_VALUES" (
   table_in    IN VARCHAR2,
   column_in   IN VARCHAR2,
   where_in    IN VARCHAR2 DEFAULT NULL
) IS
   TYPE values_t IS TABLE OF NUMBER;
   l_values   values_t;
BEGIN
    EXECUTE IMMEDIATE
        'SELECT '
        || column_in
        || ' FROM '
        || table_in
        || ' WHERE '
        || where_in
    BULK COLLECT INTO l_values;

    FOR indx IN 1 .. l_values.COUNT LOOP
        DBMS_OUTPUT.put_line (l_values (indx));
    END LOOP;
END;
/