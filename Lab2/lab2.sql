CREATE TABLE students (
    id NUMBER,
    name VARCHAR2(50),
    group_id NUMBER,

    CONSTRAINT students_pk PRIMARY KEY (id)
);

CREATE TABLE groups (
    id NUMBER,
    name VARCHAR2(50),
    c_val NUMBER,

    CONSTRAINT groups_pk PRIMARY KEY (id)
);

CREATE OR REPLACE TRIGGER check_student_id_unique
BEFORE INSERT OR UPDATE
    ON students
    FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT count(*) INTO v_count
    FROM students WHERE id = :NEW.id;

    IF (v_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Запись с таким ID уже существует!');
    end if;

end;

INSERT INTO students (id, name, group_id) VALUES (1, 'Lera', 1);
SELECT * FROM students;

