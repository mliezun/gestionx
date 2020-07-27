DROP PROCEDURE IF EXISTS `xsp_darbaja_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_tipogravamen`(pToken varchar(500), pIdTipoGravemen tinyint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de baja un tipo de gravamen controlando que no este dado de baja ya.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_tipogravamen', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoGravemen IS NULL OR pIdTipoGravemen = 0) THEN
        SELECT 'Debe indicar el tipo de gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen) THEN
		SELECT 'El tipo de gravamen que no existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen AND FechaBaja IS NOT NULL) THEN
		SELECT 'El tipo de gravamen que ya se encuentra en baja.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		-- Modifica
        UPDATE TiposGravamenes 
		SET		FechaBaja=NOW()
		WHERE	IdTipoGravemen=pIdTipoGravemen;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;