/*
cdc demo
*/ 
use master 
go
DROP DATABASE DemoCDC

CREATE DATABASE DemoCDC;
GO

-- Prender el CDC
USE DemoCDC;
GO

EXEC sys.sp_cdc_enable_db;

-- Creamos una tabla de ejemplo
DROP TABLE IF EXISTS  dbo.Clientes

CREATE TABLE dbo.Clientes (
    Id INT IDENTITY PRIMARY KEY,
    Nombre NVARCHAR(100),
    Email NVARCHAR(100)
);

-- habilitamos el cdc sobre la tabla
EXEC sys.sp_cdc_enable_table
    @source_schema = 'dbo',
    @source_name = 'Clientes',
    @role_name = NULL,
    @supports_net_changes = 1;

-- mostramos lo generado por CDC

select * from [cdc].[dbo_Clientes_CT] 

-- cargamos damos

INSERT INTO dbo.Clientes (Nombre, Email)
VALUES ('Maxi Accotto', 'maxi@mail.com'),
       ('Ana Torres', 'ana@mail.com');

select * from [cdc].[dbo_Clientes_CT] 

-- Modificamos datos

UPDATE dbo.Clientes
SET Email = 'anatorres@mail.com'
WHERE Nombre = 'Ana Torres';

select * from [cdc].[dbo_Clientes_CT] 

-- borramos datos

DELETE FROM dbo.Clientes
WHERE Nombre = 'Ana Torres';

select * from [cdc].[dbo_Clientes_CT] ORDER BY 1

-- consultamos cambios

DECLARE @from_lsn binary(10), @to_lsn binary(10);
SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_Clientes');
SET @to_lsn = sys.fn_cdc_get_max_lsn();

SELECT *
FROM cdc.fn_cdc_get_all_changes_dbo_Clientes(@from_lsn, @to_lsn, 'all');

-----------------------------------------------------------------
-----                           DEMO ETL
-----------------------------------------------------------------

-- CREAR TABLA DESTINO

DROP TABLE IF EXISTS dbo.Clientes_STAGE

CREATE TABLE dbo.Clientes_STAGE (
    IdHistorico INT IDENTITY PRIMARY KEY,
    IdCliente INT,
    Nombre NVARCHAR(100),
    Email NVARCHAR(100),
    Operacion VARCHAR(50),
    FechaCambio DATETIME,
    LSN VARBINARY(10)
);

-- CREAR TABLA DE CONTROL

-- Tabla de control
DROP TABLE IF EXISTS  dbo.Control_ETL_LSN 

CREATE TABLE dbo.Control_ETL_LSN (
    CaptureInstance NVARCHAR(128) PRIMARY KEY, -- ej: dbo_Clientes
    UltimoLSN VARBINARY(10)
);

INSERT INTO dbo.Control_ETL_LSN (CaptureInstance, UltimoLSN)
VALUES 
    ('dbo_Clientes', sys.fn_cdc_get_min_lsn('dbo_Clientes'))
    
 

-- CARGAR

-- Usar en ETL
CREATE OR ALTER PROC DBO.USP_ETL_CLIENTES
AS
SET NOCOUNT ON
DECLARE @from_lsn binary(10) = (SELECT UltimoLSN FROM dbo.Control_ETL_LSN 
                                where CaptureInstance='dbo_Clientes' );

DECLARE @to_lsn binary(10) = sys.fn_cdc_get_max_lsn();

-- Cargar cambios en tabla destino
INSERT INTO dbo.Clientes_STAGE
(IdCliente, Nombre, Email, Operacion, FechaCambio, LSN)
SELECT 
    Id, Nombre, Email,
    CASE 
        WHEN __$operation = 1 THEN 'DELETE'
        WHEN __$operation = 2 THEN 'INSERT'
        WHEN __$operation = 3 THEN 'UPDATE_BEFORE'
        WHEN __$operation = 4 THEN 'UPDATE_AFTER'
    END,
    GETDATE(),
    __$start_lsn
FROM cdc.fn_cdc_get_all_changes_dbo_Clientes(@from_lsn, @to_lsn, 'all')
WHERE __$operation NOT IN (1,3) ;

UPDATE dbo.Control_ETL_LSN SET UltimoLSN = @to_lsn 
where CaptureInstance='dbo_Clientes' ;

GO

EXEC dbo.USP_ETL_CLIENTES 

SELECT * FROM dbo.Clientes_STAGE 

-- volvemos a correr el ETL

EXEC dbo.USP_ETL_CLIENTES 

SELECT * FROM dbo.Clientes_STAGE 

-- HACEMOS UN INSERT NUEVO

INSERT INTO dbo.Clientes (Nombre, Email)
VALUES ('Leo Accotto', 'Leo@mail.com')

-- corremos ETL

EXEC dbo.USP_ETL_CLIENTES 

SELECT * FROM dbo.Clientes_STAGE 

-- actualizamos 2 registros e insertamos uno nuevo
INSERT INTO dbo.Clientes (Nombre, Email)
VALUES ('Gaston Accotto', 'Gaston@mail.com')

UPDATE dbo.Clientes
SET Email = 'leonardo@mail.com'
WHERE Nombre = 'Leo Accotto';

-- corremos ETL

EXEC dbo.USP_ETL_CLIENTES 

SELECT * FROM dbo.Clientes_STAGE 
