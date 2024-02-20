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


CREATE OR REPLACE TRIGGER check_group_id
BEFORE UPDATE OR INSERT ON groups
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


CREATE OR REPLACE TRIGGER check_group_name
BEFORE INSERT OR UPDATE ON groups
FOR EACH ROW
DECLARE
    groups_count NUMBER;
    exists_name EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO groups_count FROM groups WHERE groups.name=:NEW.name;
    IF groups_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Group name: ' || :NEW.name || ' already exists.');
        RAISE exists_name;
    END IF;
END;
/


