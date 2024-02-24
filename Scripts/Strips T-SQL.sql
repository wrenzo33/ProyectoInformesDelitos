
--Creacion de Dimensiones para problarlas

CREATE TABLE Dim_AreaDelito(
		ID_AreaDelito int NOT NULL IDENTITY(1,1) PRIMARY KEY,
		Nombre_Area varchar(50) NOT NULL,
		Nombre_Lugar varchar(100) NOT NULL,
		Nombre_Ubicacion varchar(50) NOT NULL
);

CREATE TABLE Dim_Estado_de_Informe(
		ID_Estado_Informe varchar(2) NOT NULL PRIMARY KEY,
		Descripcion_EstadoInforme varchar(50) NOT NULL
);

CREATE TABLE Dim_Tiempo(
		ID_Fecha int NOT NULL IDENTITY(1,1) PRIMARY KEY,
		Fecha DATE NOT NULL,
		Año int NOT NULL,
		Trimestre int NOT NULL,
		Trimestre_descripcion varchar(50) NOT NULL,
		Mes int NOT NULL,
		Mes_Descripcion varchar(50) NOT NULL
);

CREATE TABLE Dim_Tipo_Arma(
		ID_Arma int NOT NULL IDENTITY(1,1) PRIMARY KEY,
		Descripcion_Arma varchar(50) NOT NULL
);

CREATE TABLE Dim_Tipo_Delito(
		ID_Delito int NOT NULL IDENTITY(1,1) PRIMARY KEY,
		Descripcion_Delito varchar(100) NOT NULL
);

CREATE TABLE Dim_Victima(
		ID_Victima int NOT NULL IDENTITY(1,1) PRIMARY KEY,
		Genero varchar(50) NOT NULL,
		OrigenEtnico varchar(50) NOT NULL,
		Edad int NOT NULL
);


CREATE TABLE Fact_InfomesDelito(
		ID_Informe int NOT NULL IDENTITY (1,1) PRIMARY KEY,
		Nro_Informe int NOT NULL,
		ID_Fecha int NOT NULL,
		ID_AreaDelito int NOT NULL,
		ID_Delito int NOT NULL,
		ID_Arma int NOT NULL,
		ID_Victima int NOT NULL,
		ID_Estado_Informe int NOT NULL
)
;
--Pobland Dimension Tiempo

SELECT DISTINCT CONVERT(DATE, Fecha_Ocurrencia) AS Fecha,DATEPART(YEAR, Fecha_Ocurrencia) AS Año,
DATEPART(QUARTER, Fecha_Ocurrencia) AS Trimestre,
CASE 
	WHEN DATEPART(QUARTER, Fecha_Ocurrencia) = 1 THEN 'Primer Trimestre'
	WHEN DATEPART(QUARTER, Fecha_Ocurrencia) = 2 THEN 'Segundo Trimestre'
	WHEN DATEPART(QUARTER, Fecha_Ocurrencia) = 3 THEN 'Tercer Trimestre'
	WHEN DATEPART(QUARTER, Fecha_Ocurrencia) = 4 THEN 'Cuarto Trimestre'
END as Descripcion_Trimestre,
DATEPART(MONTH,Fecha_Ocurrencia) AS Mes,DATENAME(MONTH,Fecha_Ocurrencia) AS Descripcion_Mes  
FROM Fecha_Ocurrencia


--Poblando Dimensiones

SELECT DISTINCT GP.Descripcion_Genero,OE.Descripcion_OrigenEtnico,Edad_Victima FROM Informe_Detaills ID
INNER JOIN Genero_Persona GP ON GP.Genero_Victima = ID.Genero_Victima
INNER JOIN Origen_Etnico OE ON OE.Cod_OrigenEtnico_Victima = ID.Cod_OrigenEtnico_Victima

SELECT DISTINCT AG.Nombre_Area,LD.Descripcion_LugarDelito,UD.Ubicacion FROM Informe_Detaills ID
INNER JOIN Area_Geografica AG ON AG.Codigo_AreaGeo = ID.Codigo_AreaGeo
INNER JOIN Lugar_Delito LD ON LD.CodigoLugar_Delito = ID.CodigoLugar_Delito
INNER JOIN Ubicacion_Delito UD ON UD.ID_Ubicacion = ID.ID_Ubicacion

--Poblando fact informes

SELECT ID_Informe_Division,DT.ID_Fecha,DAD.ID_AreaDelito,DTD.ID_Delito,DTA.ID_Arma,DV.ID_Victima,DEI.ID_Estado_Informe FROM Informe_Detaills ID
INNER JOIN Area_Geografica AG ON (AG.Codigo_AreaGeo = ID.Codigo_AreaGeo)
INNER JOIN Lugar_Delito LD ON (LD.CodigoLugar_Delito = ID.CodigoLugar_Delito)
INNER JOIN Ubicacion_Delito UD ON (UD.ID_Ubicacion = ID.ID_Ubicacion)
INNER JOIN Dim_AreaDelito DAD ON (DAD.Nombre_Area = AG.Nombre_Area) AND 
		(DAD.Nombre_Lugar = LD.Descripcion_LugarDelito) AND 
		(DAD.Nombre_Ubicacion = UD.Ubicacion)
INNER JOIN Dim_Tiempo DT ON (DT.Fecha = ID.Fecha_Reporte)
INNER JOIN Tipo_Delito TD ON (TD.Codigo_Delito = ID.Codigo_Delito)
INNER JOIN Dim_Tipo_Delito DTD ON(DTD.Descripcion_Delito = TD.Descripcion_Delito)
INNER JOIN Tipo_Arma TA ON (TA.Codigo_Arma = ID.Codigo_Arma)
INNER JOIN Dim_Tipo_Arma DTA ON (DTA.Descripcion_Arma = TA.Descripcion_Arma)
INNER JOIN Genero_Persona GP ON (GP.Genero_Victima = ID.Genero_Victima)
INNER JOIN Origen_Etnico OE ON (OE.Cod_OrigenEtnico_Victima = ID.Cod_OrigenEtnico_Victima)
INNER JOIN Dim_Victima DV ON (DV.Genero = GP.Descripcion_Genero) AND
		(DV.OrigenEtnico = OE.Descripcion_OrigenEtnico) AND
		(DV.Edad = ID.Edad_Victima)
INNER JOIN Dim_Estado_de_Informe DEI ON (DEI.ID_Estado_Informe = ID.Cod_Estado_Informe)