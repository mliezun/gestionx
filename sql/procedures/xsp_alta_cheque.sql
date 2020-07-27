DROP PROCEDURE IF EXISTS `xsp_alta_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_cheque`(pToken varchar(500), pIdCliente bigint, pIdBanco smallint, pIdDestinoCheque smallint,
pNroCheque bigint, pImporte decimal(12,2), pFechaVencimiento date, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Cheque.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdCheque bigint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdBanco FROM Bancos WHERE IdBanco = pIdBanco AND Estado = 'A') THEN
		SELECT 'No existe el banco indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    IF (pIdDestinoCheque IS NOT NULL) THEN
        IF NOT EXISTS(SELECT IdDestinoCheque FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque AND Estado = 'A') THEN
            SELECT 'No existe el destino indicado.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Inserta
        INSERT INTO Cheques SELECT 0, pIdCliente, pIdBanco, pIdDestinoCheque, pNroCheque, pImporte, NOW(), pFechaVencimiento, 'D', pObservaciones;
        SET pIdCheque = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_Cheques
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Cheques.* FROM Cheques WHERE IdCheque = pIdCheque;
        
        SELECT CONCAT('OK', pIdCheque) Mensaje;
	COMMIT;
END$$

DELIMITER ;