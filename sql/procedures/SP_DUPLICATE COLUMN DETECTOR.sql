-- =============================================================================
-- DUPLICATE COLUMN DETECTOR (Version 1 - Original)
-- Purpose: Detect potentially redundant columns in RAW_DEV_DB.SOURCE schema
--          by finding column pairs with matching base names but different
--          common suffixes (e.g., CUSTOMER_ID vs CUSTOMER_NO).
-- How it works:
--   1. Self-joins INFORMATION_SCHEMA.COLUMNS to find column pairs sharing
--      the same base name but differing in suffix (_ID, _NO, _KEY, etc.)
--   2. Dynamically builds UNION ALL queries to compare values row-by-row
--   3. Classifies each pair as DUPLICATE, NULL_COLUMN, or NOT_DUPLICATE
-- =============================================================================

EXECUTE IMMEDIATE $$
DECLARE
    sql_text STRING;  -- Holds the dynamically generated SQL
    res RESULTSET;    -- Stores the final query result
BEGIN
    -- Build a dynamic UNION ALL query: for each column pair, generate a SELECT
    -- that compares values using EQUAL_NULL (NULL-safe equality) after TRIMming
    -- and casting to VARCHAR for consistent comparison across data types
    SELECT LISTAGG(
        'SELECT ''' || TABLE_NAME || ''' AS TABLE_NAME, ''' 
        || COL1 || ''' AS COLUMN_1, ''' 
        || COL2 || ''' AS COLUMN_2, '
        || 'COUNT(*) AS TOTAL_ROWS, '                                          -- Total rows in the table
        || 'SUM(CASE WHEN NOT EQUAL_NULL(TRIM(' || COL1 || ')::VARCHAR, TRIM(' || COL2 || ')::VARCHAR) THEN 1 ELSE 0 END) AS MISMATCHED_ROWS, '  -- Rows where values differ (NULL-safe)
        || 'SUM(CASE WHEN ' || COL1 || ' IS NULL THEN 1 ELSE 0 END) AS COL1_NULL_COUNT, '  -- NULL count in first column
        || 'SUM(CASE WHEN ' || COL2 || ' IS NULL THEN 1 ELSE 0 END) AS COL2_NULL_COUNT '   -- NULL count in second column
        || 'FROM RAW_DEV_DB.' || TABLE_SCHEMA || '.' || TABLE_NAME,
        ' UNION ALL '  -- Combine all per-pair queries into one result set
    ) 
    INTO sql_text
    FROM (
        -- Subquery: find all column pairs in the same table with similar base names
        SELECT DISTINCT
            c1.TABLE_SCHEMA,
            c1.TABLE_NAME,
            LEAST(c1.COLUMN_NAME, c2.COLUMN_NAME) AS COL1,       -- Alphabetically first column
            GREATEST(c1.COLUMN_NAME, c2.COLUMN_NAME) AS COL2    -- Alphabetically second column
        FROM RAW_DEV_DB.INFORMATION_SCHEMA.COLUMNS c1
        JOIN RAW_DEV_DB.INFORMATION_SCHEMA.COLUMNS c2             -- Self-join to create column pairs
            ON c1.TABLE_SCHEMA = c2.TABLE_SCHEMA
            AND c1.TABLE_NAME = c2.TABLE_NAME
            AND c1.COLUMN_NAME < c2.COLUMN_NAME                  -- Avoid duplicates & self-pairs
        WHERE c1.TABLE_SCHEMA = 'SOURCE'
          -- Strip common suffixes to get base name; base names must match
          AND REGEXP_REPLACE(c1.COLUMN_NAME, '_(ID|NO|NUM|NBR|NUMBER|KEY|CODE|CD|DESC|NAME|TXT|TEXT|VAL|VALUE|AMT|AMOUNT|QTY|QUANTITY|DT|DATE|FLAG|IND|INDICATOR|TYPE|TYP|STATUS|STAT|STS)$', '') 
            = REGEXP_REPLACE(c2.COLUMN_NAME, '_(ID|NO|NUM|NBR|NUMBER|KEY|CODE|CD|DESC|NAME|TXT|TEXT|VAL|VALUE|AMT|AMOUNT|QTY|QUANTITY|DT|DATE|FLAG|IND|INDICATOR|TYPE|TYP|STATUS|STAT|STS)$', '')
          -- Ensure the suffixes themselves are different (otherwise it's the same column)
          AND REGEXP_SUBSTR(c1.COLUMN_NAME, '_(ID|NO|NUM|NBR|NUMBER|KEY|CODE|CD|DESC|NAME|TXT|TEXT|VAL|VALUE|AMT|AMOUNT|QTY|QUANTITY|DT|DATE|FLAG|IND|INDICATOR|TYPE|TYP|STATUS|STAT|STS)$') 
           != REGEXP_SUBSTR(c2.COLUMN_NAME, '_(ID|NO|NUM|NBR|NUMBER|KEY|CODE|CD|DESC|NAME|TXT|TEXT|VAL|VALUE|AMT|AMOUNT|QTY|QUANTITY|DT|DATE|FLAG|IND|INDICATOR|TYPE|TYP|STATUS|STAT|STS)$')
    );

    -- Guard: exit early if no matching column pairs were found
    IF (sql_text IS NULL) THEN
        res := (SELECT 'No matching column pairs found' AS MESSAGE);
        RETURN TABLE(res);
    END IF;

    -- Wrap the dynamic query with classification logic:
    --   NULL_COLUMN    = one column is entirely NULL (likely unused/deprecated)
    --   DUPLICATE      = zero mismatches, columns hold identical data
    --   NOT_DUPLICATE  = values differ, columns are distinct
    sql_text := 'SELECT TABLE_NAME, COLUMN_1, COLUMN_2, TOTAL_ROWS, MISMATCHED_ROWS, '
        || 'CASE '
        || '  WHEN COL1_NULL_COUNT = TOTAL_ROWS THEN CONCAT(''NULL_COLUMN ('', COLUMN_1, '')'') '
        || '  WHEN COL2_NULL_COUNT = TOTAL_ROWS THEN CONCAT(''NULL_COLUMN ('', COLUMN_2, '')'') '
        || '  WHEN MISMATCHED_ROWS = 0 THEN ''DUPLICATE'' '
        || '  ELSE ''NOT_DUPLICATE'' '
        || 'END AS STATUS '
        || 'FROM (' || sql_text || ') ORDER BY STATUS, TABLE_NAME, COLUMN_1';

    -- Execute the fully assembled dynamic SQL and return results
    res := (EXECUTE IMMEDIATE :sql_text);
    RETURN TABLE(res);
END;
$$;
