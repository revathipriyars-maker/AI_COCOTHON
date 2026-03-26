-- Sample Snowflake Stored Procedure

CREATE OR REPLACE PROCEDURE sample_procedure()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    var current_time = new Date();
    return 'Current Time: ' + current_time.toUTCString();
$$;