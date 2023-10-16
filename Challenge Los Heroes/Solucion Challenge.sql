USE [DB_lh_fnegrete]
GO

/****** Object:  StoredProcedure [dbo].[solucion]    Script Date: 16-10-2023 10:25:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Autor:		Felipe Negrete
-- Fecha de creacion: 13-10-2023,
-- Descripcion:	Desarrollo challenge Analista de base de datos
-- =============================================
CREATE PROCEDURE [dbo].[solucion]

	
AS
BEGIN

/*Pregunta A: Listado de cuantas licencias médicas ha tenido cada trabajador con COVID por cada empresa
			  con contrato vigente. (Columnas resultantes: nombre empresa, nombre trabajador,
			  cantidad licencias).
*/

	SELECT 
		EMPRESA.NOMBRE_EMPRESA AS [Nombre Empresa],
		TRABAJADOR.NOMBRE_TRABAJADOR AS [Nombre Trabajador],
		COUNT(LICENCIA.ID_LICENCIA_MEDICA) AS [Cantidad de Licencias]   
	FROM
		TBL_TRABAJADOR TRABAJADOR
	INNER JOIN
		REL_TRABAJADOR_EMPRESA RE ON TRABAJADOR.ID_TRABAJADOR = RE.ID_TRABAJADOR
	INNER JOIN
		TBL_EMPRESA EMPRESA ON RE.ID_EMPRESA = EMPRESA.ID_EMPRESA
	INNER JOIN
		TBL_LICENCIA_MEDICA LICENCIA  ON RE.ID_TRABAJADOR_EMPRESA = LICENCIA.ID_TRABAJADOR_EMPRESA
	WHERE
	   LICENCIA.CODIGO_ENFERMEDAD = 123 -- Asumiendo que el codigo para COVID sea 123.
	   AND RE.FECHA_FIN_CONTRATO > GETDATE()  -- Contrato vigente
	GROUP BY
		EMPRESA.NOMBRE_EMPRESA, TRABAJADOR.NOMBRE_TRABAJADOR

/* Pregunta B: Listar empresas las cuales no tienen trabajadores vigentes, pero si han tenido al menos una
               licencia médica. (Columnas resultantes: rut empresa, nombre empresa).
*/

	SELECT 
		EMPRESA.RUT_EMPRESA AS [RUT Empresa],
		EMPRESA.NOMBRE_EMPRESA AS [Nombre Empresa]
	FROM
		TBL_EMPRESA EMPRESA
	LEFT JOIN
		REL_TRABAJADOR_EMPRESA REL ON EMPRESA.ID_EMPRESA = REL.ID_EMPRESA
	LEFT JOIN
		TBL_TRABAJADOR TRABAJADOR ON REL.ID_TRABAJADOR = TRABAJADOR.ID_TRABAJADOR
	WHERE
		REL.FECHA_FIN_CONTRATO < GETDATE() -- Contrato no vigente
	GROUP BY
		EMPRESA.RUT_EMPRESA, EMPRESA.NOMBRE_EMPRESA

/* Pregunta C:  Listar cantidad de licencias médicas y el monto reembolsado, por cada empresa, por año a
				partir del 2015. (Columnas resultantes: nombre empresa, año, cantidad licencias, monto
				reembolsado).
*/

	SELECT
		EMPRESA.NOMBRE_EMPRESA AS [Nombre Empresa],
		YEAR(LICENCIA.FECHA_INICIO) AS [Año],
		COUNT(LICENCIA.ID_LICENCIA_MEDICA) AS [Cantidad de Licencias],
		SUM(LICENCIA.MONTO_REEMBOLSO) AS [MONTO_REEMBOLSO]
	FROM
		TBL_EMPRESA EMPRESA
	INNER JOIN
		REL_TRABAJADOR_EMPRESA REL ON EMPRESA.ID_EMPRESA = REL.ID_EMPRESA
	INNER JOIN
		TBL_LICENCIA_MEDICA LICENCIA ON REL.ID_TRABAJADOR_EMPRESA = LICENCIA.ID_TRABAJADOR_EMPRESA
	WHERE
		YEAR(LICENCIA.FECHA_INICIO) >= 2015
	GROUP BY
		EMPRESA.NOMBRE_EMPRESA, YEAR(LICENCIA.FECHA_INICIO)

/* Pregunta D: Lista de trabajadores que tienen contrato vigente, en al menos una empresa, y han tenido
			   licencia médica continua desde el inicio del año actual junto con la cantidad de licencias que
			   lleva. (Columnas resultantes: rut trabajador, nombre trabajador, cantidad licencias).
*/

	SELECT
		TRABAJADOR.RUT_TRABAJADOR AS [Rut trabajador],
		TRABAJADOR.NOMBRE_TRABAJADOR AS [Nombre trabajador],
		COUNT(LICENCIA.ID_LICENCIA_MEDICA) AS [Cantidad licencias]

	FROM
		TBL_TRABAJADOR TRABAJADOR
	INNER JOIN
		REL_TRABAJADOR_EMPRESA REL ON TRABAJADOR.ID_TRABAJADOR = REL.ID_TRABAJADOR
	INNER JOIN
		TBL_EMPRESA EMPRESA ON REL.ID_EMPRESA = EMPRESA.ID_EMPRESA
	INNER JOIN
		TBL_LICENCIA_MEDICA LICENCIA ON REL.ID_TRABAJADOR_EMPRESA = LICENCIA.ID_TRABAJADOR_EMPRESA
	WHERE	

		REL.FECHA_FIN_CONTRATO   > GETDATE()	
		AND EXISTS (
			SELECT 1
			FROM TBL_LICENCIA_MEDICA AS LICENCIA
			WHERE
				LICENCIA.ID_TRABAJADOR_EMPRESA = LICENCIA.ID_TRABAJADOR_EMPRESA				
				AND LICENCIA.FECHA_INICIO = DATEADD(DAY, 1, LICENCIA.FECHA_FIN)  -- Fecha de inicio + 1 día es igual a la fecha de fin
				AND LICENCIA.FECHA_FIN >= GETDATE()
		)
	GROUP BY
		TRABAJADOR.RUT_TRABAJADOR, TRABAJADOR.NOMBRE_TRABAJADOR
	HAVING COUNT(LICENCIA.ID_LICENCIA_MEDICA) > 0

	--OBSERVACION: No existen licencias continuas que terminen en la fecha actual


/* Pregunta E: Promedio de renta pagada por cada empresa, asumiendo que las rentas se almacenan con
			   la key “renta1” a “rentaN”. (Columnas resultantes: rut empresa, nombre empresa,
			   promedio de rentas).
*/

	SELECT EMPRESA.RUT_EMPRESA [RUT Empresa]
		 , EMPRESA.NOMBRE_EMPRESA [Nombre Empresa]
		 , AVG(RENTAS.MONTO) [Promedio de rentas]

	FROM 
		TBL_EMPRESA EMPRESA
	INNER JOIN 
	 	REL_TRABAJADOR_EMPRESA REL ON EMPRESA.ID_EMPRESA = REL.ID_EMPRESA
	INNER JOIN 
		TBL_LICENCIA_MEDICA LICENCIA ON LICENCIA.ID_TRABAJADOR_EMPRESA = REL.ID_TRABAJADOR_EMPRESA
	INNER JOIN 
		( 
		SELECT ID_LICENCIA_MEDICA, CASE WHEN ISNUMERIC(VALUE) = 1 THEN VALUE ELSE 0 END MONTO
		FROM TBL_METADATOS
		) RENTAS ON LICENCIA.ID_LICENCIA_MEDICA = RENTAS.ID_LICENCIA_MEDICA
	GROUP BY EMPRESA.RUT_EMPRESA, EMPRESA.NOMBRE_EMPRESA;
		 

/* Pregunta F: Listado de cada empresa, solo con los 3 trabajadores que han tenido los mayores
			   reembolsos, ordenándolos de mayor a menor e indicando su posición (1,2 o 3). (Columnas
			   resultantes: nombre empresa, rut trabajador, nombre trabajador, monto reembolsado,
			   posición).
*/

		SELECT lista.NOMBRE_EMPRESA,
			   lista.RUT_TRABAJADOR,
			   lista.NOMBRE_TRABAJADOR,
			   lista.MONTO_REEMBOLSO,
			   lista.Posicion
		FROM (
			SELECT E.NOMBRE_EMPRESA,
				   T.RUT_TRABAJADOR,
				   T.NOMBRE_TRABAJADOR,
				   LM.MONTO_REEMBOLSO,
				   ROW_NUMBER() OVER (PARTITION BY E.NOMBRE_EMPRESA ORDER BY LM.MONTO_REEMBOLSO DESC) AS Posicion
			FROM TBL_EMPRESA E
			INNER JOIN 
				REL_TRABAJADOR_EMPRESA RE ON E.ID_EMPRESA = RE.ID_EMPRESA
			INNER JOIN 
				TBL_TRABAJADOR T ON RE.ID_TRABAJADOR = T.ID_TRABAJADOR
			INNER JOIN 
				TBL_LICENCIA_MEDICA LM ON RE.ID_TRABAJADOR_EMPRESA = LM.ID_TRABAJADOR_EMPRESA
		) AS lista
		WHERE lista.Posicion <= 3 order by NOMBRE_EMPRESA desc;




/* Pregunta G: Lista de trabajadores que tienen licencia medica vigente, con su monto reembolsado y las 3
			   primeras rentas que se almacenaron para el calculo de su reembolso. (Columnas
			   resultantes: rut trabajador, nombre trabajador, monto reembolsado, renta1, renta2,
			   renta3).
*/

		SELECT
			RUT_TRABAJADOR,
			NOMBRE_TRABAJADOR,
			MONTO_REEMBOLSO,
			[RENTA1],
			[RENTA2],
			[RENTA3]
		FROM
		(
			SELECT
				TRABAJADOR.ID_TRABAJADOR,
				TRABAJADOR.RUT_TRABAJADOR,
				TRABAJADOR.NOMBRE_TRABAJADOR,
				LICENCIA.MONTO_REEMBOLSO,
				LICENCIA.FECHA_INICIO,
				META.[KEY],
				META.VALUE
			FROM
				TBL_TRABAJADOR TRABAJADOR
				INNER JOIN 
						REL_TRABAJADOR_EMPRESA REL ON TRABAJADOR.ID_TRABAJADOR = REL.ID_TRABAJADOR
				INNER JOIN 
						TBL_LICENCIA_MEDICA LICENCIA ON REL.ID_TRABAJADOR_EMPRESA = LICENCIA.ID_TRABAJADOR_EMPRESA
				INNER JOIN 
						TBL_METADATOS META ON LICENCIA.ID_LICENCIA_MEDICA = META.ID_LICENCIA_MEDICA
			WHERE
      			REL.FECHA_FIN_CONTRATO   > GETDATE() -- Contrato vigente
		
		) AS Tabla
		PIVOT
		(
			MAX(VALUE) FOR [KEY] IN ([RENTA1], [RENTA2], [RENTA3])

		) AS TablaResultado;


	
END


GO


