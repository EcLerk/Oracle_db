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