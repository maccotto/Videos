/*
Demo Rowversion SQL
*/

use tempdb 
go

--Demo 1: introduccion a rowversion
drop table if exists clientes

CREATE TABLE Clientes (
    Id INT PRIMARY KEY IDENTITY,
    Nombre NVARCHAR(100),
    Email NVARCHAR(100),
    [Version] ROWVERSION
);

INSERT INTO Clientes (Nombre, Email) 
VALUES ('Maxi', 'maxiaccotto@example.com');

INSERT INTO Clientes (Nombre, Email) 
VALUES ('Ana', 'ana@example.com');

SELECT Id, Nombre, Email, Version FROM Clientes;

-- Demo 2: Actualizar datos
select version as version_orig from Clientes where Nombre ='Maxi'

UPDATE Clientes SET Email = 'maxi@example.com.ar' 
WHERE Nombre = 'Maxi';

select version as version_nueva from Clientes where Nombre ='Maxi'

SELECT Id, Nombre, Email, Version FROM Clientes;

-- Demo 3: Obtener filas modificadas desde una versión anterior
DECLARE @ultimaVersionAnterior VARBINARY(8) = 0x00000000000101D2; 

SELECT *
FROM Clientes
WHERE Version > @ultimaVersionAnterior;

/*
 Demo 4: Control de concurrencia optimista

 Leer una fila y guardar su rowversion para controlar 
 cambios antes de actualizar 
*/

-- Supón que una aplicación leyó este dato
SELECT Id, Nombre, Email, Version
INTO #CacheTemporal
FROM Clientes
WHERE Id = 1;

-- Luego alguien más actualiza el registro
UPDATE Clientes SET Email = 'nuevo@mail.com' WHERE Id = 1;

-- Ahora simulamos un intento de actualización usando la versión cacheada
UPDATE Clientes
SET Nombre = 'Juan Carlos'
WHERE Id = 1
AND Version = (SELECT Version FROM #CacheTemporal);

-- Verificamos si se logró la actualización
IF @@ROWCOUNT = 0
    PRINT 'La fila fue modificada por otro proceso. Abortando actualización.';
ELSE
    PRINT 'Actualización exitosa.';
