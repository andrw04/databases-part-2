SET SERVEROUTPUT ON;

--DROP TABLE students;
--DROP TABLE groups;

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
CREATE OR REPLACE TRIGGER check_student_id
BEFORE UPDATE OR INSERT ON students
FOR EACH ROW
DECLARE
    students_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO students_count FROM students WHERE students.id=:NEW.id;
    
    IF students_count != 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'This id is already exits.');
    END IF;
END;
/

INSERT INTO students (id, name, group_id) VALUES (1, 'Andrei', 4);