DROP PROCEDURE IF EXISTS `xsp_pagar_venta_mercaderia`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_venta_mercaderia`(pToken varchar(500), pIdVenta bigint, pIdMedioPago smallint,
pFechaDebe datetime, pFechaPago datetime, pIdRemito bigint, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago de una venta, utilizando mercaderia asosiada a un Remito.
    * Siempre y cuando el estado actual de la venta sea Activo y el del remito sea Activo.
    * Si con este nuevo pago se termina de pagar la venta, cambiar el estado de la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdPago bigint;
    DECLARE pIdCliente bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMontoPago decimal(12,2);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_venta_mercaderia', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- IF (pIdTipoComprobante IS NULL OR pIdTipoComprobante = 0) THEN
    --     SELECT 'Debe indicar el tipo de comprobante.' Mensaje;
    --     LEAVE SALIR;
	-- END IF;
    IF (pIdMedioPago IS NULL OR pIdMedioPago = 0) THEN
        SELECT 'Debe indicar la medio de pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdRemito IS NULL OR pIdRemito = 0) THEN
        SELECT 'Debe ingresar el remito.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'A') THEN
		SELECT 'La venta no se encuentra activa.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- IF NOT EXISTS(SELECT Estado FROM TiposComprobante WHERE IdTipoComprobante = pIdTipoComprobante AND Estado = 'A') THEN
	-- 	SELECT 'El tipo de comprobante no se encuentra activo.' Mensaje;
    --     LEAVE SALIR;
	-- END IF;
    IF NOT EXISTS(SELECT Estado FROM MediosPago WHERE IdMedioPago = pIdMedioPago AND Estado = 'A') THEN
		SELECT 'El medio de pago no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'A') THEN
        SELECT 'El remito no existe, o no se encuentra activo.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF NOT EXISTS(SELECT IdCliente FROM Remitos WHERE IdRemito = pIdRemito AND IdCliente IS NULL) THEN
        SELECT 'El remito ya esta utilizado en otro pago.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    SET pMontoPago = (SELECT COALESCE(SUM(li.Cantidad*li.Precio),0) FROM Ingresos i 
        INNER JOIN LineasIngreso li USING(IdIngreso) WHERE i.IdRemito = pIdRemito);

    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V')
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del pago supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;
    
    -- IF((SELECT COALESCE(SUM(li.Cantidad*li.Precio),0) FROM Ingresos i 
    --     INNER JOIN LineasIngreso li USING(IdIngreso) WHERE i.IdRemito = pIdRemito)
    -- + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V')
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V')
        < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
            SET pMotivo='ALTA';
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
        SET pIdCliente = (SELECT IdCliente FROM Ventas WHERE IdVenta = pIdVenta);

        -- Antes Remito
        INSERT INTO aud_Remitos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
        -- Modifica Remito
        UPDATE Remitos
		SET		IdCliente=pIdCliente
		WHERE	IdRemito=pIdRemito;
		-- Despues Remito
        INSERT INTO aud_Remitos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdVenta, 'V', pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, pIdRemito, NULL, NULL, NULL, NULL, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- Disminuye la deuda del Cliente
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			(SELECT IdCliente FROM Ventas WHERE IdVenta = pIdVenta),
			'C',
			pMontoPago,
			'Pago de Venta',
			NULL,
			pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

        -- -- Inserto el comprobante
        -- INSERT INTO Comprobantes VALUES (pIdPago, pIdTipoComprobante,
        -- CONCAT('/Rutas_Comprobantes/Comp',pIdPago,'.pdf'), NOW());
        -- -- Audito el comprobante
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;

        IF EXISTS (SELECT IdPago FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V' AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V' AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
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