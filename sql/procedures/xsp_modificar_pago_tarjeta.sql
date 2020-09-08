DROP PROCEDURE IF EXISTS `xsp_modificar_pago_tarjeta`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_tarjeta`(pToken varchar(500), pIdPago bigint, pMontoPago decimal(12,2),
pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pNroTarjeta char(16), pMesVencimiento char(2), pAnioVencimiento char(2), pCCV char(3),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago de una venta, utilizando una tarjeta.
    * Controlando que los datos de la tarjeta sean validos.
    * Si con esta modificacion del pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario, pIdVenta, pIdCliente bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje, pDescripcion text;
    DECLARE pDiferencia, pMontoAnterior decimal(12, 2);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_tarjeta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdPago IS NULL OR pIdPago = 0) THEN
        SELECT 'Debe indicar el pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- IF (pIdTipoComprobante IS NULL OR pIdTipoComprobante = 0) THEN
    --     SELECT 'Debe indicar el tipo de comprobante.' Mensaje;
    --     LEAVE SALIR;
	-- END IF;
    IF (pNroTarjeta IS NULL) THEN
        SELECT 'Debe indicar el numero de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;
    /*IF (pMesVencimiento IS NULL OR CHAR_LENGTH(pMesVencimiento) != 2) THEN
        SELECT 'Debe indicar el mes de vencimiento de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pAnioVencimiento IS NULL OR CHAR_LENGTH(pAnioVencimiento) != 2) THEN
        SELECT 'Debe indicar el año de vencimiento de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pCCV IS NULL OR CHAR_LENGTH(pCCV) != 3) THEN
        SELECT 'Debe indicar el codigo de verificacion de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;*/
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe indicar la monto del pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdPago FROM Pagos WHERE IdPago = pIdPago) THEN
		SELECT 'El pago indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- IF NOT EXISTS(SELECT Estado FROM TiposComprobante WHERE IdTipoComprobante = pIdTipoComprobante AND Estado = 'A') THEN
	-- 	SELECT 'El tipo de comprobante no se encuentra activo.' Mensaje;
    --     LEAVE SALIR;
	-- END IF;
    IF NOT EXISTS(SELECT NroTarjeta FROM Pagos WHERE IdPago = pIdPago AND IdRemito IS NULL AND IdCheque IS NULL)THEN
        SELECT 'El pago indicado no es de tipo tarjeta.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    SET pIdVenta = (SELECT Codigo FROM Pagos WHERE IdPago = pIdPago);
    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V' AND IdPago != pIdPago)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del cheque supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V')
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SELECT      p.Monto, v.IdCliente, mp.MedioPago
        INTO        pMontoAnterior, pIdCliente, pDescripcion
        FROM        Ventas v
        INNER JOIN  Pagos p ON p.Codigo = v.IdVenta AND Tipo = 'V'
        INNER JOIN  MediosPago mp USING(IdMedioPago)
        WHERE       p.IdPago = pIdPago;

        SET pDiferencia = pMontoPago - pMontoAnterior;
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V' AND IdPago != pIdPago)
        < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
            SET pMotivo='MODIFICA';
        ELSE
            SET pMotivo='PAGA';
            -- Audito Antes la Venta
            INSERT INTO aud_Ventas
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
            -- Modifica Venta
            UPDATE  Ventas
            SET	    Estado='P'
            WHERE   IdVenta=pIdVenta;
            -- Audito Despues la Venta
            INSERT INTO aud_Ventas
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
        END IF;

        -- Audito el pago Antes
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'A',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Modifica el pago
        UPDATE Pagos
        SET Monto = pMontoPago,
            NroTarjeta=pNroTarjeta,
            MesVencimiento = pMesVencimiento,
            AnioVencimiento = pAnioVencimiento,
            CCV = pCCV,
            Observaciones=pObservacionesPago
        WHERE IdPago=pIdPago;
        -- Audito el pago Despues
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'D',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- Disminuye la deuda del Cliente
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			pIdCliente, 'C', - pDiferencia,
			'Modifica Pago de Venta', pDescripcion,
			pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

        -- -- Audito el comprobante Antes
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_PAGO', 'A',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;
        -- -- Modifica el comprobante
        -- UPDATE Comprobantes
        -- SET IdTipoComprobante = pIdTipoComprobante
        -- WHERE IdPago = pIdPago;
        -- -- Audito el comprobante Despues
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_PAGO', 'D',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;

        IF EXISTS (SELECT IdPago FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V' AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V' AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE  Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   Codigo = pIdVenta AND Tipo = 'V' AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V' AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;