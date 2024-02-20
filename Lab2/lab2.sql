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
AFTER DELETE ON groups
FOR EACH ROW
BEGIN
    DELETE FROM students WHERE students.group_id=:OLD.id;
END;
/


-- task 6
CREATE OR REPLACE TRIGGER update_c_val
AFTER INSERT OR UPDATE OR DELETE ON students
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
INSERT INTO students (id, name, group_id) VALUES (1, 'Andrei', 1);
INSERT INTO students (id, name, group_id) VALUES (2, 'Anton', 1);
INSERT INTO students (id, name, group_id) VALUES (3, 'Vadim', 1);



--DELETE FROM groups WHERE groups.id=1;
