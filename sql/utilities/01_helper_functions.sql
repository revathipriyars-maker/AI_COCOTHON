-- Sample Snowflake Helper Functions

-- Function to get current date and time in UTC
CREATE OR REPLACE FUNCTION get_current_utc() RETURNS STRING
  LANGUAGE SQL
  AS
  $$
  SELECT TO_CHAR(CURRENT_TIMESTAMP(), 'YYYY-MM-DD HH24:MI:SS')
  $$;

-- Function to get the current user's login
CREATE OR REPLACE FUNCTION get_current_user() RETURNS STRING
  LANGUAGE SQL
  AS
  $$
  SELECT CURRENT_USER()
  $$;

-- Function to validate email format
CREATE OR REPLACE FUNCTION validate_email(email STRING) RETURNS BOOLEAN
  LANGUAGE SQL
  AS
  $$
  RETURN REGEXP_LIKE(email, '^[^@]+@[^@]+\.[a-zA-Z]{2,}$');
  $$;

-- Function to fetch distinct values from a column in a given table
CREATE OR REPLACE FUNCTION fetch_distinct_values(table_name STRING, column_name STRING) RETURNS TABLE VARCHAR
  LANGUAGE SQL
  AS
  $$
  RETURN TABLE(SELECT DISTINCT column_name FROM IDENTIFIER(table_name));
  $$;