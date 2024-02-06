DROP TABLE MyTable;

CREATE TABLE MyTable (
    id NUMBER PRIMARY KEY,
    val NUMBER NOT NULL
);

DECLARE
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

BEGIN

    FOR i IN 1 .. 10 LOOP
        INSERT INTO MyTable values (i, ROUND(DBMS_RANDOM.value(0,10000)));
    END LOOP;

END;


      
