DROP PROCEDURE IF EXISTS `xsp_inicio_darbaja_suscripcion`;
DELIMITER $$
CREATE PROCEDURE `xsp_inicio_darbaja_suscripcion`(pToken varchar(128), pIdSuscripcion bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
    /*
    Coloca en estado 'F' (Pendiende de cancelación), a la suscripcion indicada.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pMensaje varchar(100);
    DECLARE pIdEmpresa bigint;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
	END;

    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_inicio_darbaja_suscripcion', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE PROC;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
    
    IF NOT EXISTS (SELECT IdSuscripcion FROM Suscripciones WHERE IdUsuario = pIdEmpresa AND IdSuscripcion = pIdSuscripcion) THEN
		SELECT 'SUSCRNOTFOUND' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;   
        
        UPDATE  Suscripciones
        SET     Estado = 'F'
        WHERE   IdSuscripcion = pIdSuscripcion;
        
            
        SELECT 'OK' Mensaje;
	COMMIT;
END $$

DELIMITER ;