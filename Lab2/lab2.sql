--Task1 (Tables creating)
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

--Task2 (Unique triggers)
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

CREATE OR REPLACE TRIGGER check_group_id_unique
BEFORE INSERT OR UPDATE
    ON groups
    FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT count(*) INTO v_count
    FROM groups WHERE id = :NEW.id;

    IF (v_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ошибка в таблице groups: запись с таким ID уже существует!');
    end if;

end;

INSERT INTO groups (id, name, c_val) VALUES (1, 'gRUPPA', 20);
SELECT * FROM groups;

--autoincrements
CREATE OR REPLACE TRIGGER students_id_autoincrement
BEFORE INSERT
    ON students
    FOR EACH ROW
BEGIN
    SELECT COALESCE(MAX(ID), 0) + 1
        INTO :NEW.ID
        FROM students;

end;

INSERT INTO students (name, group_id) VALUES ('Sasha', 1);
SELECT * FROM students;

CREATE OR REPLACE TRIGGER groups_id_autoincrement
BEFORE INSERT
    ON groups
    FOR EACH ROW
BEGIN
    SELECT COALESCE(MAX(ID), 0) + 1
        INTO :NEW.ID
        FROM groups;

end;

INSERT INTO groups (name, c_val) VALUES ('gRUPPA2', 10);
SELECT * FROM groups;