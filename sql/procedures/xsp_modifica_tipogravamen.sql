DROP PROCEDURE IF EXISTS `xsp_modifica_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_tipogravamen`(pToken varchar(500), pIdTipoGravemen tinyint, pTipoGravamen varchar(100),
pGravamen decimal(3,2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite modificar un tipo de gravamen controlando que el nombre del tipo de gravamen no exista ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_tipogravamen', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoGravemen IS NULL OR pIdTipoGravemen = 0) THEN
        SELECT 'Debe indicar el tipo de gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pTipoGravamen IS NULL OR pTipoGravamen = '') THEN
        SELECT 'Debe ingresar el tipo de gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pGravamen IS NULL OR pGravamen = 0) THEN
        SELECT 'Debe ingresar el gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen) THEN
		SELECT 'El tipo de gravamen que desea modificar no existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen AND FechaBaja IS NULL) THEN
		SELECT 'El tipo de gravamen que desea modificar se encuentra en baja.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE TipoGravamen = pTipoGravamen AND IdTipoGravemen!=pIdTipoGravemen) THEN
		SELECT 'El tipo de gravamen ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		-- Modifica
        UPDATE TiposGravamenes 
		SET		TipoGravamen=pTipoGravamen,
                Gravamen=pGravamen
		WHERE	IdTipoGravemen=pIdTipoGravemen;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;