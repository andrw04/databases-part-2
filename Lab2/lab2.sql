SET SERVEROUTPUT ON;

DROP TABLE students;
DROP TABLE groups;


-- task 1
CREATE TABLE students (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    group_id NUMBER
);


CREATE TABLE groups (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    c_val NUMBER DEFAULT 0
);

-- task 2
DROP SEQUENCE students_sequence;
DROP SEQUENCE groups_sequence;


CREATE SEQUENCE students_sequence
START WITH 1
INCREMENT BY 1;


CREATE SEQUENCE groups_sequence
START WITH 1
INCREMENT BY 1;


DROP TRIGGER update_c_val;

CREATE OR REPLACE TRIGGER check_student_id
BEFORE UPDATE OR INSERT ON students
FOR EACH ROW
DECLARE
    students_count NUMBER;
    existing_id EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO students_count FROM students WHERE students.id=:NEW.id;
    
    IF students_count != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Students ID: ' || :NEW.id || ' is already exists.');
        RAISE existing_id;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER check_group_name
BEFORE INSERT ON groups
FOR EACH ROW
DECLARE
    groups_count NUMBER;
    exists_name EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO groups_count FROM groups WHERE name = :NEW.name;
    
    IF groups_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Group name: ' || :NEW.name || ' already exists.');
        RAISE exists_name;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER check_group_id
BEFORE INSERT ON groups
FOR EACH ROW
DECLARE
    groups_count NUMBER;
    existing_id EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO groups_count FROM groups WHERE groups.id=:NEW.id;
    
    IF groups_count != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Group ID: ' || :NEW.id || ' is already exits');
        RAISE existing_id;
    END IF;
END;
/


CREATE OR REPLACE TRIGGER increment_students_id
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    SELECT students_sequence.NEXTVAL INTO :NEW.id FROM dual;
END;
/


CREATE OR REPLACE TRIGGER increment_groups_id
BEFORE INSERT ON groups
FOR EACH ROW
BEGIN
    SELECT groups_sequence.NEXTVAL INTO :NEW.id FROM dual;
END;
/


-- task 3
CREATE OR REPLACE TRIGGER students_cascade_delete
BEFORE DELETE ON groups
FOR EACH ROW
BEGIN
    DELETE FROM students WHERE students.group_id=:OLD.id;
END;
/


-- task 4
DROP TABLE students_logs;

CREATE TABLE students_logs (
    id NUMBER PRIMARY KEY,
    operation VARCHAR(20) NOT NULL,
    timestamp_written TIMESTAMP NOT NULL,
    student_id NUMBER,
    student_name VARCHAR2(100) NOT NULL,
    student_group_id NUMBER
);

CREATE OR REPLACE TRIGGER log_students
AFTER UPDATE OR INSERT OR DELETE ON students
FOR EACH ROW
DECLARE
    number_of_records NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM students_logs' INTO number_of_records;
    IF INSERTING THEN
        INSERT INTO students_logs VALUES (number_of_records + 1, 'INSERT', CURRENT_TIMESTAMP, :NEW.id, :NEW.name, :NEW.group_id);
    END IF;
    IF UPDATING THEN
        INSERT INTO students_logs VALUES (number_of_records + 1, 'UPDATE', CURRENT_TIMESTAMP, :NEW.id, :NEW.name, :NEW.group_id);
    END IF;
    IF DELETING THEN
        INSERT INTO students_logs VALUES (number_of_records + 1, 'DELETE', CURRENT_TIMESTAMP, :OLD.id, :OLD.name, :old.group_id);
    END IF;
END;
/


-- task 5
CREATE OR REPLACE PROCEDURE roll_back (rollback_time TIMESTAMP)
AS
BEGIN
    DELETE FROM students;
                        
    FOR log_record IN (SELECT * FROM students_logs) LOOP
        IF log_record.timestamp_written <= rollback_time THEN
            IF log_record.operation = 'INSERT' THEN
                INSERT INTO students (id, name, group_id) VALUES (log_record.student_id, log_record.student_name, log_record.student_group_id);
            END IF;
            If log_record.operation = 'UPDATE' THEN
                UPDATE students SET name = log_record.student_name, group_id = log_record.student_group_id WHERE id=log_record.student_id;
            END IF;
            IF log_record.operation = 'DELETE' THEN
                DELETE FROM students WHERE id = log_record.student_id;
            END IF;
        END IF;
    END LOOP;
END;
/


DROP TRIGGER check_student_id;
DROP TRIGGER check_group_name;
DROP TRIGGER check_group_id;
DROP TRIGGER check_group_id;
DROP TRIGGER increment_students_id;
DROP TRIGGER increment_groups_id;
DROP TRIGGER students_cascade_delete;
DROP TRIGGER log_students;

-- task 6
CREATE OR REPLACE TRIGGER update_c_val
AFTER INSERT OR DELETE OR UPDATE ON students
FOR EACH ROW
DECLARE
    students_in_group NUMBER;
BEGIN
    IF INSERTING THEN
        UPDATE groups
        SET c_val = c_val + 1
        WHERE id = :NEW.group_id;
    ELSIF DELETING THEN
        UPDATE groups
        SET c_val = c_val - 1
        WHERE id = :OLD.group_id;
    ELSIF UPDATING THEN
        UPDATE groups
        SET c_val = c_val - 1
        WHERE id = :OLD.group_id;
        
        UPDATE groups
        SET c_val = c_val + 1
        WHERE id = :NEW.group_id;
    END IF;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('The group was deleted');
END;
/


INSERT INTO groups (id, name, c_val) VALUES (1, '153504', 0);
INSERT INTO groups (id, name, c_val) VALUES (2, '153504', 0);
INSERT INTO students (id, name, group_id) VALUES (10, 'Andrei', 1);
INSERT INTO students (id, name, group_id) VALUES (11, 'Anton', 1);
INSERT INTO students (id, name, group_id) VALUES (12, 'Kirill', 1);

SELECT * FROM students;
SELECT * FROM groups;
    
SELECT * FROM students_logs;

DELETE FROM groups WHERE groups.id=1;
call roll_back(TO_TIMESTAMP('02.03.24 11:38:45'));
