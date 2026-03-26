-- Sample Snowflake View Creation Script

-- Creating a view to select employee details
CREATE OR REPLACE VIEW EMPLOYEE_VIEW AS
SELECT 
    EMPLOYEE_ID, 
    FIRST_NAME, 
    LAST_NAME, 
    EMAIL,
    DEPARTMENT,
    SALARY
FROM 
    EMPLOYEES
WHERE 
    STATUS = 'ACTIVE';
