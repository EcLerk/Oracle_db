CREATE USER C##dev_schema IDENTIFIED BY dev;
CREATE USER C##prod_schema IDENTIFIED BY prod;

grant connect to C##DEV_SCHEMA;
grant all privileges to C##DEV_SCHEMA;

grant connect to C##PROD_SCHEMA;
grant all privileges to C##PROD_SCHEMA;