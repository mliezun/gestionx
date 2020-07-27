DROP PROCEDURE IF EXISTS `xsp_modificar_pago_proveedor_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_proveedor_cheque`(pToken varchar(500), pIdPago bigint,
pFechaDebe datetime, pFechaPago datetime, pIdCheque bigint, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago a un proveedor, utilizando un cheque.
    * Si se cambia de cheque se controla que el estado actual del nuevo cheque
    * sea Disponible y cambia su estado a Utilizado, a si mismo el estado del
    * antiguo cheque vuelve a Disponible.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pIdChequeAntiguo bigint;
    DECLARE pMensaje text;
    DECLARE pMontoPago decimal(12, 2);
    DECLARE pDiferencia decimal(12, 2);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_proveedor_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdPago IS NULL OR pIdPago = 0) THEN
        SELECT 'Debe indicar el pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCheque IS NULL OR pIdCheque = 0) THEN
        SELECT 'Debe ingresar el cheque.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdPago FROM Pagos WHERE IdPago = pIdPago) THEN
		SELECT 'El pago indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT IdCheque FROM Pagos WHERE IdPago = pIdPago)THEN
        SELECT 'El pago indicado no es de tipo cheque.' Mensaje;
        LEAVE SALIR;
    END IF;
    SET pIdChequeAntiguo = (SELECT IdCheque FROM Pagos WHERE IdPago = pIdPago);
    IF(pIdChequeAntiguo != pIdCheque)THEN
        IF NOT EXISTS( SELECT IdCheque FROM Cheques WHERE IdCheque = pIdCheque AND Estado = 'D') THEN
            SELECT 'El cheque no existe, o no se encuentra disponible para el uso.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pMontoPago = (SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque);
        SET pDiferencia = 0;
        IF(pIdChequeAntiguo != pIdCheque)THEN
            -- Audito Antes el Cheque Antiguo
            INSERT INTO aud_Cheques
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_PAGO', 'A',
            Cheques.* FROM Cheques WHERE IdCheque = pIdChequeAntiguo;
            -- Modifica Cheque Antiguo
            UPDATE  Cheques 
            SET	    Estado='D'
            WHERE   IdCheque=pIdChequeAntiguo;
            -- Audito Despues el Cheque Antiguo
            INSERT INTO aud_Cheques
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_PAGO', 'D',
            Cheques.* FROM Cheques WHERE IdCheque = pIdChequeAntiguo;

            -- Audito Antes el Cheque
            INSERT INTO aud_Cheques
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'UTILIZA', 'A',
            Cheques.* FROM Cheques WHERE IdCheque = pIdCheque;
            -- Modifica Cheque
            UPDATE  Cheques 
            SET	    Estado='U'
            WHERE   IdCheque=pIdCheque;
            -- Audito Despues el Cheque
            INSERT INTO aud_Cheques
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'UTILIZA', 'D',
            Cheques.* FROM Cheques WHERE IdCheque = pIdCheque;

            SET pDiferencia = pMontoPago - (SELECT Importe FROM Cheques WHERE IdCheque = pIdChequeAntiguo);
        END IF;

        -- Audito el pago Antes
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Modifica el pago
        UPDATE  Pagos
        SET     IdCheque = pIdCheque,
                Monto = pMontoPago,
                Observaciones = pObservacionesPago
        WHERE   IdPago = pIdPago;
        -- Audito el pago Despues
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- Modifica la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			(SELECT Codigo FROM Pagos WHERE IdPago = pIdPago),
			'P',
			pDiferencia,
			'Modifica Pago al Proveedor',
			NULL,
			pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;