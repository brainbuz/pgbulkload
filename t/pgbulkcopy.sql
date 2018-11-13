-- Database: pgbulkcopy

-- DROP DATABASE pgbulkcopy;

CREATE DATABASE pgbulkcopy
    WITH 
    OWNER = brainbuz
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE pgbulkcopy
    IS 'Testing DataBase for PgBulkCopy.';
	
-- Table: public.load1

-- DROP TABLE public.load1;

CREATE TABLE public.load1
(
    string character varying COLLATE pg_catalog."default",
    adate date,
    atimestamp timestamp without time zone,
    aninteger integer
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
