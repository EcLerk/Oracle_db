--Task1 (Tables creating)
CREATE TABLE students (
    id NUMBER,
    name VARCHAR2(50),
    group_id NUMBER,

    FOREIGN KEY (group_id) REFERENCES GROUPS(ID),
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

--Unique group name
CREATE OR REPLACE TRIGGER check_group_name_unique
    BEFORE INSERT OR UPDATE
    ON groups
    FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM groups
        WHERE groups.name = :NEW.name;

    IF (v_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Ошибка: группа с таким названием уже сущетвует!');
    end if;
end;

INSERT INTO groups (name, c_val) VALUES ('gRUPPA', 20);


--Task 3 (cascade deletion)
CREATE OR REPLACE TRIGGER cascade_deletion
    AFTER DELETE ON GROUPS
    FOR EACH ROW
BEGIN
    DELETE FROM STUDENTS
        WHERE STUDENTS.GROUP_ID = :OLD.ID;
end;


INSERT INTO GROUPS (NAME, C_VAL) VALUES('group_check_cascade', 35);
SELECT * FROM GROUPS;
INSERT INTO STUDENTS (NAME, GROUP_ID) VALUES('st_check_cascade', (select id from groups where name = 'group_check_cascade'));
SELECT * FROM STUDENTS;
DELETE FROM GROUPS WHERE Name = 'group_check_cascade';

SELECT * FROM GROUPS;
SELECT * FROM STUDENTS;

--Task 4
CREATE TABLE LOG_STUDENTS
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ACTION VARCHAR(6),
  DATETIME TIMESTAMP,
  STUDENT_ID NUMBER,
  NAME VARCHAR2(20),
  GROUP_ID NUMBER
);

CREATE OR REPLACE TRIGGER LOG_STUDENTS_ACTIONS
    AFTER INSERT OR UPDATE OR DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO LOG_STUDENTS (ACTION, DATETIME, STUDENT_ID, NAME, GROUP_ID)
        VALUES ('INSERT', SYSTIMESTAMP, :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
    end if;
    IF UPDATING THEN
        INSERT INTO LOG_STUDENTS (ACTION, DATETIME, STUDENT_ID, NAME, GROUP_ID)
        VALUES ('UPDATE', SYSTIMESTAMP, :OLD.ID, :OLD.NAME, :OLD.GROUP_ID);
    end if;
    IF DELETING THEN
        INSERT INTO LOG_STUDENTS (ACTION, DATETIME, STUDENT_ID, NAME, GROUP_ID)
        VALUES ('DELETE', SYSTIMESTAMP, :OLD.ID, :OLD.NAME, :OLD.GROUP_ID);
    end if;
end;

INSERT INTO  STUDENTS (NAME, GROUP_ID) VALUES ('Kate', 1);
INSERT INTO  STUDENTS (NAME, GROUP_ID) VALUES ('Dima', 2);
SELECT * FROM LOG_STUDENTS;


--task5
CREATE OR REPLACE PROCEDURE restore_students_data (restore_date TIMESTAMP, time_offset INTERVAL DAY TO SECOND)
AS
BEGIN
    DELETE FROM STUDENTS;

    FOR student IN (SELECT STUDENT_ID, NAME, GROUP_ID
        FROM (
            SELECT STUDENT_ID, NAME, GROUP_ID,
                ROW_NUMBER() OVER (PARTITION BY STUDENT_ID ORDER BY DATETIME DESC) AS row_number
            FROM LOG_STUDENTS
            WHERE DATETIME <= restore_date + time_offset
        )
        WHERE row_number = 1)
    LOOP
            INSERT INTO STUDENTS (ID, NAME, GROUP_ID) VALUES
            (student.STUDENT_ID, student.NAME, student.GROUP_ID);
    END LOOP;
    COMMIT;
END;

--task6
CREATE OR REPLACE TRIGGER update_group_count
AFTER INSERT OR UPDATE OR DELETE ON STUDENTS
FOR EACH ROW
BEGIN

        FOR group_ IN (SELECT GROUP_ID, COUNT(*) AS student_count FROM STUDENTS GROUP BY GROUP_ID)
        LOOP
            UPDATE GROUPS
            SET C_VAL = group_.student_count
            WHERE ID = group_.GROUP_ID;
        END LOOP;

END;


CREATE OR REPLACE TRIGGER update_group_count
AFTER INSERT OR UPDATE OR DELETE ON STUDENTS
FOR EACH ROW
BEGIN
    -- Проверяем, было ли изменение в колонке GROUP_ID
    IF INSERTING OR UPDATING('GROUP_ID') OR DELETING THEN
        UPDATE GROUPS
        SET C_VAL = (SELECT COUNT(*) FROM STUDENTS WHERE GROUP_ID = :NEW.GROUP_ID)
        WHERE ID = :NEW.GROUP_ID;
    END IF;
END;