DROP PROCEDURE IF EXISTS `xsp_alta_rectificacionpv`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_rectificacionpv`(pToken varchar(500), pIdEmpresa int, pIdPuntoVentaOrigen bigint,
pIdPuntoVentaDestino bigint, pIdArticulo bigint, pIdCanal bigint, pCantidad decimal(12,2), pObservaciones varchar(255),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta una Rectificacion de Punto de Venta, incrementando o decrementando la cantidad
	* de existencias de un articulo en un punto de venta con la posibilidad de que se aplique
	* la accion contraria inmediatamente en otro punto de venta de la misma empresa
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdRectificacionPV bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_rectificacionpv', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdPuntoVentaOrigen IS NULL OR pIdPuntoVentaOrigen = 0) THEN
        SELECT 'Debe ingresar el punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdArticulo IS NULL OR pIdArticulo = 0) THEN
        SELECT 'Debe ingresar el articulo.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdCanal IS NULL OR pIdCanal = 0) THEN
        SELECT 'Debe ingresar el canal.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pCantidad IS NULL OR pCantidad = 0) THEN
        SELECT 'Debe ingresar la cantidad de articulos.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT PuntoVenta FROM PuntosVenta WHERE IdPuntoVenta=pIdPuntoVentaOrigen) THEN
		SELECT 'Debe existir el punto de venta de origen.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF ((SELECT IdEmpresa FROM PuntosVenta WHERE IdPuntoVenta=pIdPuntoVentaOrigen) != pIdEmpresa) THEN
		SELECT 'El punto de venta de origen debe pertenecer a la empresa.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF (pIdPuntoVentaDestino IS NOT NULL AND pIdPuntoVentaDestino != 0) THEN
		IF NOT EXISTS(SELECT PuntoVenta FROM PuntosVenta WHERE IdPuntoVenta=pIdPuntoVentaDestino) THEN
			SELECT 'Debe existir el punto de venta de destino.' Mensaje;
			LEAVE SALIR;
		END IF;
		IF ((SELECT IdEmpresa FROM PuntosVenta WHERE IdPuntoVenta=pIdPuntoVentaDestino) != pIdEmpresa) THEN
			SELECT 'El punto de venta de destino debe pertenecer a la empresa.' Mensaje;
			LEAVE SALIR;
		END IF;
		IF ((SELECT IdEmpresa FROM PuntosVenta WHERE IdPuntoVenta=pIdPuntoVentaOrigen) != 
		(SELECT IdEmpresa FROM PuntosVenta WHERE IdPuntoVenta=pIdPuntoVentaDestino)) THEN
			SELECT 'Los puntos de venta no pertenecen a la misma empresa.' Mensaje;
			LEAVE SALIR;
		END IF;
		IF (ABS(pCantidad) > (SELECT Cantidad FROM ExistenciasConsolidadas 
			WHERE IdArticulo = pIdArticulo AND IdPuntoVenta = IF(pCantidad < 0, pIdPuntoVentaDestino, pIdPuntoVentaOrigen) AND IdCanal = pIdCanal)) THEN
			SELECT 'No hay stock suficiente en el punto de venta de origen.' Mensaje;
			LEAVE SALIR;
		END IF;
	ELSE
		IF (pCantidad < 0 AND ABS(pCantidad) > (SELECT Cantidad FROM ExistenciasConsolidadas 
			WHERE IdArticulo = pIdArticulo AND IdPuntoVenta = pIdPuntoVentaOrigen AND IdCanal = pIdCanal)) THEN
			SELECT 'No hay stock suficiente en el punto de venta de origen.' Mensaje;
			LEAVE SALIR;
		END IF;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO RectificacionesPV
		SELECT 0, pIdArticulo, pIdPuntoVentaOrigen, IF(pIdPuntoVentaDestino = 0, NULL, pIdPuntoVentaDestino),
		pIdEmpresa, pIdUsuario, pIdCanal, pCantidad, NOW(), 'P', pObservaciones;
		SET pIdRectificacionPV = LAST_INSERT_ID();
		-- Audito
		INSERT INTO aud_RectificacionesPV
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
		RectificacionesPV.* FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;

		-- Modifico las existencias consolidadas
		IF (pIdPuntoVentaDestino IS NULL OR pIdPuntoVentaDestino=0) THEN
			UPDATE ExistenciasConsolidadas SET Cantidad = Cantidad + pCantidad WHERE IdPuntoVenta = pIdPuntoVentaOrigen AND IdArticulo = pIdArticulo  AND IdCanal = pIdCanal;
		ELSE
			UPDATE ExistenciasConsolidadas SET Cantidad = Cantidad - pCantidad WHERE IdPuntoVenta = pIdPuntoVentaOrigen AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
			-- Esto se hace en la confirmacion
			-- UPDATE ExistenciasConsolidadas SET Cantidad = Cantidad + pCantidad WHERE IdPuntoVenta = pIdPuntoVentaDestino AND IdArticulo = pIdArticulo  AND IdCanal = pIdCanal;
		END IF;
        
        SELECT CONCAT('OK', pIdRectificacionPV) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_rectificacionpv`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_rectificacionpv`(pToken varchar(500), pIdRectificacionPV bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite borrar una Rectificacion de Punto de Venta, dentro del tiempo de anulacion.
	* Siempre y cuando se encuentre pendiente de confirmación
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pIdPuntoVentaOrigen bigint;
	DECLARE pIdArticulo bigint;
	DECLARE pIdCanal bigint;
	DECLARE pIdEmpresa int;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pCantidad decimal(12,2);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_rectificacionpv', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdRectificacionPV IS NULL OR pIdRectificacionPV = 0) THEN
        SELECT 'Debe ingresar la rectificacion del punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV=pIdRectificacionPV) THEN
		SELECT 'Debe existir la rectificacion del punto de venta.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV=pIdRectificacionPV AND Estado = 'C') THEN
		SELECT 'No se puede anular una rectificacion ya confirmada.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
	IF NOT((SELECT FechaAlta FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1)) ) THEN
        SELECT 'La venta supero el tiempo maximo de anulacion.' Mensaje;
        LEAVE SALIR;
    END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		SET pIdPuntoVentaOrigen = (SELECT IdPuntoVentaOrigen FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdArticulo = (SELECT IdArticulo FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdCanal = (SELECT IdCanal FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pCantidad = (SELECT Cantidad FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		
		-- Modifico las existencias consolidadas
		UPDATE ExistenciasConsolidadas
		SET Cantidad = Cantidad + pCantidad
		WHERE IdPuntoVenta = pIdPuntoVentaOrigen AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
		
		-- Audito
		INSERT INTO aud_RectificacionesPV
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B',
		RectificacionesPV.* FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;
        
		-- Borra Rectificacion
        DELETE FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;
        
        SELECT CONCAT('OK') Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_rectificacionespv`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_rectificacionespv`(pIdEmpresa int, pIdPuntoVenta bigint, pIdCanal bigint, pCadena varchar(100), pIncluyeBajas char(1))
SALIR: BEGIN
	/*
	Permite buscar rectificaciones dentro de un punto de venta de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas. Si pIdPuntoVenta = 0 lista todas las rectficaciones activos de una empresa.
	*/
    SELECT  r.*, a.Articulo, a.Codigo, pr.Proveedor, po.PuntoVenta PuntoVentaOrigen, pd.PuntoVenta PuntoVentaDestino, c.Canal
    FROM    RectificacionesPV r
	INNER JOIN Articulos a USING(IdArticulo)
	INNER JOIN Proveedores pr USING(IdProveedor)
	INNER JOIN Canales c USING(IdCanal)
    INNER JOIN PuntosVenta po ON r.IdPuntoVentaOrigen = po.IdPuntoVenta
    INNER JOIN PuntosVenta pd ON r.IdPuntoVentaDestino = pd.IdPuntoVenta
    WHERE   r.IdEmpresa = pIdEmpresa
			AND (r.IdCanal = pIdCanal OR pIdCanal = 0)
			AND (pIdPuntoVenta = r.IdPuntoVentaDestino OR pIdPuntoVenta = r.IdPuntoVentaOrigen OR pIdPuntoVenta = 0)
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%')
                )
            AND (pIncluyeBajas = 'S' OR r.Estado = 'P')
    GROUP BY r.IdRectificacionPV
	ORDER BY r.Estado;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_confirmar_rectificacionpv`;
DELIMITER $$
CREATE PROCEDURE `xsp_confirmar_rectificacionpv`(pToken varchar(500), pIdRectificacionPV bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite confirmar una rectificacion, solamente si esta se encuentra pendiente de confirmación.
	Añade las existencias consolidadas en el destino.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdPuntoVentaDestino bigint;
	DECLARE pIdArticulo bigint;
	DECLARE pIdCanal bigint;
	DECLARE pCantidad decimal(12,2);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_confirmar_rectificacionpv', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV) THEN
        SELECT 'La Rectificación indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV AND Estado = 'P') THEN
        SELECT 'La Rectificación indicada no se encuentra en estado Pendiente.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita Antes
        INSERT INTO aud_RectificacionesPV
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'CONFIRMAR', 'A',
		RectificacionesPV.* FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;

        -- Confirmo Rectificacion
        UPDATE  RectificacionesPV
        SET     Estado = 'C'
        WHERE   IdRectificacionPV = pIdRectificacionPV;

        -- Audita Despues
        INSERT INTO aud_RectificacionesPV
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'CONFIRMAR', 'D',
		RectificacionesPV.* FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;

		-- Modifico las existencias consolidadas
        SET pIdPuntoVentaDestino = (SELECT IdPuntoVentaDestino FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdArticulo = (SELECT IdArticulo FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdCanal = (SELECT IdCanal FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pCantidad = (SELECT Cantidad FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		IF (pIdPuntoVentaDestino IS NOT NULL) THEN
			UPDATE ExistenciasConsolidadas
			SET Cantidad = Cantidad + pCantidad
			WHERE IdPuntoVenta = pIdPuntoVentaDestino AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
		END IF;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_devolucion_rectificacionpv`;
DELIMITER $$
CREATE PROCEDURE `xsp_devolucion_rectificacionpv`(pToken varchar(500), pIdRectificacionPV bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite devolver una rectificacion, solamente si esta se encuentra pendiente de confirmación.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdArticulo bigint;
	DECLARE pIdCanal bigint;
	DECLARE pIdPuntoVentaOrigen bigint;
	DECLARE pIdPuntoVentaDestino bigint;
	DECLARE pEstado char(1);
	DECLARE pCantidad decimal(12,2);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_devolucion_rectificacionpv', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV) THEN
        SELECT 'La Rectificación indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV AND Estado = 'B') THEN
        SELECT 'La Rectificación indicada ya se encuentra dado de Baja.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS (SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV AND Estado = 'C') THEN
        SELECT 'La Rectificación indicada ya fue Confirmada.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

		-- Modifico las existencias consolidadas
		SET pIdPuntoVentaOrigen = (SELECT IdPuntoVentaOrigen FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
        SET pIdPuntoVentaDestino = (SELECT IdPuntoVentaDestino FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdArticulo = (SELECT IdArticulo FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdCanal = (SELECT IdCanal FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pEstado = (SELECT Estado FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pCantidad = (SELECT Cantidad FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		
		UPDATE ExistenciasConsolidadas
		SET Cantidad = Cantidad + pCantidad
		WHERE IdPuntoVenta = pIdPuntoVentaOrigen AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
		
		IF (pIdPuntoVentaDestino IS NOT NULL AND pEstado = 'C' ) THEN
			UPDATE ExistenciasConsolidadas
			SET Cantidad = Cantidad - pCantidad
			WHERE IdPuntoVenta = pIdPuntoVentaDestino AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
		END IF;

		-- Audita Antes
        INSERT INTO aud_RectificacionesPV
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'CONFIRMAR', 'A',
		RectificacionesPV.* FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;

        -- Baja Rectificacion
        UPDATE  RectificacionesPV
        SET     Estado = 'B'
        WHERE   IdRectificacionPV = pIdRectificacionPV;

        -- Audita Despues
        INSERT INTO aud_RectificacionesPV
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'CONFIRMAR', 'D',
		RectificacionesPV.* FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;
