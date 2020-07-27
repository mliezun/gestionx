DROP PROCEDURE IF EXISTS `xsp_alta_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_tipogravamen`(pToken varchar(500), pTipoGravamen varchar(100),
pGravamen decimal(3,2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un tipo de gravamen controlando que el nombre del tipo de gravamen no exista ya.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdTipoGravemen tinyint;
    DECLARE pIdUsuario bigint;
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_tipogravamen', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
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
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE TipoGravamen = pTipoGravamen) THEN
		SELECT 'El tipo de gravamen ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
        INSERT INTO TiposGravamenes SELECT 0, pTipoGravamen, pGravamen, NULL;
        SET pIdTipoGravemen = LAST_INSERT_ID();
        
        SELECT CONCAT('OK', pIdTipoGravemen) Mensaje;
	COMMIT;
END$$

DELIMITER ;