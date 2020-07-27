DROP PROCEDURE IF EXISTS `xsp_activar_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_destino_cheque`(pToken varchar(500), pIdDestinoCheque smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado del Destino de cheque a Activo siempre y cuando no esté activo ya.
    * Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_destino_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque AND Estado = 'A') THEN
		SELECT 'El Destino ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		-- Activa Destino
		UPDATE DestinosCheque SET Estado = 'A' WHERE IdDestinoCheque = pIdDestinoCheque;
		-- Después
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;