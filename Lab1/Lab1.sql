SET SERVEROUTPUT ON;

DROP TABLE MyTable;

-- task 1
CREATE TABLE MyTable (
    id NUMBER PRIMARY KEY,
    val NUMBER NOT NULL
);


--task 3
CREATE OR REPLACE FUNCTION compare_even_odd_count RETURN VARCHAR IS
    even_count NUMBER := 0;
    odd_count NUMBER := 0;
BEGIN
    FOR line IN (SELECT * FROM MyTable) LOOP
        IF MOD(line.val, 2) = 0 THEN
            even_count := even_count + 1;
        ELSE
            odd_count := odd_count + 1;
        END IF;
    END LOOP;
    
    IF even_count = odd_count THEN
        RETURN 'EQUAL';
    ELSIF even_count > odd_count THEN
        RETURN 'TRUE';
    ELSE
        RETURN 'FALSE';
    END IF;
    
END compare_even_odd_count;
/


-- task 4
CREATE OR REPLACE FUNCTION get_insert_query(table_name VARCHAR2, id NUMBER, val NUMBER) RETURN VARCHAR2 IS
BEGIN
    RETURN utl_lms.format_message('INSERT INTO %s(id, val) VALUES (%d, %d)', table_name,TO_CHAR(id), TO_CHAR(val));
END;
/


-- task 5
CREATE OR REPLACE PROCEDURE insert_data(table_name VARCHAR, id NUMBER, val NUMBER) IS
BEGIN
    EXECUTE IMMEDIATE get_insert_query(table_name, id, val);
END;
/


CREATE OR REPLACE PROCEDURE update_data(table_name VARCHAR2, id NUMBER, val NUMBER) IS
BEGIN
    EXECUTE IMMEDIATE utl_lms.format_message('UPDATE %s SET val=%d WHERE id=%d', table_name, TO_CHAR(val), TO_CHAR(id));
END;
/


CREATE OR REPLACE PROCEDURE delete_data(table_name VARCHAR2, id NUMBER) IS
BEGIN
    EXECUTE IMMEDIATE utl_lms.format_message('DELETE FROM %s WHERE id=%d', table_name, TO_CHAR(id));
END;
/


-- task 6
CREATE OR REPLACE FUNCTION get_year_income(monthly_income NUMBER, adding_percent NUMBER) 
RETURN VARCHAR2
IS
    result_value REAL;
    negative_value EXCEPTION;
    null_value EXCEPTION;
BEGIN
    IF adding_percent < 0 OR monthly_income < 0 THEN
        RAISE negative_value;
    ELSIF adding_percent IS NULL OR monthly_income IS NULL THEN
        RAISE null_value;
    END IF;
    result_value := (1 + (1/100)*adding_percent)*12*monthly_income;
    RETURN  utl_lms.format_message('%d', TO_CHAR(result_value));
EXCEPTION
    WHEN negative_value THEN
        DBMS_OUTPUT.PUT_Line('Negative exception');
    WHEN null_value THEN
        DBMS_OUTPUT.PUT_LINE('Null exception');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Value exception');
END;
/


CREATE OR REPLACE PROCEDURE select_data IS
BEGIN
    FOR line IN (SELECT * FROM MyTable) LOOP
        DBMS_OUTPUT.PUT_LINE('id: ' || line.id || ', val: ' || line.val);
    END LOOP;
END;
/


-- task 2
DECLARE
    res VARCHAR2(255);
BEGIN
--    FOR i IN 1 .. 10 LOOP
--        INSERT INTO MyTable values (i, ROUND(DBMS_RANDOM.value(0,10000)));
--    END LOOP;
    
--    res := get_year_income(1000,1);
--    DBMS_OUTPUT.PUT_LINE('Year income result: ' || res);
    
--    DBMS_OUTPUT.PUT_LINE('Original data: ');
--    select_data();
    
    res := compare_even_odd_count();
    DBMS_OUTPUT.PUT_LINE('Result of comparing: ' || res);
    
--    res := get_insert_query('MyTable',11, 100);
--    DBMS_OUTPUT.PUT_LINE('Insert query:' || res);
--    
--    insert_data('MyTable',11, 11);
--    DBMS_OUTPUT.PUT_LINE('Data after insert: ');
--    select_data();
--    
--    update_data('MyTable', 1, 1500);
--    DBMS_OUTPUT.PUT_LINE('Data after update: ');
--    select_data();
--
--    delete_data('MyTable', 2);
--    DBMS_OUTPUT.PUT_LINE('Data after delete: ');
--    select_data();
--EXCEPTION
--    WHEN VALUE_ERROR THEN
--        DBMS_OUTPUT.PUT_LINE('Value exception');    
--    WHEN OTHERS THEN
--        DBMS_OUTPUT.PUT_LINE('Other exception');
END;
/

