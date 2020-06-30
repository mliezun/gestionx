DROP PROCEDURE IF EXISTS `xsp_listar_tablas`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_tablas`(pSchema varchar(255))
SALIR: BEGIN
    /*
	Permite listar las tablas del sistema.
	*/    
    -- Obtener nombres de todas las tablas excepto aquellas que son de auditoría
    DROP TEMPORARY TABLE IF EXISTS tmp_atributos_tabla;
    CREATE TEMPORARY TABLE tmp_atributos_tabla ENGINE = MEMORY
        SELECT 	c.`TABLE_NAME` Tabla, JSON_ARRAYAGG(JSON_OBJECT(
                    'Columna', CAST(COLUMN_NAME AS CHAR(255)),
                    'Tipo', CAST(COLUMN_TYPE AS CHAR(255)),
                    'Null', CAST(IS_NULLABLE AS CHAR(255)),
                    'Key', CAST(COLUMN_KEY AS CHAR(255)),
                    'Default', CAST(COLUMN_DEFAULT AS CHAR(255))
                )) Columnas
        FROM 	`INFORMATION_SCHEMA`.`COLUMNS` c
        WHERE 	`TABLE_SCHEMA` = pSchema
        GROUP BY c.`TABLE_NAME`;

    SELECT  JSON_ARRAYAGG(JSON_OBJECT(
            'Tabla', t.Tabla,
            'Columnas', t.Columnas
            )) Tablas
    FROM    tmp_atributos_tabla t;

    DROP TEMPORARY TABLE IF EXISTS tmp_atributos_tabla;
END$$
DELIMITER ;

/*
-- Ideas --
    - Tablas a ocultar
    - Columnas a ocultar
    - Transformaciones a nombres de tablas
    - Transformaciones a nombres de columnas
    - Columnas incruzables (Estado, Observaciones, IdEmpresa, ...)
Al seleccionar una tabla en la interfaz de creación de informes se grisan todas las que no se pueden
cruzar por alguna columna.
Después de elegir las tablas se eligen las columnas de cada una que se desean incluir en los informes.
Luego se eligen cuáles son los atributos que se van a incluir en el where (es decir los que funcionarán como filtros).
Por último se genera el procedimiento almacenado y se inserta en la tabla informes.
*/



DROP procedure IF EXISTS `xsp_inf_dame_modeloreporte`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_modeloreporte`(pIdEmpresa int, pIdModeloReporte int)
BEGIN
	/*
    Trae todos los campos de la tabla ModelosReporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT		*
    FROM		ModelosReporte
    WHERE		IdModeloreporte = pIdModeloReporte;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$
DELIMITER ;



DROP procedure IF EXISTS `xsp_inf_dame_parametro_listado`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_parametro_listado`(pIdEmpresa int, pIdModeloReporte int, pNroParametro tinyint, pId varchar(20))
SALIR:BEGIN
	/*
    Permite traer el nombre del elemento de un listado dado el Id.
    */
	DECLARE pProcDame varchar(100);
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SET pProcDame = (SELECT ProcDame FROM ParamsReportes WHERE IdModeloReporte = pIdModeloReporte AND NroParametro = pNroParametro AND Tipo IN('L','A'));
    IF pProcDame IS NULL THEN
		SELECT 'ERROR' Nombre;
        LEAVE SALIR;
	END IF;
		CALL xsp_eval(CONCAT('call ', pProcDame, '("', pIdEmpresa,'", "', pId,'");'));
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$
DELIMITER ;



DROP procedure IF EXISTS `xsp_inf_dame_parametros_modeloreporte`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_parametros_modeloreporte`(pIdEmpresa int, pIdModeloReporte int, pTipoOrden char(1))
BEGIN
	/*
    Trae todos los parámetros de un modelo de reporte ordenados por pTipoOrden: P: Parámetro - F: Formulario.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    IF pTipoOrden = 'P' THEN
		SELECT		*
		FROM		ParamsReportes
		WHERE		IdModeloReporte = pIdModeloReporte
		ORDER BY	NroParametro;
	ELSE
		SELECT		*
		FROM		ParamsReportes
		WHERE		IdModeloReporte = pIdModeloReporte
		ORDER BY	OrdenForm;
    END IF;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;




DROP procedure IF EXISTS `xsp_inf_ejecutar_reporte`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_ejecutar_reporte`(pIdEmpresa int, pIdModeloReporte int, pCadenaParametros text)
BEGIN
	/*
    Permite traer el resultset del reporte. Para ello trae el nombre del SP de la tabla ModelosReporte.
    */
	DECLARE pProcedimiento varchar(100);
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW errors;
		SELECT 'Error' Mensaje;
	END;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SET pProcedimiento = (SELECT Procedimiento FROM ModelosReporte WHERE IdModeloReporte = pIdModeloReporte);
	IF pProcedimiento IS NULL THEN
		SELECT 'Error' AS Mensaje;
	END IF;
	CALL xsp_eval(CONCAT('call ', pProcedimiento, '("', pIdEmpresa, '", ', pCadenaParametros,');'));
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;




DROP procedure IF EXISTS `xsp_inf_listar_menu_reportes`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_listar_menu_reportes`(pIdEmpresa int)
BEGIN
	/*
    Lista el menú correspondiente a los informes activos, adjuntando un campo que dice si es o no es hoja (EsHoja = [S|N], cuando no es hoja es un menú de distribución).
    Los ítems de menú están listados en orden jerárquico y arbóreo, con el nodo padre, el nivel del árbol y una cadena para mostrarlo ordenado.
    */
	DECLARE pNivel tinyint DEFAULT 0;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DROP TEMPORARY TABLE IF EXISTS Arbol, aux;
    -- Tabla auxiliar para ir armando árbol
    CREATE TEMPORARY TABLE Arbol ENGINE = MEMORY AS
		SELECT	IdModeloReporte, IdModeloReportePadre, Reporte, NombreMenu, Ayuda, OrdenMenu, IF(Procedimiento IS NULL,'N','S') EsHoja, 0 'Nivel', 'N' Visitado, '00000000000000000000' Ordenar
		FROM	ModelosReporte
		WHERE	Estado='A';
    -- Nivel 1
    SET pNivel = 1;
    UPDATE	Arbol SET Visitado = 'S', Nivel = pNivel, Ordenar = LPAD(CONVERT(OrdenMenu, char(3)), 2,'0')
    WHERE	IdModeloReportePadre IS NULL;
    -- Loop hasta visitar todos los nodos
    armar_arbol: LOOP
        IF NOT EXISTS(SELECT Visitado FROM Arbol WHERE Visitado='N') THEN
			LEAVE armar_arbol;
		END IF;
        -- Tabla auxiliar de los padres ya visitados
        CREATE TEMPORARY TABLE aux ENGINE = MEMORY AS
			SELECT IdModeloReporte, Nivel, Ordenar FROM Arbol WHERE Nivel = pNivel AND Visitado='S';
		UPDATE	Arbol
				INNER JOIN aux ON Arbol.IdModeloReportePadre = aux.IdModeloReporte
		SET		Arbol.Visitado = 'S', Arbol.Nivel = pNivel + 1, Arbol.Ordenar = CONCAT(aux.Ordenar, '.', LPAD(CONVERT(Arbol.OrdenMenu, char(3)), 2,'0'));
        DROP TEMPORARY TABLE aux;
		SET pNivel = pNivel + 1;
    END LOOP armar_arbol;
    SELECT	IdModeloReporte, IdModeloReportePadre, Reporte, NombreMenu, Ayuda, EsHoja, Nivel, Ordenar FROM Arbol ORDER BY Ordenar;
    
    DROP TEMPORARY TABLE IF EXISTS Arbol, aux;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$
DELIMITER ;



DROP procedure IF EXISTS `xsp_inf_llenar_listado_parametro`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_llenar_listado_parametro`(pIdEmpresa int, pIdModeloReporte int, pNroParametro tinyint, pCadena varchar(300))
SALIR:BEGIN
	/*
    Permite traer un resultset de forma {Id,Nombre} para poblar la lista del parámetro que debe ser de tipo L: Listado o A: Autocompletar.
    En este último caso, debe pasarse el parámetro pCadena; en otro caso, pasar ''. Lo ordena por nombre. No incluye el TODOS.
    */
	DECLARE pProcLlenado varchar(100);
    DECLARE pTipo char(1);
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SET pProcLlenado = (SELECT ProcLlenado FROM ParamsReportes WHERE IdModeloReporte = pIdModeloReporte AND NroParametro = pNroParametro AND Tipo IN('L','A'));
    SET pTipo = (SELECT Tipo FROM ParamsReportes WHERE IdModeloReporte = pIdModeloReporte AND NroParametro = pNroParametro AND Tipo IN ('L','A'));
    IF pProcLlenado IS NULL THEN
		SELECT 0 Id, 'ERROR' Nombre;
        LEAVE SALIR;
	END IF;
    IF pTipo = 'L' THEN
		CALL xsp_eval(CONCAT('call ', pProcLlenado, '("', pIdEmpresa, '");'));
	ELSE
		CALL xsp_eval(CONCAT('call ', pProcLlenado, '("', pIdEmpresa, '", \'',REPLACE(pCadena,"'","\\'"),'\');'));
    END IF;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;



DROP procedure IF EXISTS `xsp_inf_autocompletar_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_autocompletar_puntosventa`(pIdEmpresa int, pCadena varchar(50))
BEGIN
	/*
    Permite buscar los puntos de venta dada una cadena de búsqueda que se autocompleta con el nombre del punto de venta que coincide con parte del nombre.
    Busca a partir de una cadena de más de 3 caracteres. Llena la lista del parámetro tipo A: Autocompletar de varios reportes.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
	SELECT		IdPuntoVenta Id, PuntoVenta Nombre
    FROM		PuntosVenta
    WHERE		IdEmpresa = pIdEmpresa AND Estado = 'A' AND
				(PuntoVenta LIKE CONCAT('%', pCadena, '%')) AND
				CHAR_LENGTH(pCadena) > 3
	ORDER BY	PuntoVenta;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;




DROP procedure IF EXISTS `xsp_inf_dame_param_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_puntoventa`(pIdEmpresa int, pId varchar(20))
BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT PuntoVenta Nombre FROM PuntosVenta WHERE IdEmpresa = pIdEmpresa AND IdPuntoVenta = pId;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;




DROP PROCEDURE IF EXISTS `xsp_reporte_ventas`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_ventas`(pIdEmpresa int, pFechaInicio date, pFechaFin date, pIdPuntoVenta int)
BEGIN
    DECLARE pTotal, pPagado, pDeuda DECIMAL(14,2);
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET pIdPuntoVenta = COALESCE(pIdPuntoVenta, 0);

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_ventas;
    CREATE TEMPORARY TABLE tmp_inf_ventas
        SELECT      v.FechaAlta 'Fecha',
                    CASE v.Tipo
                        WHEN 'V' THEN 'Venta'
                        WHEN 'P' THEN 'Presupuesto'
                        WHEN 'C' THEN 'Cotizacion'
                        ELSE 'Otro'
                    END 'Tipo de Venta',
                    v.Monto 'Monto Total',
                    COALESCE((SELECT SUM(p.Monto) FROM Pagos p WHERE p.IdVenta = v.IdVenta), 0) 'Monto Pagado',
                    COALESCE((v.Monto - (SELECT SUM(p.Monto) FROM Pagos p WHERE p.IdVenta = v.IdVenta)), v.Monto) Deuda,
                    (
                        SELECT JSON_ARRAYAGG(JSON_OBJECT(
                            'MedioPago', mp.MedioPago,
                            'Monto', p.Monto,
                            'Fecha', p.FechaPago
                        ))
                        FROM Pagos p
                        INNER JOIN MediosPago mp USING(IdMedioPago)
                        WHERE p.IdVenta = v.IdVenta
                    ) PagosJson,
                    JSON_ARRAYAGG(JSON_OBJECT(
                        'Articulo', a.Articulo,
                        'Precio', lv.Precio,
                        'Cantidad', lv.Cantidad,
                        'Subtotal', lv.Precio*lv.Cantidad,
                        'Descuento', IF(lv.Factor < 0, lv.Factor, 0)
                    )) ArticulosJson,
                    GROUP_CONCAT(pr.Proveedor) Proveedores, pv.PuntoVenta,
                    CONCAT(u.Nombres, ' ', u.Apellidos) Vendedor,
                    IF(cl.Tipo = 'F', CONCAT(cl.Nombres, ' ', cl.Apellidos), cl.RazonSocial) Cliente
        FROM        Ventas v
        INNER JOIN  Clientes cl USING(IdCliente)
        -- LEFT JOIN   Pagos p ON v.IdVenta = p.IdVenta
        -- LEFT JOIN   MediosPago mp USING(IdMedioPago)
        INNER JOIN  LineasVenta lv ON v.IdVenta = lv.IdVenta
        INNER JOIN  Articulos a USING(IdArticulo)
        INNER JOIN  Proveedores pr USING(IdProveedor)
        INNER JOIN  PuntosVenta pv ON v.IdPuntoVenta = pv.IdPuntoVenta
        INNER JOIN  Usuarios u ON v.IdUsuario = u.IdUsuario
        WHERE       v.IdEmpresa = pIdEmpresa AND
                    (v.FechaAlta BETWEEN pFechaInicio AND pFechaFin) AND 
                    v.IdPuntoVenta = IF(pIdPuntoVenta = 0, v.IdPuntoVenta, pIdPuntoVenta)
        GROUP BY    v.IdVenta
        ORDER BY    v.IdVenta desc;


    SELECT  SUM(`Monto Total`), SUM(`Monto Pagado`), SUM(Deuda)
    INTO    pTotal, pPagado, pDeuda
    FROM    tmp_inf_ventas;

    SELECT * FROM tmp_inf_ventas
    UNION ALL
    SELECT NOW(), 'TOTALES', pTotal, pPagado, pDeuda, NULL, NULL, NULL, NULL, NULL, NULL;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_inf_ventas;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$
DELIMITER ;

