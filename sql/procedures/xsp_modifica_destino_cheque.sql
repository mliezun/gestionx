DROP PROCEDURE IF EXISTS `xsp_modifica_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_destino_cheque`(pToken varchar(500), pIdDestinoCheque smallint,
pDestino varchar(100), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un DestinoCheque.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario, pIdEmpresa bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_destino_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdDestinoCheque IS NULL OR pIdDestinoCheque = 0) THEN
        SELECT 'Debe indicar el destino.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDestino IS NULL OR TRIM(pDestino) = '') THEN
        SELECT 'Debe indicar el nombre del destino.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	-- Control de Parametros incorrectos
    IF EXISTS(SELECT IdDestinoCheque FROM DestinosCheque WHERE Destino = pDestino AND IdDestinoCheque != pIdDestinoCheque AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe otro destino con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_DestinosCheque
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
        -- Modifica
        UPDATE DestinosCheque 
		SET	   Destino = pDestino
		WHERE  IdDestinoCheque=pIdDestinoCheque;
		-- Despues
        INSERT INTO aud_DestinosCheque
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;