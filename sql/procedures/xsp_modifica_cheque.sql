DROP PROCEDURE IF EXISTS `xsp_modifica_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_cheque`(pToken varchar(500), pIdCheque bigint,
pIdCliente bigint, pIdBanco smallint, pIdDestinoCheque smallint, pNroCheque bigint, pImporte decimal(12,2),
pFechaVencimiento date, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un Cheque.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCheque IS NULL OR pIdCheque = 0) THEN
        SELECT 'Debe indicar el cheque.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdCheque FROM Cheques WHERE IdCheque = pIdCheque AND Estado = 'D') THEN
		SELECT 'El cheque indicado no existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_Cheques
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Cheques.*
        FROM Cheques WHERE IdCheque = pIdCheque;
        -- Modifica
        UPDATE  Cheques 
		SET	    IdCliente=pIdCliente,
                IdBanco=pIdBanco,
                IdDestinoCheque=pIdDestinoCheque,
                NroCheque=pNroCheque,
                Importe=pImporte,
                FechaVencimiento=pFechaVencimiento,
                Obversaciones=pObservaciones
		WHERE   IdCheque=pIdCheque;
		-- Despues
        INSERT INTO aud_Cheques
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Cheques.*
        FROM Cheques WHERE IdCheque = pIdCheque;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;