DROP PROCEDURE IF EXISTS `xsp_borra_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_canal`(pToken varchar(500), pIdCanal bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un Canal existente controlando que no existan remitos,
    * ventas o rectificaciones asociadas.
    * Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_canal', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCanal FROM Canales WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdVenta FROM Ventas WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no se puede borrar, tiene ventas asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdRemito FROM Remitos WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no se puede borrar, tiene remitos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no se puede borrar, tiene rectificaciones asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        
        -- Borro las existencias consolidadas
        DELETE FROM ExistenciasConsolidadas WHERE IdCanal = pIdCanal;

        -- Audito
        INSERT INTO aud_Canales
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
        
        -- Borro
        DELETE FROM Canales WHERE IdCanal = pIdCanal;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;