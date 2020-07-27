DROP PROCEDURE IF EXISTS `xsp_darbaja_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_puntoventa`(pToken varchar(500), pIdPuntoVenta bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del PuntoVenta a Baja siempre y cuando no esté dado de baja ya.
	Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta AND Estado = 'B') THEN
		SELECT 'El punto de venta ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
		-- Da de baja
		UPDATE PuntosVenta SET Estado = 'B' WHERE IdPuntoVenta = pIdPuntoVenta;
		-- Después
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;