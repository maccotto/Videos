--- Demos: Encriptando datos en MSSQL


USE AdventureWorks2019 
GO
----------------------------------------------------------------
--Using a Function to Encrypt By Passphrase
-----------------------------------------------------------------



CREATE TABLE #SecretInfo
(Secret1 varbinary(8000) NOT NULL,
 Secret2 varchar(8000) null,
 Secret3_int varbinary(8000) null)
 
GO

-- USAMOS LA FUNCION EncryptByPassPhrase PARA INSERTAR VALORES CIFRADOS

INSERT #SecretInfo
(Secret1,Secret2,Secret3_int)
SELECT 
EncryptByPassPhrase(
'Clave',
'Varbinary'),
EncryptByPassPhrase(
'Clave',
'Varchar'),
EncryptByPassPhrase(
'Clave','100')
 

-- HACEMOS UN SELECT COMUN Y VEMOS QUE EL VALOR QUEDO CIFRADO

SELECT *
FROM #SecretInfo

-- HACEMOS UN SELECT USANDO DecryptByPassPhrase PARA MOSTRAR LA INFORMACION DESCIFRADA

SELECT CAST(DecryptByPassPhrase(
'Clave',Secret1) as varchar(50)) as secret1,
CAST(DecryptByPassPhrase(
'Clave',
Secret2) as varchar(50)) as secret2,
cast(cast(DecryptByPassPhrase('Clave',Secret3_int) as varchar(50)) as int)  
as secret3
from #SecretInfo 


drop table #SecretInfo


-------------------------------------------------------------------------------------
-------------------------------  CERTIFICADOS ---------------------------------------
-------------------------------------------------------------------------------------
--Creating a Database Certificate


CREATE CERTIFICATE cert_triggerdb
ENCRYPTION BY PASSWORD = 'AA5FA6AC'
WITH SUBJECT = 'Certificado Triggerdb ',
START_DATE = '7/15/2005', EXPIRY_DATE = '10/15/2026'

--Viewing Certificates in the Database

SELECT name, pvt_key_encryption_type_desc, issuer_name
FROM sys.certificates

--Backing Up and Restoring a Certificate

BACKUP CERTIFICATE cert_triggerdb
TO FILE = 'c:\temp\cert_triggerdb.BAK'
WITH PRIVATE KEY ( FILE = 'c:\temp\certTriggerdbPK.BAK' ,
ENCRYPTION BY PASSWORD = '3439F6A',
DECRYPTION BY PASSWORD = 'AA5FA6AC' )


--Managing a Certificate’s Private Key

drop table IF EXISTS #PasswordHint

CREATE TABLE #PasswordHint
(CustomerID int NOT NULL PRIMARY KEY,
 Username varchar(300) NOT NULL,
 userPassword   varbinary(1000) NOT NULL)
GO

--Using Certificate Encryption and Decryption

INSERT #PasswordHint
(CustomerID, Username, userPassword)
VALUES
(1, 'Triggerdb',
EncryptByCert(Cert_ID('cert_triggerdb'), 'Clave1'))

Select * from #PasswordHint

SELECT CAST(userPassword as varchar(200)) Password
FROM #PasswordHint
WHERE CustomerID = 1

SELECT CAST(DecryptByCert(Cert_ID('cert_triggerdb'),
userpassword, N'AA5FA6AC') 
as varchar(200)) Password
FROM #PasswordHint
WHERE CustomerID = 1

-- BORRAMOS CERTIFICADO

DROP CERTIFICATE cert_triggerdb
GO

-- CREAMOS CERTIFICADO POR MEDIO DE BACKUP

CREATE CERTIFICATE cert_triggerdb
FROM FILE = 'c:\temp\cert_triggerdb.BAK'
WITH PRIVATE KEY (FILE = 'c:\temp\certtriggerdbPK.BAK',
DECRYPTION BY PASSWORD = '3439F6A',
ENCRYPTION BY PASSWORD = 'AA5FA6AC')
GO


Select * from #PasswordHint

SELECT CAST(DecryptByCert(Cert_ID('cert_triggerdb'),
userpassword, N'AA5FA6AC') 
as varchar(200)) Password
FROM #PasswordHint
WHERE CustomerID = 1

DROP CERTIFICATE cert_triggerdb
GO


----------------------------------------------------------------------------------------
------------------------------- CLAVES ASIMETRICAS -------------------------------------
----------------------------------------------------------------------------------------

--Creating an Asymmetric Key
DROP ASYMMETRIC KEY asy_TRIGGERDB

CREATE ASYMMETRIC KEY asy_TRIGGERDB
WITH ALGORITHM = RSA_2048
ENCRYPTION BY PASSWORD = 'EEB0B4DD'

--Viewing Asymmetric Keys in the Current Database

SELECT name, algorithm_desc, pvt_key_encryption_type_desc
FROM sys.asymmetric_keys

--Encrypting and Decrypting Data using an Asymmetric Key

drop table IF EXISTS #PasswordHint

CREATE TABLE #PasswordHint
(CustomerID int NOT NULL PRIMARY KEY,
 Username varchar(300) NOT NULL,
 userPassword   varbinary(1000) NOT NULL)
GO

INSERT #PasswordHint
(CustomerID, Username, userPassword)
VALUES
(1, 'Triggerdb',
 EncryptByAsymKey(AsymKey_ID('asy_TRIGGERDB'),
'Clave del usuario'))

SELECT * FROM #PasswordHint

-- 

SELECT CAST(DecryptByAsymKey
( AsymKey_ID('asy_triggerdb'),

userPassword,
N'EEB0B4DD') as varchar(100)) BankRoutingNBR
FROM #PasswordHint


----------------------------------
------------ azure database
-----------------------------------

----------------------------------------------------------------
--Using a Function to Encrypt By Passphrase
-----------------------------------------------------------------

use adventureworks


CREATE TABLE #SecretInfo
(Secret1 varbinary(8000) NOT NULL,
 Secret2 varchar(8000) null,
 Secret3_int varbinary(8000) null)
 
GO

-- USAMOS LA FUNCION EncryptByPassPhrase PARA INSERTAR VALORES CIFRADOS

INSERT #SecretInfo
(Secret1,Secret2,Secret3_int)
SELECT 
EncryptByPassPhrase(
'Clave',
'Varbinary'),
EncryptByPassPhrase(
'Clave',
'Varchar'),
EncryptByPassPhrase(
'Clave','100')
 

-- HACEMOS UN SELECT COMUN Y VEMOS QUE EL VALOR QUEDO CIFRADO

SELECT *
FROM #SecretInfo

-- HACEMOS UN SELECT USANDO DecryptByPassPhrase PARA MOSTRAR LA INFORMACION DESCIFRADA

SELECT CAST(DecryptByPassPhrase(
'Clave',Secret1) as varchar(50)) as secret1,
CAST(DecryptByPassPhrase(
'Clave',
Secret2) as varchar(50)) as secret2,
cast(cast(DecryptByPassPhrase('Clave',Secret3_int) as varchar(50)) as int)  
as secret3
from #SecretInfo 


drop table #SecretInfo

---------------------------
--- certificados
----------------------------

--Creating a Database Certificate


CREATE CERTIFICATE cert_triggerdb
ENCRYPTION BY PASSWORD = 'Passw0rdAA5FA6AC'
WITH SUBJECT = 'Certificado Triggerdb ',
START_DATE = '7/15/2005', EXPIRY_DATE = '10/15/2026'

--Viewing Certificates in the Database

SELECT name, pvt_key_encryption_type_desc, issuer_name
FROM sys.certificates

drop table IF EXISTS #PasswordHint

CREATE TABLE #PasswordHint
(CustomerID int NOT NULL PRIMARY KEY,
 Username varchar(300) NOT NULL,
 userPassword   varbinary(1000) NOT NULL)
GO

--Using Certificate Encryption and Decryption

INSERT #PasswordHint
(CustomerID, Username, userPassword)
VALUES
(1, 'Triggerdb',
EncryptByCert(Cert_ID('cert_triggerdb'), 'Clave1'))

Select * from #PasswordHint

SELECT CAST(userPassword as varchar(200)) Password
FROM #PasswordHint
WHERE CustomerID = 1

SELECT CAST(DecryptByCert(Cert_ID('cert_triggerdb'),
userpassword, N'Passw0rdAA5FA6AC') 
as varchar(200)) Password
FROM #PasswordHint
WHERE CustomerID = 1

-- BORRAMOS CERTIFICADO

DROP CERTIFICATE cert_triggerdb
GO
