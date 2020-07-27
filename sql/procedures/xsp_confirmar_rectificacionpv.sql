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