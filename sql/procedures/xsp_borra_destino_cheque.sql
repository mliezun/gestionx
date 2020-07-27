DROP PROCEDURE IF EXISTS `xsp_borra_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_destino_cheque`(pToken varchar(500), pIdDestinoCheque smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un destino controlando que no tenga cheques asosiados.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_destino_cheque', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdDestinoCheque FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque) THEN
        SELECT 'El destino indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdCheque FROM Cheques WHERE IdDestinoCheque = pIdDestinoCheque) THEN
        SELECT 'El destino indicado no se puede borrar, tiene cheques asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_DestinosCheque
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;

        -- Borro
        DELETE FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;