use AdventureWorks2022
go

-- CREAMOS UNA TABLA PARA NUESTRAS PRUEBAS

DROP TABLE IF EXISTS DBO.clientes
DROP TABLE IF EXISTS DBO.clientes_DESTINO

create table dbo.clientes (id int identity primary key,
                           nombre varchar(255),
						   apellido varchar(255),
						   estado_civil varchar(50)
						   )
go

create table dbo.clientes_destino (id int identity primary key,
                           nombre varchar(255),
						   apellido varchar(255),
						   estado_civil varchar(50)
						   )
go

-- insertamos algunos registros

insert into dbo.clientes (nombre,apellido,estado_civil)
values ('Maxi','Accotto','Casado'),
       ('Gaston','Lopez','Soltero'),
	   ('Rocio','Perotti','Soltera')

-- agregamos columna row_version
ALTER TABLE DBO.CLIENTES ADD VERSION_REGISTRO ROWVERSION

-- LE CREAMOS UN INDICE :-)
CREATE INDEX IX1_CLIENTES ON DBO.CLIENTES(VERSION_REGISTRO)

SELECT * FROM DBO.clientes 

-- CREAMOS UNA TABLA PARA SINCRONIZAR
DROP TABLE IF EXISTS DBO.SINCRONIZAR_DATA
CREATE TABLE DBO.SINCRONIZAR_DATA
(ID INT IDENTITY PRIMARY KEY,
 NOMBRE_TABLA VARCHAR(255),
 ULTIMO_SYNC VARBINARY NULL
 )

INSERT INTO DBO.SINCRONIZAR_DATA (NOMBRE_TABLA,ULTIMO_SYNC)
VALUES ('Clientes',null)

DECLARE @ULTIMO_VERSION_REGISTRO VARBINARY
SELECT  @ULTIMO_VERSION_REGISTRO = ULTIMO_SYNC from DBO.SINCRONIZAR_DATA
WHERE NOMBRE_TABLA = 'Clientes'

declare  @MyTableVar as table (ultimo_rowversion varbinary)

BEGIN TRAN
	INSERT INTO DBO.clientes_destino (NOMBRE,APELLIDO,estado_civil) 
	OUTPUT INSERTED.VERSION_REGISTRO
        INTO @MyTableVar
	SELECT NOMBRE,APELLIDO,estado_civil  
	FROM DBO.clientes 
	WHERE VERSION_REGISTRO > 
		  isnull(@ULTIMO_VERSION_REGISTRO,VERSION_REGISTRO)
   
   -- ACTUALIZAMOS LA TABLA DE SINC
   DECLARE @ULTIMO_SYNC VARBINARY
   SELECT @ULTIMO_SYNC = MAX(ultimo_rowversion) FROM @MyTableVar
   
   UPDATE  DBO.SINCRONIZAR_DATA
   SET ULTIMO_SYNC = @ULTIMO_SYNC
   WHERE NOMBRE_TABLA = 'Clientes'

   COMMIT TRAN
GO