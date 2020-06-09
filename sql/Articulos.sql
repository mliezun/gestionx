DROP function IF EXISTS `f_calcular_precio_articulo`;
DELIMITER $$
CREATE FUNCTION `f_calcular_precio_articulo`(pIdArticulo bigint, pDescuento decimal(10,4), pPorcentaje decimal(10,4)) RETURNS decimal(12,2)
    READS SQL DATA
BEGIN
	/*
    Calcula el precio de un artículo.
    */
	DECLARE pPrecioCosto, pPorcentajeIVA decimal(12,2);
    DECLARE pIdTipoIVA int;
    
	SELECT a.PrecioCosto, t.Porcentaje 
    INTO pPrecioCosto, pPorcentajeIVA
    FROM Articulos a 
    INNER JOIN TiposIVA t USING(IdTipoIVA)
    WHERE IdArticulo = pIdArticulo;
    
	RETURN pPrecioCosto * (1-pDescuento/100) * (1+pPorcentajeIVA/100) * (1+pPorcentaje/100);
END$$
DELIMITER ;

DROP function IF EXISTS `f_existencias_articulo`;
DELIMITER $$
CREATE FUNCTION `f_existencias_articulo`(pIdArticulo bigint) RETURNS json
    READS SQL DATA
BEGIN
	/*
    Calcula el precio de un artículo.
    */
    DECLARE pExistencias json;

	SELECT      JSON_ARRAYAGG(JSON_OBJECT(
                    'PuntoVenta', pv.PuntoVenta,
                    'Cantidad', ec.Cantidad,
                    'Canal', cc.Canal
                ))
    INTO        pExistencias
    FROM        ExistenciasConsolidadas ec
    INNER JOIN  PuntosVenta pv USING(IdPuntoVenta)
    INNER JOIN  Canales cc USING(IdCanal)
    WHERE       ec.IdArticulo = pIdArticulo AND pv.Estado = 'A' AND cc.Estado = 'A'
    GROUP BY    IdArticulo;
    
	RETURN pExistencias;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_alta_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_articulo`(pToken varchar(500), pIdProveedor bigint, pIdEmpresa int,
    pArticulo varchar(255), pCodigo varchar(255), pDescripcion text, pPrecioCosto decimal(12, 2),
    pIdTipoIVA tinyint, pIP varchar(40), pUserAgent varchar(255),
    pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de alta un articulo. Controlando que el nombre y el código del articulo no
    existan ya dentro del mismo proveedor. 
    Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pDescuento decimal(10,4);
    DECLARE pIdArticulo bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoIVA IS NULL OR pIdTipoIVA = 0) THEN
        SELECT 'Debe indicar el tipo de IVA.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pArticulo IS NULL OR pArticulo = '') THEN
        SELECT 'El nombre del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pCodigo IS NULL OR pCodigo = '') THEN
        SELECT 'El código del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDescripcion IS NULL OR pDescripcion = '') THEN
        SELECT 'La descripción del artículo no puede estar vacía.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPrecioCosto IS NULL OR pPrecioCosto = 0) THEN
        SELECT 'El precio de costo del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa) THEN
        SELECT 'La empresa indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoIVA FROM TiposIVA WHERE IdTipoIVA = pIdTipoIVA) THEN
        SELECT 'El tipo de IVA indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoIVA FROM TiposIVA
    WHERE IdTipoIVA = pIdTipoIVA AND FechaHasta IS NULL) THEN
        SELECT 'El tipo de IVA indicado no se encuentra vigente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Articulo = pArticulo) THEN
        SELECT 'Ya existe un artículo con ese nombre.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Codigo = pCodigo) THEN
        SELECT 'Ya existe un artículo con ese código.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Insercion en Articulos
        INSERT INTO Articulos
        SELECT  0, pIdProveedor, pIdEmpresa, pIdTipoIVA, pArticulo, pCodigo, pDescripcion, pPrecioCosto, NOW(), 'A';

        SET pIdArticulo = LAST_INSERT_ID();

        -- Insercion de Existencias
        INSERT INTO ExistenciasConsolidadas
        SELECT      pIdArticulo, IdPuntoVenta, IdCanal, 0
        FROM        PuntosVenta pv
        CROSS JOIN  Canales c
        WHERE       pv.IdEmpresa = pIdEmpresa AND c.IdEmpresa = pIdEmpresa;

        SET pDescuento = (SELECT MAX(Descuento) FROM Proveedores WHERE IdProveedor = pIdProveedor);

        -- Insercion de Precios Articulos
        INSERT INTO PreciosArticulos
        SELECT      pIdArticulo, IdListaPrecio, NOW(), f_calcular_precio_articulo(pIdArticulo, pDescuento, lp.Porcentaje)
        FROM        ListasPrecio lp
        WHERE       lp.IdEmpresa = pIdEmpresa;

        -- Insercion de Historial Precios
        -- INSERT INTO HistorialPrecios
        -- SELECT      0, pIdArticulo, pPrecioCosto, NOW(), NULL, NULL;

        INSERT INTO HistorialPrecios
        SELECT      0, pIdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
        FROM        PreciosArticulos WHERE IdArticulo = pIdArticulo;
        
        -- Audita Inserciones
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;

        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA_ARTICULO', 'I',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;
		
        SELECT CONCAT('OK', pIdArticulo) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_articulo`(pToken varchar(500), pIdArticulo bigint,
    pArticulo varchar(255), pCodigo varchar(255), pDescripcion text, pPrecioCosto decimal(12, 2),
    pIdTipoIVA tinyint, pIP varchar(40), pUserAgent varchar(255),
    pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite cambiar el nombre, el código, la descripción, el precio por defecto de un articulo,
    verificando que no exista uno igual dentro del mismo proveedor.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pPrecioCostoAntiguo decimal(12,2);
    DECLARE pDescuento decimal(10,4);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pArticulo IS NULL OR pArticulo = '') THEN
        SELECT 'El nombre del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pCodigo IS NULL OR pCodigo = '') THEN
        SELECT 'El código del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDescripcion IS NULL OR pDescripcion = '') THEN
        SELECT 'La descripción del artículo no puede estar vacía.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdTipoIVA IS NULL OR pIdTipoIVA = 0) THEN
        SELECT 'Debe indicar el tipo de IVA.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPrecioCosto IS NULL OR pPrecioCosto = 0) THEN
        SELECT 'El precio de costo del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoIVA FROM TiposIVA WHERE IdTipoIVA = pIdTipoIVA) THEN
        SELECT 'El tipo de IVA indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoIVA FROM TiposIVA
    WHERE IdTipoIVA = pIdTipoIVA AND FechaHasta IS NULL) THEN
        SELECT 'El tipo de IVA indicado no se encuentra vigente.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        SET pPrecioCostoAntiguo = (SELECT PrecioCosto FROM Articulos WHERE IdArticulo = pIdArticulo);

        -- Audita Articulos Antes
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;

        -- Modifica
        UPDATE  Articulos
        SET     Articulo = pArticulo,
                Codigo = pCodigo,
                Descripcion = pDescripcion,
                PrecioCosto = pPrecioCosto,
                IdTipoIVA = pIdTipoIVA
        WHERE   IdArticulo = pIdArticulo;

        IF (pPrecioCostoAntiguo != pPrecioCosto) THEN
            -- SET pDescuento = (SELECT MAX(p.Descuento) 
            -- FROM Proveedores p INNER JOIN Articulos a
            -- WHERE a.IdArticulo = pIdArticulo);

            -- Audito PreciosArticulos Antes
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_ARTICULO', 'A',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

            -- Modifico los PreciosArticulos
            UPDATE      PreciosArticulos pa
            INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
            INNER JOIN  Articulos a USING(IdArticulo)
            INNER JOIN  Proveedores p USING(IdProveedor)
            SET         pa.PrecioVenta = f_calcular_precio_articulo(IdArticulo, p.Descuento, lp.Porcentaje)
            WHERE       IdArticulo = pIdArticulo;

            INSERT INTO HistorialPrecios
            SELECT 0, IdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
            FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

            -- Audita PreciosArticulos Despues
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_ARTICULO', 'D',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

            -- Modifico el Historico
            UPDATE HistorialPrecios SET FechaFin = NOW() WHERE IdArticulo = pIdArticulo AND FechaFin IS NULL;
            
            -- Inserto Historico
            INSERT INTO HistorialPrecios
            SELECT      0, pIdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
            FROM        PreciosArticulos WHERE IdArticulo = pIdArticulo;

        END IF;

        -- Audita Articulos Despues
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_borra_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_articulo`(pToken varchar(500), pIdArticulo bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite borrar un articulo controlando que no tenga lineas asociadas.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM LineasVenta WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene ventas asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM LineasIngreso WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene ingresos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM ExistenciasConsolidadas WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene existencias asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM RectificacionesPV WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene rectificaciones asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;

        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_ARTICULO', 'A',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

        -- Borra
        DELETE FROM HistorialPrecios WHERE IdArticulo = pIdArticulo;

        DELETE FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

        DELETE FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_articulo`(pToken varchar(500), pIdArticulo bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de baja un articulo controlando que no esté dado de baja ya.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo AND Estado = 'B') THEN
        SELECT 'El artículo indicado ya se encuentra dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita Antes
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;

        -- Da de Baja Articulo
        UPDATE  Articulos
        SET     Estado = 'B'
        WHERE   IdArticulo = pIdArticulo;

        -- Audita Despues
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_activar_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_articulo`(pToken varchar(500), pIdArticulo bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite activar un articulo controlando que no esté activo ya.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo AND Estado = 'A') THEN
        SELECT 'El artículo indicado ya se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita Antes
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;

        -- Activa Articulo
        UPDATE  Articulos
        SET     Estado = 'A'
        WHERE   IdArticulo = pIdArticulo;

        -- Audita Despues
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_articulo`(pIdArticulo bigint)
SALIR: BEGIN
	/*
	Permite instanciar un artículo desde la base de datos.
	*/
    SELECT  a.*, JSON_OBJECTAGG(lp.Lista, pa.PrecioVenta) PreciosVenta, p.Proveedor, ti.TipoIVA
    FROM    Articulos a
    INNER JOIN Proveedores p USING(IdProveedor, IdEmpresa)
    INNER JOIN TiposIVA ti USING(IdTipoIVA)
    INNER JOIN PreciosArticulos pa USING(IdArticulo)
    INNER JOIN ListasPrecio lp USING(IdListaPrecio, IdEmpresa)
    WHERE   a.IdArticulo = pIdArticulo AND lp.Estado = 'A';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_cantidad_articulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_cantidad_articulos`(pIdEmpresa int)
BEGIN
    /*
    Permite obtener la cantidad de artículos de una empresa.
    */
    SELECT COUNT(IdArticulo) Total FROM Articulos WHERE IdEmpresa = pIdEmpresa;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_articulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_articulos`(pIdEmpresa int, pOffset bigint, pLimit bigint, pIdProveedor bigint, pIdListaPrecio bigint, pCadena varchar(100), pIncluyeBajas char(1), pIncluyeBajasListas char(1))
SALIR: BEGIN
	/*
	Permite buscar articulos dentro de un proveedor de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas. Si pIdProveedor = 0 lista para todos los proveedores activos de una empresa.
	*/
    SELECT  a.*, JSON_OBJECTAGG(lp.Lista, pa.PrecioVenta) PreciosVenta, p.Proveedor, ti.TipoIVA,
            f_calcular_precio_articulo(a.IdArticulo, p.Descuento, 0) PrecioCompra, f_existencias_articulo(IdArticulo) Existencias
    FROM       Articulos a
    INNER JOIN Proveedores p USING(IdProveedor, IdEmpresa)
    INNER JOIN TiposIVA ti USING(IdTipoIVA)
    INNER JOIN PreciosArticulos pa USING(IdArticulo)
    INNER JOIN ListasPrecio lp USING(IdListaPrecio, IdEmpresa)
    WHERE   a.IdEmpresa = pIdEmpresa
            AND (pIdListaPrecio = 0 OR lp.IdListaPrecio = pIdListaPrecio)
            AND (pIdProveedor = 0 OR a.IdProveedor = pIdProveedor)
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%')
                )
            AND (pIncluyeBajas = 'S' OR a.Estado = 'A')
            AND (pIncluyeBajasListas = 'S' OR lp.Estado = 'A')
    GROUP BY a.IdArticulo
    LIMIT pOffset, pLimit;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_articulos_por_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_articulos_por_cliente`(pIdEmpresa int, pIdCliente bigint, pCadena varchar(100))
SALIR: BEGIN
	/*
	Permite buscar articulos y su precios para un cliente de una empresa, indicando una cadena de búsqueda.
	*/
    SELECT  a.IdArticulo, a.IdProveedor, a.IdEmpresa, a.IdTipoIVA, a.Codigo, a.Descripcion, a.PrecioCosto, a.Estado, a.FechaAlta,
			CONCAT(a.Articulo, ' (', p.Proveedor, ')') Articulo, IF(pIdCliente = 0, a.PrecioCosto, (SELECT pa.PrecioVenta FROM PreciosArticulos pa INNER JOIN ListasPrecio lp USING(IdListaPrecio) INNER JOIN Clientes USING(IdListaPrecio) WHERE IdCliente = pIdCliente AND pa.IdArticulo = a.IdArticulo)) PrecioVenta
    FROM    Articulos a
    INNER JOIN Proveedores p USING(IdProveedor)
    WHERE   a.IdEmpresa = pIdEmpresa AND a.Estado = 'A'
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%') OR
                    p.Proveedor LIKE CONCAT('%', pCadena, '%')
                )
    GROUP BY a.IdArticulo;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_articulos_autocompletado`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_articulos_autocompletado`(pIdEmpresa int, pCadena varchar(100))
SALIR: BEGIN
	/*
	Permite buscar articulos dentro de un proveedor de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas. Si pIdProveedor = 0 lista para todos los proveedores activos de una empresa.
	*/
    SELECT  a.*, CONCAT(a.Articulo, ' (', a.Codigo, ') [', p.Proveedor, ']') NombreArticulo
    FROM    Articulos a
    INNER JOIN  Proveedores p USING(IdProveedor)
    WHERE   a.IdEmpresa = pIdEmpresa
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%') OR
                    p.Proveedor LIKE CONCAT('%', pCadena, '%')
                )
            AND (a.Estado = 'A');
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_listar_listas_precios_articulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_listas_precios_articulos`(pIdArticulo bigint)
SALIR: BEGIN
	/*
	Permite listar las listas de precios de un articulo desde la base de datos.
	*/
    SELECT  lp.Lista, pa.*
    FROM    Articulos a
    INNER JOIN PreciosArticulos pa USING(IdArticulo)
    INNER JOIN ListasPrecio lp USING(IdListaPrecio)
    WHERE   a.IdArticulo = pIdArticulo AND lp.Estado = 'A';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_precio_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_precio_articulo`(pIdArticulo bigint, pIdListaPrecio bigint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un precio articulo desde la base de datos.
    */
	SELECT	*
    FROM	PreciosArticulos
    WHERE	IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_precio_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_precio_articulo`(pToken varchar(500), pIdArticulo bigint, pIdListaPrecio bigint,
    pPrecioVenta decimal(12, 2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar un precio de un articulo.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdArticulo IS NULL OR pIdArticulo = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdListaPrecio IS NULL OR pIdListaPrecio = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPrecioVenta IS NULL OR pPrecioVenta = 0) THEN
        SELECT 'El precio de venta del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El articulo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio) THEN
        SELECT 'La lista de precios indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio AND Estado = 'A') THEN
        SELECT 'La lista no se encuentra activa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo AND Estado = 'A') THEN
        SELECT 'El Articulo no se encuentra activa.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita Antes
        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;

        -- Modifica en PreciosArticulos
        UPDATE PreciosArticulos
        SET     PrecioVenta=pPrecioVenta,
                FechaAlta=NOW()
        WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;
        
        -- Audita Despues
        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_listar_historial_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_historial_articulo`(pIdArticulo bigint, pIdEmpresa bigint)
SALIR: BEGIN
	/*
	Permite listar el historial de precios de un articulo.
	*/
    SELECT  a.Articulo, lp.Lista, hp.*
    FROM    Articulos a
    INNER JOIN HistorialPrecios hp USING(IdArticulo)
    LEFT JOIN ListasPrecio lp USING(IdListaPrecio)
    WHERE   a.IdArticulo = pIdArticulo
            AND lp.IdEmpresa = pIdEmpresa
    ORDER BY FechaFin;
END$$
DELIMITER ;
