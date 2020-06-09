DROP PROCEDURE IF EXISTS `xsp_alta_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_venta`(pToken varchar(500), pIdEmpresa int, pIdPuntoVenta bigint, pIdCliente bigint,
pIdTipoComprobanteAfip smallint, pIdTipoTributo tinyint, pIdCanal bigint, pTipo char(1), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta una venta en un punto de venta, indicando el cliente, el tipo de venta y el usuario.
    * Controlando que el tipo de tributo y tipo de comprobantes existan y esten activos.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdVenta bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdPuntoVenta IS NULL OR pIdPuntoVenta = 0) THEN
        SELECT 'Debe indicar el punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCliente IS NULL OR pIdCliente = 0) THEN
        SELECT 'Debe indicar el punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCanal IS NULL OR pIdCanal = 0) THEN
        SELECT 'Debe indicar el canal de la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoComprobanteAfip IS NOT NULL) THEN
        IF (pIdTipoComprobanteAfip = 0) THEN
            SELECT 'Debe indicar el tipo de comprobante.' Mensaje;
            LEAVE SALIR;
        END IF;
	END IF;
    IF (pIdTipoTributo IS NOT NULL) THEN
        IF (pIdTipoTributo = 0) THEN
            SELECT 'Debe indicar el tipo de tributo.' Mensaje;
            LEAVE SALIR;
        END IF;
	END IF;
	IF (pTipo IS NULL) THEN
        SELECT 'Debe ingresar el tipo de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa) THEN
        SELECT 'La empresa indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdPuntoVenta FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta) THEN
        SELECT 'El punto de venta indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCanal FROM Canales WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoComprobanteAfip IS NOT NULL) THEN
        IF NOT EXISTS (SELECT IdTipoComprobanteAfip FROM TiposComprobantesAfip WHERE IdTipoComprobanteAfip = pIdTipoComprobanteAfip) THEN
            SELECT 'El tipo de comprobante indicado no existe.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;
    IF (pIdTipoTributo IS NOT NULL) THEN
        IF NOT EXISTS (SELECT IdTipoTributo FROM TiposTributos WHERE IdTipoTributo = pIdTipoTributo) THEN
            SELECT 'El tipo de tributo indicado no existe.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO Ventas 
        SELECT 0, pIdPuntoVenta, pIdEmpresa, pIdCliente, pIdUsuario,
        pIdTipoComprobanteAfip, pIdTipoTributo, pIdCanal, 0, NOW(), pTipo, 'E', pObservaciones;
        SET pIdVenta = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_Ventas
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
        
        SELECT CONCAT('OK', pIdVenta) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_venta`(pToken varchar(500), pIdVenta bigint, pIdEmpresa int, pIdCliente bigint,
pIdTipoComprobanteAfip smallint, pIdTipoTributo tinyint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite modificar una venta en un punto de venta, siempre y cuando la venta este en edicion.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCliente IS NULL OR pIdCliente = 0) THEN
        SELECT 'Debe indicar el punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoComprobanteAfip IS NOT NULL) THEN
        IF (pIdTipoComprobanteAfip = 0) THEN
            SELECT 'Debe indicar el tipo de comprobante.' Mensaje;
            LEAVE SALIR;
        END IF;
	END IF;
    IF (pIdTipoTributo IS NOT NULL) THEN
        IF (pIdTipoTributo = 0) THEN
            SELECT 'Debe indicar el tipo de tributo.' Mensaje;
            LEAVE SALIR;
        END IF;
	END IF;
    
	-- Control de Parametros incorrectos
	IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
		SELECT 'La venta debe estar en edicion para ser modificada.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa) THEN
        SELECT 'La empresa indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoComprobanteAfip IS NOT NULL) THEN
        IF NOT EXISTS (SELECT IdTipoComprobanteAfip FROM TiposComprobantesAfip WHERE IdTipoComprobanteAfip = pIdTipoComprobanteAfip) THEN
            SELECT 'El tipo de comprobante indicado no existe.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;
    IF (pIdTipoTributo IS NOT NULL) THEN
        IF NOT EXISTS (SELECT IdTipoTributo FROM TiposTributos WHERE IdTipoTributo = pIdTipoTributo) THEN
            SELECT 'El tipo de tributo indicado no existe.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;

    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Audito Antes
        INSERT INTO aud_Ventas
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
		-- Da de alta calculando el próximo id
        UPDATE Ventas
        SET     IdCliente=pIdCliente,
                IdTipoComprobanteAfip=pIdTipoComprobanteAfip,
                IdTipoTributo=pIdTipoTributo,
                Observaciones=pObservaciones
        WHERE IdVenta=pIdVenta;
		-- Audito Despues
		INSERT INTO aud_Ventas
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_venta`(pToken varchar(500), pIdVenta bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar una venta controlando que no tenga pagos o lineas ventas asosiadas,
    * siempre y cuando se encuentre en estado de edicion ademas que estar dentro del tiempo de anulacion de la empresa.
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pIdEmpresa int;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_venta', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no se puede borrar, tiene pagos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no se puede borrar, tiene lineas de venta asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
		SELECT 'La venta debe estar en edicion para ser borrada.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Ventas WHERE IdVenta = pIdVenta);
    IF NOT ((SELECT FechaAlta FROM Ventas WHERE IdVenta = pIdVenta) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1) ) ) THEN
        SELECT 'La venta supero el tiempo maximo de anulacion.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Ventas
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Ventas.*
        FROM Ventas WHERE IdVenta = pIdVenta;
        -- Borro
        DELETE FROM Ventas WHERE IdVenta = pIdVenta;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_venta`(pIdVenta bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar una venta desde la base de datos.
    */
	SELECT	v.*, COALESCE(SUM(p.Monto),0) MontoPagado, tca.TipoComprobanteAfip, tt.TipoTributo
    FROM	Ventas v
    LEFT JOIN TiposComprobantesAfip tca USING(IdTipoComprobanteAfip)
    LEFT JOIN TiposTributos tt USING(IdTipoTributo)
            LEFT JOIN Pagos p USING(IdVenta)
    WHERE	IdVenta = pIdVenta;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_ventas`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_ventas`(pIdPuntoVenta bigint, pIdEmpresa int, pFechaDesde datetime,
pFechaHasta datetime, pIdCliente bigint, pTipo char(1), pIncluyeBajas char(1))
BEGIN
	/*
    * Permite buscar las ventas de un punto de venta, dado el tipo de venta (T para listar todas),
    * un cliente (0 para listar todos) y un rango de fechas (rango de fechas nulo, para listar todas).
    */
    IF (pFechaDesde IS NULL) THEN
        SET pFechaDesde = '1990-01-01 00:00:00';
	END IF;
    IF (pFechaHasta IS NULL) THEN
        SET pFechaHasta = NOW();
	END IF;
    SELECT	v.*, u.Usuario, (IF(c.Tipo = 'F',CONCAT(c.Apellidos,', ',c.Nombres),c.RazonSocial)) Cliente, tca.TipoComprobanteAfip, tt.TipoTributo,
            c.Observaciones ObservacionesCliente, ca.Canal
    FROM	Ventas v
    INNER JOIN Clientes c USING (IdCliente)
    INNER JOIN Canales ca USING (IdCanal)
    INNER JOIN Usuarios u USING (IdUsuario)
    LEFT JOIN TiposComprobantesAfip tca USING(IdTipoComprobanteAfip)
    LEFT JOIN TiposTributos tt USING(IdTipoTributo)
    WHERE	v.IdEmpresa = pIdEmpresa
            AND v.IdPuntoVenta = pIdPuntoVenta
            AND (v.IdCliente = pIdCliente OR pIdCliente = 0)
            AND (v.Tipo = pTipo OR pTipo = 'T')
            AND (v.Estado != 'B' OR pIncluyeBajas = 'S')
            AND (v.FechaAlta BETWEEN pFechaDesde AND pFechaHasta)
    ORDER BY v.Estado;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_venta`(pToken varchar(500), pIdVenta bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de baja una venta siempre y cuando no esté dado de baja ya.
    * Controlando que no tenga pagos o lineas ventas asosiadas, siempre y cuando
    * se encuentre en estado de edicion ademas que estar dentro del tiempo de anulacion de la empresa.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdEmpresa int;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'B') THEN
		SELECT 'La venta ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdPago FROM Pagos WHERE IdVenta = pIdVenta) THEN
		SELECT 'La venta indicada no se puede dar de baja, tiene pagos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no se puede dar de baja, tiene lineas de venta asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Ventas WHERE IdVenta = pIdVenta);
    IF NOT ((SELECT FechaAlta FROM Ventas WHERE IdVenta = pIdVenta) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1) ) ) THEN
        SELECT 'La venta supero el tiempo maximo de anulacion.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Audito Antes Ventas
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
		-- Da de baja la venta
		UPDATE Ventas SET Estado = 'B' WHERE IdVenta = pIdVenta;
		-- Audito Después Ventas
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;

		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_venta`(pToken varchar(500), pIdVenta bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado de la Venta a Activo siempre y cuando el estado actual sea Edicion.
    * Controlando que la venta cuente con al menos una linea de venta.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción interna. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controla Parámetros
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'A') THEN
		SELECT 'La venta ya está activa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
		SELECT 'La venta debe estar en edición para poder ser activada.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta) THEN
		SELECT 'La venta debe tener al menos una linea de venta para poder ser activada.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Audito Venta Antes
        INSERT INTO aud_Ventas
        SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'ACTIVAR','A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
        -- Activa Venta
        UPDATE Ventas 
        SET     Estado = 'A',
                Monto = (SELECT COALESCE(SUM(Precio*Cantidad),0) FROM LineasVenta WHERE IdVenta = pIdVenta)
        WHERE IdVenta = pIdVenta;
        -- Audito Venta Después
        INSERT INTO aud_Ventas
        SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'ACTIVAR','D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_alta_linea_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_linea_venta`(pToken varchar(500), pIdVenta bigint, pIdArticulo bigint, pCantidad decimal(12, 2),
pPrecio decimal(10, 2), pConsumeStock char(1), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	* Permite agregar una línea de venta a una venta que se encuentre en estado En edición.
    * Controlando si exite stock suficiente, si es que consume stock (pConsumeStock = 'S').
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pNroLinea smallint;
    DECLARE pFactor decimal(10, 4);
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pIdPuntoVenta bigint;
    DECLARE pIdListaPrecio bigint;
    DECLARE pIdCanal bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_linea_venta', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
        SELECT 'La venta no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    SELECT IdPuntoVenta, IdCanal INTO pIdPuntoVenta, pIdCanal FROM Ventas WHERE IdVenta = pIdVenta;
    IF(pConsumeStock = 'S') THEN
        IF ( (SELECT COALESCE(SUM(Cantidad),0) FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo ) + pCantidad
        > (SELECT Cantidad FROM ExistenciasConsolidadas WHERE IdArticulo = pIdArticulo AND IdPuntoVenta = pIdPuntoVenta AND IdCanal = pIdCanal)) THEN
            SELECT 'No hay stock suficiente.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        IF EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo) THEN
            -- Audito Antes la linea de venta
            INSERT INTO aud_LineasVenta
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'A', LineasVenta.*
            FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
            -- Modifica la linea de venta
            UPDATE LineasVenta SET Cantidad = Cantidad + pCantidad WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
            -- Audito Despues la linea de venta
            INSERT INTO aud_LineasVenta
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'D', LineasVenta.*
            FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
        ELSE
            SET pNroLinea = (SELECT COALESCE(MAX(NroLinea), 0) + 1 FROM LineasVenta WHERE IdVenta = pIdVenta);
            SET pIdListaPrecio = (SELECT c.IdListaPrecio FROM Ventas v
            INNER JOIN Clientes c USING(IdCliente) WHERE v.IdVenta = pIdVenta);
            SET pFactor = (SELECT (pPrecio/pa.PrecioVenta) FROM Articulos a 
            INNER JOIN PreciosArticulos pa USING(IdArticulo)
            WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio);
            -- Inserto la linea de venta
            INSERT INTO LineasVenta SELECT pIdVenta, pNroLinea, pIdArticulo, pCantidad, pPrecio, pFactor;
            -- Audito la linea de venta
            INSERT INTO aud_LineasVenta
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', LineasVenta.*
            FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
        END IF;

        IF (pConsumeStock = 'S') THEN
            SET pIdPuntoVenta = (SELECT IdPuntoVenta FROM Ventas WHERE IdVenta = pIdVenta);
            -- Modifico la existencia consolidada
            UPDATE ExistenciasConsolidadas SET Cantidad = Cantidad - pCantidad WHERE IdPuntoVenta = pIdPuntoVenta AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
        END IF;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borrar_linea_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_borrar_linea_venta`(pToken varchar(500), pIdVenta bigint, pIdArticulo bigint,
pConsumeStock char(1), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	* Permite quitar una línea de venta a una venta que se encuentre en estado En edición.
    * Devolviendo el stock, si es que consume stock (pConsumeStock = 'S').
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pIdPuntoVenta bigint;
    DECLARE pIdCanal bigint;
    DECLARE pNroLinea smallint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pCantidad decimal(12, 2);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borrar_linea_venta', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
        SELECT 'La venta no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF NOT EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo) THEN
        SELECT 'La línea indicada no existe.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito Antes
        INSERT INTO aud_LineasVenta
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', LineasVenta.*
        FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
        -- Borro
        SET pCantidad = (SELECT Cantidad FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo);
        DELETE FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;

        IF (pConsumeStock = 'S') THEN
            SELECT IdPuntoVenta, IdCanal INTO pIdPuntoVenta, pIdCanal FROM Ventas WHERE IdVenta = pIdVenta;
            -- Modifico la existencia consolidada
            UPDATE ExistenciasConsolidadas SET Cantidad = Cantidad + pCantidad WHERE IdPuntoVenta = pIdPuntoVenta AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
        END IF;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_lineas_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_lineas_venta`(pIdVenta bigint)
SALIR: BEGIN
    /*
	* Permite listar las líneas de una venta.
	*/
	SELECT lv.*, a.Articulo FROM LineasVenta lv INNER JOIN Articulos a USING(IdArticulo) WHERE lv.IdVenta = pIdVenta;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_pagos_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_pagos_venta`(pIdVenta bigint)
SALIR: BEGIN
    /*
	* Permite listar los pagos de una venta.
	*/
	SELECT p.*, mp.MedioPago, r.NroRemito, ch.NroCheque
    FROM Pagos p 
    INNER JOIN MediosPago mp USING(IdMedioPago)
    INNER JOIN Ventas v USING(IdVenta)
    INNER JOIN Clientes cl USING(IdCliente)
    LEFT JOIN  Remitos r ON p.IdRemito = r.IdRemito
    LEFT JOIN  Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE p.IdVenta = pIdVenta
    ORDER BY p.FechaAlta;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_medios_pago`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_medios_pago`()
SALIR: BEGIN
    /*
	* Permite listar los medios de pago activos.
	*/
	SELECT mp.* FROM MediosPago mp WHERE mp.Estado = 'A';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_tipos_comprobantes`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_tipos_comprobantes`()
SALIR: BEGIN
    /*
	* Permite listar los tipos de comprobantes activos.
	*/
	SELECT tc.* FROM TiposComprobante tc WHERE tc.Estado = 'A';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_devolucion_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_devolucion_venta`(pToken varchar(500), pIdVenta bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado de la Venta a baja y agregar existencias articulos vendidos.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdPuntoVenta bigint;
    DECLARE pIdCliente bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pIdIngreso bigint;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_devolucion_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'B') THEN
		SELECT 'La venta está dada de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdPago FROM Pagos WHERE IdVenta = pIdVenta) THEN
		SELECT 'La venta no se puede devolver, tiene pagos asosiados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pIdPuntoVenta = (SELECT IdPuntoVenta FROM Ventas WHERE IdVenta = pIdVenta);
        SET pIdCliente = (SELECT IdPuntoVenta FROM Ventas WHERE IdVenta = pIdVenta);

        -- Instancia un nuevo ingreso
		CALL xsp_alta_existencia(pIdUsuario, pIdPuntoVenta, pIdCliente, NULL, 'Devolucion de Venta', pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

        SET pIdIngreso = SUBSTRING_INDEX(pMensaje,'OK',-1);
        -- Instancia las lineas ingreso del ingreo
        INSERT INTO LineasIngreso SELECT pIdIngreso, lv.NroLinea, lv.IdArticulo, lv.Cantidad, lv.Precio 
        FROM LineasVenta lv WHERE IdVenta=pIdVenta;

        -- Audita las lineas del ingreso
        INSERT INTO aud_LineasIngreso
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        LineasIngreso.* FROM LineasIngreso WHERE IdIngreso = pIdIngreso;

        -- Activa el nuevo ingreso
        CALL xsp_activar_existencia(pIdUsuario, pIdIngreso, pIP, pUserAgent, pAplicacion, pMensaje);
		IF pMensaje != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Audito la Venta antes de darla de baja
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DEVOLUCION','A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
		-- Da de baja la venta
		UPDATE Ventas SET Estado = 'B' WHERE IdVenta = pIdVenta;
		-- Audito la Venta despues de darla de baja
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DEVOLUCION','D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;

		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_generar_comprobante_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_generar_comprobante_venta`(pIdVenta bigint)
SALIR: BEGIN
    /*
	* Permite obtener los datos para generar un comprobante de Venta.
	*/
	SELECT      v.*, c.*, JSON_ARRAYAGG(JSON_OBJECT(
                        'Articulo', a.Articulo,
                        'Codigo', a.Codigo,
                        'Cantidad', lv.Cantidad,
                        'Precio', lv.Precio,
                        'Subtotal', CAST(lv.Cantidad * lv.Precio AS DECIMAL(12, 2)),
                        'ImporteIVA', CAST(CAST(lv.Cantidad * lv.Precio AS DECIMAL(12, 2)) * (SELECT 1-1/(1+Porcentaje/100) FROM TiposIVA WHERE IdTipoIVA = a.IdTipoIVA) AS DECIMAL(12, 2)),
                        'IdTipoIVA', a.IdTipoIVA,
                        'Unidad', 7
                    )) Articulos, CAST(SUM(lv.Precio * lv.Cantidad) AS DECIMAL(12, 2)) Total,
                IF(c.Tipo = 'F', CONCAT(c.Apellidos, ', ', c.Nombres), c.RazonSocial) NombreCliente
    FROM        Ventas v
    INNER JOIN  Clientes c USING(IdCliente)
    INNER JOIN  LineasVenta lv USING(IdVenta)
    INNER JOIN  Articulos a USING(IdArticulo)
    WHERE       v.IdVenta = pIdVenta AND v.Estado = 'P'
    GROUP BY    v.IdVenta;
END$$
DELIMITER ;
