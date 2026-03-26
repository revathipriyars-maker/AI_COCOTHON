-- Duplicate Column Detector Utility Script

-- This utility script checks for duplicate columns in a given SQL table.
-- It takes the table name as input and returns a list of duplicate column names.

CREATE OR REPLACE FUNCTION duplicate_column_detector(table_name TEXT)
RETURNS TABLE(column_name TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT column_name
    FROM information_schema.columns
    WHERE table_name = table_name
    GROUP BY column_name
    HAVING COUNT(*) > 1;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT * FROM duplicate_column_detector('your_table_name');