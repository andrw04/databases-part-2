DROP TABLE MyTable;

CREATE TABLE MyTable (
    id NUMBER PRIMARY KEY,
    val NUMBER NOT NULL
);

DECLARE
    res VARCHAR2(20);

    FUNCTION compare_even_odd_count RETURN VARCHAR IS
        even_count NUMBER := 0;
        odd_count NUMBER := 0;
        CURSOR cursor IS SELECT id, val FROM MyTable;
    BEGIN
        OPEN cursor;
        
        FOR line IN cursor LOOP
            IF MOD(line.val, 2) = 0 THEN
                even_count := even_count + 1;
            ELSE
                odd_count := odd_count + 1;
            END IF;
        END LOOP;
        
        CLOSE cursor;
        
        IF even_count = odd_count THEN
            RETURN 'EQUAL';
        ELSIF even_count > odd_count THEN
            RETURN 'TRUE';
        ELSE
            RETURN 'FALSE';
        END IF;
        
    END compare_even_odd_count;
    
    
    FUNCTION get_insert_query(table_name VARCHAR2, val NUMBER) RETURN VARCHAR2 IS
    BEGIN
        RETURN utl_lms.format_message('INSERT INTO %s VALUES (%d);', table_name, val);
    END;
    
    PROCEDURE insert_data(table_name VARCHAR, val NUMBER) IS
    BEGIN
        EXECUTE IMMEDIATE get_insert_query(table_name, val);
    END;
    
    PROCEDURE update_data(table_name VARCHAR2, id NUMBER, val NUMBER) IS
    BEGIN
        EXECUTE IMMEDIATE utl_lms.format_message('UPDATE %s SET val=%d WHERE id=%d;', table_name, val, id);
    END;
    
    PROCEDURE delete_data(table_name VARCHAR2, id NUMBER) IS
    BEGIN
        EXECUTE IMMEDIATE utl_lms.format_message('DELETE FROM %s WHERE id=%d;', table_name, id);
    END;

BEGIN
    FOR i IN 1 .. 10000 LOOP
        INSERT INTO MyTable values (i, ROUND(DBMS_RANDOM.value(0,10000)));
    END LOOP;
    
    res := compare_even_odd_count();
END;


      
