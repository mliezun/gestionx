DROP PROCEDURE IF EXISTS `xsp_borrar_pago_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_borrar_pago_venta`(pToken varchar(500), pIdPago bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite borrar un Pago existente. Si la venta ya estaba pagada
    * cambia su estado a Activo.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdCheque bigint;
    DECLARE pIdRemito, pIdIngreso bigint;
    DECLARE pIdVenta bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borrar_pago_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

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

        -- Mercaderia
        IF EXISTS(SELECT 1 FROM Pagos WHERE IdMedioPago = 2 AND IdPago = pIdPago) THEN
            SET pIdIngreso = (SELECT Datos->>'$.IdIngreso' FROM Pagos WHERE IdPago = pIdPago);
            CALL xsp_darbaja_existencia(pIdUsuario, pIdIngreso, pIP, pUserAgent, pAplicacion, pMensaje);
            IF pMensaje IS NULL OR pMensaje != 'OK' THEN
                SELECT COALESCE(pMensaje, 'Error en la transacción interna. Contáctese con el administrador.') Mensaje;
                ROLLBACK;
                LEAVE SALIR;
            END IF;
        END IF;

        -- -- Audito Comprobante
		-- INSERT INTO aud_Comprobantes
		-- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;
        -- -- Borra Comprobante
        -- DELETE FROM Comprobantes WHERE IdPago = pIdPago;

        SELECT      p.Monto, p.Codigo, mp.MedioPago
        INTO        pMontoPago, pIdVenta, pDescripcion
        FROM        Pagos p
        INNER JOIN  MediosPago mp USING(IdMedioPago)
        WHERE       p.IdPago = pIdPago;

        IF EXISTS( SELECT IdVenta FROM Ventas WHERE IdVenta=pIdVenta AND Estado='P')THEN
            -- Audito Antes la Venta
            INSERT INTO aud_Ventas
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_PAGO', 'A',
            Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
            -- Modifica Venta
            UPDATE  Ventas
            SET	    Estado='A'
            WHERE   IdVenta=pIdVenta;
            -- Audito Despues la Venta
            INSERT INTO aud_Ventas
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_PAGO', 'D',
            Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
        END IF;

        -- Aumenta la deuda del Cliente
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			(SELECT IdCliente FROM Ventas WHERE IdVenta = pIdVenta), 'C', pMontoPago,
			'Borra Pago de Venta', pDescripcion,
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