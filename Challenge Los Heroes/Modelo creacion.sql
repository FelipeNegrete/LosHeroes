USE [DB_lh_fnegrete]
GO

/****** Object:  StoredProcedure [dbo].[CREACION_MODELO]    Script Date: 16-10-2023 10:25:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Autor:		Felipe Negrete
-- Fecha de creacion: 14-10-2023,
-- Descripcion:	Desarrollo challenge Analista de base de datos
-- =============================================

CREATE PROCEDURE [dbo].[CREACION_MODELO]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

-- Tabla Persona
CREATE TABLE FN_Persona (
    ID INT PRIMARY KEY,
    Nombre VARCHAR(255),
    Apellido VARCHAR(255),
    NivelIngresos DECIMAL(10, 2),
    NivelEndeudamiento DECIMAL(10, 2)
);

-- Tabla Domicilio
CREATE TABLE FN_Domicilio (
    ID INT PRIMARY KEY,
    Tipo VARCHAR(50),
    Direccion VARCHAR(255),
    PersonaID INT,
    FOREIGN KEY (PersonaID) REFERENCES FN_Persona(ID)
);

-- Tabla Telefono
CREATE TABLE FN_Telefono (
    ID INT PRIMARY KEY,
    PersonaID INT,
    Numero VARCHAR(20),
    Tipo VARCHAR(50),
    FOREIGN KEY (PersonaID) REFERENCES FN_Persona(ID)
);

-- Tabla Correo
CREATE TABLE FN_Correo (
    ID INT PRIMARY KEY,
    PersonaID INT,
    DireccionCorreo VARCHAR(100),
    FOREIGN KEY (PersonaID) REFERENCES FN_Persona(ID)
);

-- Tabla TipoCredito
CREATE TABLE FN_TipoCredito (
    ID INT PRIMARY KEY,
    NombreTipo VARCHAR(100),
    Descripcion VARCHAR(255)
);

-- Tabla Sucursal
CREATE TABLE FN_Sucursal (
    ID INT PRIMARY KEY,
    NombreSucursal VARCHAR(255),
    Ubicacion VARCHAR(255)
);

-- Tabla Promotor
CREATE TABLE FN_Promotor (
    ID INT PRIMARY KEY,
    Nombre VARCHAR(255),
    Apellido VARCHAR(255),
    SucursalID INT,
    Comision DECIMAL(5, 2),
    FOREIGN KEY (SucursalID) REFERENCES FN_Sucursal(ID)
);

-- Tabla Credito
CREATE TABLE FN_Credito (
    ID INT PRIMARY KEY,
    TipoCreditoID INT,
    PersonaID INT,
    Monto DECIMAL(10, 2),
    FechaSolicitud DATE,
    Estado VARCHAR(50),
    PromotorID INT,
    SucursalID INT,
    FOREIGN KEY (TipoCreditoID) REFERENCES FN_TipoCredito(ID),
    FOREIGN KEY (PersonaID) REFERENCES FN_Persona(ID),
    FOREIGN KEY (PromotorID) REFERENCES FN_Promotor(ID),
    FOREIGN KEY (SucursalID) REFERENCES FN_Sucursal(ID)
);

-- Tabla DocumentosAdjuntos (para documentos adjuntos a las solicitudes de crédito en línea)
CREATE TABLE FN_DocumentosAdjuntos (
    ID INT PRIMARY KEY,
    CreditoID INT,
    NombreDocumento VARCHAR(255),
    RutaDocumento VARCHAR(255),
    FechaAdjunto DATETIME,
    FOREIGN KEY (CreditoID) REFERENCES FN_Credito(ID)
);
-- Tabla Ingresos
CREATE TABLE FN_Ingresos (
    ID INT PRIMARY KEY,
    PersonaID INT,
    FuenteIngresos VARCHAR(255),
    MontoMensual DECIMAL(10, 2),
    FOREIGN KEY (PersonaID) REFERENCES FN_Persona(ID)
);
-- Tabla Endeudamiento
CREATE TABLE FN_Endeudamiento (
    ID INT PRIMARY KEY,
    PersonaID INT,
    TipoDeuda VARCHAR(255),
    MontoDeuda DECIMAL(10, 2),
    FOREIGN KEY (PersonaID) REFERENCES FN_Persona(ID)
);
-- Tabla EvaluacionCredito
CREATE TABLE FN_EvaluacionCredito (
    ID INT PRIMARY KEY,
    CreditoID INT,
    FechaEvaluacion DATE,
    Resultado VARCHAR(50),
    Observaciones TEXT,
    FOREIGN KEY (CreditoID) REFERENCES FN_Credito(ID)
);
-- Tabla TipoDocumento
CREATE TABLE FN_TipoDocumento (
    ID INT PRIMARY KEY,
    NombreTipoDocumento VARCHAR(100),
    Descripcion VARCHAR(255)
);

END
GO


