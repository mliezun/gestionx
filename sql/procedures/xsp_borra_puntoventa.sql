DROP PROCEDURE IF EXISTS `xsp_borra_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_puntoventa`(pToken varchar(500), pIdPuntoVenta bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite borrar un PuntoVenta existente controlando que no existan ventas,
	rectificaciones pv, ingresos o existencias cosolidadas asociadas.
	Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM Ventas WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen ventas asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdPuntoVentaOrigen = pIdPuntoVenta OR IdPuntoVentaDestino = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen rectificaciones pv asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM Ingresos WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen ingresos asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM ExistenciasConsolidadas WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen existencias consolidadas asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM UsuariosPuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen usuarios asociados.' Mensaje;
		LEAVE SALIR;
	END IF;
	-- Borra el puntoventa
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Audito
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
        -- Borra rol
        DELETE FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;