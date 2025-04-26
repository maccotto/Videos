--- datetime vs time vs date

USE tempdb 
GO

declare @fechayhora datetime = getdate()
declare @fecha date = getdate()
declare @hora time = getdate()
declare @fechautc datetimeoffset = getdate()


select DATALENGTH(@fechayhora) as [DatetimeBytes],
       DATALENGTH(@fecha) as [dateBytes],
	   DATALENGTH(@hora) as [timeBytes],
	   DATALENGTH(@fechautc) as [datetimeutcBytes]
	   


select @fechayhora as fechayhora,
       @fecha as fecha,
	   @hora as hora,
	   @fechautc as Dateutc

DROP TABLE IF EXISTS dbo.FECHAS1 

CREATE TABLE dbo.fechas1 (id int identity primary key,
                          mes char(10),
                          f_datetime datetime,
                          f_date date,
						  f_time time,
						  f_datetimeutc datetimeoffset)
go

WITH RandomDates AS (
    SELECT TOP (1000000)
        -- Generar una fecha datetime aleatoria entre enero de 2022 y agosto de 2024
        DATEADD(SECOND, 
                ABS(CHECKSUM(NEWID()) % 63072000), -- Genera segundos aleatorios entre 0 y 2 años (2 * 365 * 24 * 60 * 60 = 63072000)
                '2022-01-01 00:00:00') AS f_datetime,
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
    FROM sys.all_columns a
    CROSS JOIN sys.all_columns b
)
INSERT INTO dbo.fechas1 (f_datetime, f_date, f_time, f_datetimeutc,mes)
SELECT 
    f_datetime, 
    CAST(f_datetime AS date) AS f_date,             -- Extrae la parte de la fecha
    CAST(f_datetime AS time) AS f_time,             -- Extrae la parte de la hora
    SWITCHOFFSET(CAST(f_datetime AS datetimeoffset), DATENAME(TzOffset, SYSDATETIMEOFFSET())) AS f_datetimeutc -- Convierte a UTC
    ,DATENAME(month,f_datetime) 
FROM RandomDates;



select top (50) * from dbo.fechas1


drop index if exists ix1 on dbo.fechas1
drop index if exists ix2 on dbo.fechas1
drop index if exists ix4 on dbo.fechas1


create index ix1 on dbo.fechas1(f_datetime) include (mes)
create index ix2 on dbo.fechas1(f_date) include (mes)
create index ix4 on dbo.fechas1(f_datetimeutc) include(mes)


select  id,mes
from dbo.fechas1 
where  f_date >= '20220101'
and f_date < ='20220301'

select  id,mes
from dbo.fechas1 
where  f_datetime >= '20220101'
and f_datetime < ='20220301'


select  id,mes from dbo.fechas1 
where  f_datetimeutc >= '20220101'
and f_datetimeutc < ='20220301'


---- pruebas funcionales

select  id,mes,f_datetime  from dbo.fechas1 
where  f_datetime >= '20220101'
and f_datetime < '20220102'
-- no ves datos
select  id,mes,f_datetime  from dbo.fechas1 
where  f_datetime = '20220101'


select  id,mes,f_date  from dbo.fechas1 
where  f_date = '20220101'

