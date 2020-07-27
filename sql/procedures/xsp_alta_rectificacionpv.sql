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