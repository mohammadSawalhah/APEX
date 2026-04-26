
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GET_JOURNAL_CHANGED_COLUMNS" (
  p_journal_table  IN VARCHAR2,
  p_id             IN NUMBER
) RETURN VARCHAR2
IS
  l_changed_columns VARCHAR2(4000);
  l_sql             VARCHAR2(1000);
BEGIN
  -- Dynamic SQL to get CHANGED_COLUMNS from latest journal for this ID
  l_sql := '
    SELECT CHANGED_COLUMNS
    FROM (
      SELECT CHANGED_COLUMNS
      FROM ' || p_journal_table || '
      WHERE ID = :1 AND NVL(IS_DISMISSED, 0) = 0
      ORDER BY JOURNAL_ID DESC
    )
    WHERE ROWNUM = 1';

  EXECUTE IMMEDIATE l_sql INTO l_changed_columns USING p_id;

  RETURN l_changed_columns;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN NULL;
END;
/