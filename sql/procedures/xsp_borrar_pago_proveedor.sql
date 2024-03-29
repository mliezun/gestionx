DROP PROCEDURE IF EXISTS `xsp_borrar_pago_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_borrar_pago_proveedor`(pToken varchar(500), pIdPago bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite borrar un pago a un Proveedor existente.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdCheque bigint;
    DECLARE pIdProveedor bigint;
    DECLARE pMontoPago decimal(12, 2);
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pDescripcion text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_borrar_pago_proveedor', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SELECT      p.Monto, p.Codigo, mp.MedioPago
        INTO        pMontoPago, pIdProveedor, pDescripcion
        FROM        Pagos p
        INNER JOIN  MediosPago mp USING(IdMedioPago)
        WHERE       p.IdPago = pIdPago;

        IF EXISTS(SELECT IdCheque FROM Pagos WHERE IdCheque IS NOT NULL AND IdPago = pIdPago) THEN
            SET pIdCheque = (SELECT IdCheque FROM Pagos WHERE IdPago = pIdPago);
            -- Audito Antes el Cheque
            INSERT INTO aud_Cheques
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_PAGO', 'A',
            Cheques.* FROM Cheques WHERE IdCheque = pIdCheque;
            -- Modifica Cheque
            UPDATE  Cheques 
            SET	    Estado='D'
            WHERE   IdCheque=pIdCheque;
            -- Audito Despues el Cheque
            INSERT INTO aud_Cheques
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_PAGO', 'D',
            Cheques.* FROM Cheques WHERE IdCheque = pIdCheque;
        END IF;

        -- Aumenta la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			pIdProveedor, 'P', - pMontoPago,
			'Borra Pago al Proveedor', pDescripcion,
			pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Audito Pago
		INSERT INTO aud_Pagos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Borra pago
        DELETE FROM Pagos WHERE IdPago = pIdPago;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;