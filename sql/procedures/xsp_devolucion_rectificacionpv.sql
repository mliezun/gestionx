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