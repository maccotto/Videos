use tempdb 
go

drop table if exists test_table

CREATE TABLE test_table (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    C1 VARCHAR(1),
    C2 VARCHAR(1),
    C3 VARCHAR(1),
    C4 VARCHAR(1),
    C5 VARCHAR(1),
    C6 VARCHAR(1),
    C7 VARCHAR(1),
    C8 VARCHAR(1),
    C9 VARCHAR(1),
    C10 VARCHAR(1),
    created_at DATETIME
);

INSERT INTO test_table (C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, created_at)
SELECT top 5000000
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 'a' WHEN RAND(CHECKSUM(NEWID())) < 0.30 THEN 'b' ELSE 'c' END,
    GETDATE()
FROM
  master.sys.columns c1
  cross join master.sys.columns  c2 
  cross join master.sys.columns  c3

---- indices
update top(100) test_table
set c1='z',c2='x',c3='y'

sp_helpindex 'test_table'
-- crear indices

create index ix1 on  test_table(c1)

create index ix2 on  test_table(c1,c2)

create index ix3 on  test_table(c1,c2,c3)


--- CONSULTAS
SP_SPACEUSED 'test_table' -- 269224 105328 


select c1,created_at from  test_table 
where c1='z'

select c1,created_at from  test_table 
where c2='z'


select c1,created_at from  test_table 
where c1='z'
and c2='z'

select c1,created_at from  test_table 
where c1='z'
and c2='z'
and c3='z'

ALTER INDEX ix1 on  test_table DISABLE

ALTER INDEX ix2 on  test_table DISABLE


---- MELLIZOS CON INCLUDE

create index ix4 on  test_table(c3)
INCLUDE (created_at)

create index ix5 on  test_table(c3,c5)
INCLUDE (created_at,C4)

ALTER INDEX ix4 on  test_table DISABLE


select c1,created_at from  test_table 
where c1='z'

SELECT created_at FROM  test_table WHERE C3='B'
SELECT created_at,C4 FROM  test_table WHERE C3='B'