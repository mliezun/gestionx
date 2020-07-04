DROP PROCEDURE IF EXISTS `xsp_buscar_pagos_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_pagos_venta`(pIdVenta bigint, pIdMedioPago SMALLINT)
SALIR: BEGIN
    /*
	* Permite buscar los pagos de una venta. Se puede filtrar por medio de pago (0 para listar todos)
	*/
	SELECT p.*, mp.MedioPago, r.NroRemito, ch.NroCheque
    FROM        Pagos p 
    INNER JOIN  MediosPago mp USING(IdMedioPago)
    INNER JOIN  Ventas v USING(IdVenta)
    INNER JOIN  Clientes cl USING(IdCliente)
    LEFT JOIN   Remitos r ON p.IdRemito = r.IdRemito
    LEFT JOIN   Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE       p.IdVenta = pIdVenta
                AND (IdMedioPago = pIdMedioPago OR pIdMedioPago = 0)
    ORDER BY    p.FechaAlta;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_pagar_venta_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_venta_cheque`(pToken varchar(500), pIdVenta bigint, pIdMedioPago smallint,
pFechaDebe datetime, pFechaPago datetime, pIdCheque bigint, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago de una venta, utilizando un cheque.
    * Siempre y cuando el estado actual de la venta sea Activo y el del
    * cheque sea Disponible. Cambia el estado del cheque a Utilizado.
    * Si con este nuevo pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_venta_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdMedioPago IS NULL OR pIdMedioPago = 0) THEN
        SELECT 'Debe indicar la medio de pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCheque IS NULL OR pIdCheque = 0) THEN
        SELECT 'Debe ingresar el cheque.' Mensaje;
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
    IF NOT EXISTS(SELECT IdCheque FROM Cheques WHERE IdCheque = pIdCheque AND Estado = 'D') THEN
        SELECT 'El cheque no existe, o no se encuentra disponible para el uso.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    IF ((SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque) + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del cheque supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( (SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque) + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF ( (SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque) + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
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

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdVenta, pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, (SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque), pObservacionesPago,
        pIdCheque, NULL, NULL, NULL, NULL, NULL, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- -- Inserto el comprobante
        -- INSERT INTO Comprobantes VALUES (pIdPago, pIdTipoComprobante,
        -- CONCAT('/Rutas_Comprobantes/Comp',pIdPago,'.pdf'), NOW());
        -- -- Audito el comprobante
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_pagar_venta_efectivo`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_venta_efectivo`(pToken varchar(500), pIdVenta bigint, pIdMedioPago smallint,
pMontoPago decimal(12,2), pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago de una venta, utilizando efectivo.
    * Siempre y cuando el estado actual de la venta sea Activo.
    * Si con este nuevo pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pMedioPago varchar(100);
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_venta_efectivo', pMensaje, pIdUsuario);
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
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe indicar la monto del pago.' Mensaje;
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
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del pago supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
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

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdVenta, pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- -- Inserto el comprobante
        -- INSERT INTO Comprobantes VALUES (pIdPago, pIdTipoComprobante,
        -- CONCAT('/Rutas_Comprobantes/Comp',pIdPago,'.pdf'), NOW());
        -- -- Audito el comprobante
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_pagar_venta_tarjeta`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_venta_tarjeta`(pToken varchar(500), pIdVenta bigint, pIdMedioPago smallint,
pMontoPago decimal(12,2), pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pNroTarjeta char(16), pMesVencimiento char(2), pAnioVencimiento char(2), pCCV char(3),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago de una venta, utilizando una tarjeta.
    * Controlando que los datos de la tarjeta sean validos.
    * Siempre y cuando el estado actual de la venta sea Activo.
    * Si con este nuevo pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pMedioPago varchar(100);
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_venta_tarjeta', pMensaje, pIdUsuario);
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
    /*
    IF (pNroTarjeta IS NULL OR CHAR_LENGTH(pNroTarjeta) != 16) THEN
        SELECT 'Debe indicar el numero de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pMesVencimiento IS NULL OR CHAR_LENGTH(pMesVencimiento) != 2) THEN
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
	END IF;
    */
    IF (pNroTarjeta IS NULL) THEN
        SELECT 'Debe indicar el numero de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe indicar la monto del pago.' Mensaje;
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
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del pago supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
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

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdVenta, pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, NULL, pNroTarjeta, pMesVencimiento, pAnioVencimiento, pCCV, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- -- Inserto el comprobante
        -- INSERT INTO Comprobantes VALUES (pIdPago, pIdTipoComprobante,
        -- CONCAT('/Rutas_Comprobantes/Comp',pIdPago,'.pdf'), NOW());
        -- -- Audito el comprobante
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

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

    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del pago supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;
    
    -- IF((SELECT COALESCE(SUM(li.Cantidad*li.Precio),0) FROM Ingresos i 
    --     INNER JOIN LineasIngreso li USING(IdIngreso) WHERE i.IdRemito = pIdRemito)
    -- + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
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
        INSERT INTO Pagos VALUES (0, pIdVenta, pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, pIdRemito, NULL, NULL, NULL, NULL, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- -- Inserto el comprobante
        -- INSERT INTO Comprobantes VALUES (pIdPago, pIdTipoComprobante,
        -- CONCAT('/Rutas_Comprobantes/Comp',pIdPago,'.pdf'), NOW());
        -- -- Audito el comprobante
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_pagar_venta_retencion`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_venta_retencion`(pToken varchar(500), pIdVenta bigint, pIdMedioPago smallint,
pIdTipoTributo tinyint, pMontoPago decimal(12,2), pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago de una venta, utilizando efectivo a un agente de Retencion.
    * Siempre y cuando el estado actual de la venta sea Activo.
    * Si con este nuevo pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pMedioPago varchar(100);
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_venta_retencion', pMensaje, pIdUsuario);
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
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe indicar la monto del pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoTributo IS NULL OR pIdTipoTributo = 0) THEN
        SELECT 'Debe indicar el tipo de tributo.' Mensaje;
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
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del pago supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
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

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdVenta, pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, NULL, NULL, NULL, NULL, NULL,
        JSON_OBJECT('IdTipoTributo', pIdTipoTributo));

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- -- Inserto el comprobante
        -- INSERT INTO Comprobantes VALUES (pIdPago, pIdTipoComprobante,
        -- CONCAT('/Rutas_Comprobantes/Comp',pIdPago,'.pdf'), NOW());
        -- -- Audito el comprobante
        -- INSERT INTO aud_Comprobantes
        -- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

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
    DECLARE pIdRemito bigint;
    DECLARE pIdVenta bigint;
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

        IF EXISTS(SELECT IdRemito FROM Pagos WHERE IdRemito IS NOT NULL AND IdPago = pIdPago) THEN
            SET pIdRemito = (SELECT IdRemito FROM Pagos WHERE IdPago = pIdPago);
            -- Audito Antes el Remito
            INSERT INTO aud_Remitos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_PAGO', 'A',
            Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
            -- Modifico Remito
            UPDATE  Remitos 
            SET	    IdCliente=NULL
            WHERE   IdRemito=pIdRemito;
            -- Audito Despues el Remito
            INSERT INTO aud_Remitos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_PAGO', 'D',
            Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
        END IF;

        -- -- Audito Comprobante
		-- INSERT INTO aud_Comprobantes
		-- SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B',
        -- Comprobantes.* FROM Comprobantes WHERE IdPago = pIdPago;
        -- -- Borra Comprobante
        -- DELETE FROM Comprobantes WHERE IdPago = pIdPago;

        SET pIdVenta = (SELECT IdVenta FROM Pagos WHERE IdPago=pIdPago);
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

DROP PROCEDURE IF EXISTS `xsp_dame_pago`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_pago`(pIdPago bigint)
SALIR: BEGIN
    /*
	* Permite instanciar un pago desde la base de datos.
	*/
	SELECT p.*, mp.MedioPago, r.NroRemito, ch.NroCheque
    FROM Pagos p 
    INNER JOIN MediosPago mp USING(IdMedioPago)
    INNER JOIN Ventas v USING(IdVenta)
    INNER JOIN Clientes cl USING(IdCliente)
    LEFT JOIN  Remitos r ON p.IdRemito = r.IdRemito
    LEFT JOIN  Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE p.IdPago = pIdPago;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_mediopago_pago`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_mediopago_pago`(pMedioPago varchar(100))
BEGIN
	/*
    Procedimiento que sirve para instanciar un medio de pago desde la base de datos.
    */
	SELECT	mp.IdMedioPago
    FROM	MediosPago mp
    WHERE	mp.MedioPago = pMedioPago
            AND mp.Estado = 'A';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modificar_pago_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_cheque`(pToken varchar(500), pIdPago bigint,
pFechaDebe datetime, pFechaPago datetime, pIdCheque bigint, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago de una venta, utilizando un cheque.
    * Si se cambia de cheque se controla que el estado actual del nuevo cheque
    * sea Disponible y cambia su estado a Utilizado, a si mismo el estado del
    * antiguo cheque vuelve a Disponible.
    * Si con esta modificacion del pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdVenta bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pIdChequeAntiguo bigint;
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_cheque', pMensaje, pIdUsuario);
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
    IF (pIdCheque IS NULL OR pIdCheque = 0) THEN
        SELECT 'Debe ingresar el cheque.' Mensaje;
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

    SET pIdVenta = (SELECT IdVenta FROM Pagos WHERE IdPago = pIdPago);
    IF ((SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque)
    + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del cheque supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( (SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque) + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
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

            IF ((SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque) 
            + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
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
        ELSE
            SET pMotivo='MODIFICA';
        END IF;

        -- Audito el pago Antes
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'A',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Modifica el pago
        UPDATE Pagos
        SET IdCheque=pIdCheque,
            Monto = (SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque),
            Observaciones=pObservacionesPago
        WHERE IdPago=pIdPago;
        -- Audito el pago Despues
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'D',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

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

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modificar_pago_efectivo`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_efectivo`(pToken varchar(500), pIdPago bigint, pMontoPago decimal(12,2),
pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago de una venta, utilizando un efectivo.
    * Si con esta modificacion del pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdVenta bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_efectivo', pMensaje, pIdUsuario);
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
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe ingresar el monto.' Mensaje;
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
    IF NOT EXISTS(SELECT IdPago FROM Pagos WHERE IdPago = pIdPago AND IdRemito IS NULL AND IdCheque IS NULL AND NroTarjeta IS NULL)THEN
        SELECT 'El pago indicado no es de tipo efectivo.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    SET pIdVenta = (SELECT IdVenta FROM Pagos WHERE IdPago = pIdPago);
    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del cheque supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
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
            Observaciones=pObservacionesPago
        WHERE IdPago=pIdPago;
        -- Audito el pago Despues
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'D',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

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

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

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
	DECLARE pIdUsuario bigint;
    DECLARE pIdVenta bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje text;
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

    SET pIdVenta = (SELECT IdVenta FROM Pagos WHERE IdPago = pIdPago);
    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del cheque supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
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

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modificar_pago_mercaderia`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_mercaderia`(pToken varchar(500), pIdPago bigint,
pFechaDebe datetime, pFechaPago datetime, pIdRemito bigint, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago de una venta, utilizando mercaderia asosiada a un remito.
    * Si se cambia el remito se controla que el estado actual del nuevo remito
    * sea Disponible.
    * Si con esta modificacion del pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdVenta bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pIdRemitoAntiguo bigint;
    DECLARE pMontoPago decimal(12,2);
    DECLARE pIdCliente bigint;
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_mercaderia', pMensaje, pIdUsuario);
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
    IF (pIdRemito IS NULL OR pIdRemito = 0) THEN
        SELECT 'Debe ingresar el remito.' Mensaje;
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
    IF NOT EXISTS(SELECT IdRemito FROM Pagos WHERE IdPago = pIdPago)THEN
        SELECT 'El pago indicado no es de tipo mercaderia.' Mensaje;
        LEAVE SALIR;
    END IF;
    SET pIdRemitoAntiguo = (SELECT IdRemito FROM Pagos WHERE IdPago = pIdPago);
    IF(pIdRemitoAntiguo != pIdRemito)THEN
        IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'A') THEN
            SELECT 'El remito no existe, o no se encuentra activo.' Mensaje;
            LEAVE SALIR;
        END IF;
        IF NOT EXISTS(SELECT IdCliente FROM Remitos WHERE IdRemito = pIdRemito AND IdCliente IS NULL) THEN
            SELECT 'El remito ya esta utilizado en otro pago.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    SET pMontoPago = (SELECT COALESCE(SUM(li.Cantidad*li.Precio),0) FROM Ingresos i 
        INNER JOIN LineasIngreso li USING(IdIngreso) WHERE i.IdRemito = pIdRemito);
    SET pIdVenta = (SELECT IdVenta FROM Pagos WHERE IdPago = pIdPago);

    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del cheque supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF(pIdRemito != pIdRemitoAntiguo)THEN
            SET pIdCliente = (SELECT IdCliente FROM Remitos WHERE IdRemito = pIdRemitoAntiguo);
            -- Audito Antes el remito Antiguo
            INSERT INTO aud_Remitos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_PAGO', 'A',
            Remitos.* FROM Remitos WHERE IdRemito = pIdRemitoAntiguo;
            -- Modifica Cheque Antiguo
            UPDATE  Remitos 
            SET	    IdCliente=NULL
            WHERE   IdRemito=pIdRemitoAntiguo;
            -- Audito Despues el Cheque Antiguo
            INSERT INTO aud_Remitos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_PAGO', 'D',
            Remitos.* FROM Remitos WHERE IdRemito = pIdRemitoAntiguo;

            -- Antes Remito
            INSERT INTO aud_Remitos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGO', 'A',
            Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
            -- Modifica Remito
            UPDATE Remitos
            SET		IdCliente=pIdCliente
            WHERE	IdRemito=pIdRemito;
            -- Despues Remito
            INSERT INTO aud_Remitos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGO', 'D',
            Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;

            IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
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
        ELSE   
            SET pMotivo='MODIFICA';
        END IF;

        -- Audito el pago Antes
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'A',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Modifica el pago
        UPDATE Pagos
        SET IdRemito=pIdRemito,
            Monto = pMontoPago,
            Observaciones=pObservacionesPago
        WHERE IdPago=pIdPago;
        -- Audito el pago Despues
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'D',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

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

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modificar_pago_retencion`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_retencion`(pToken varchar(500), pIdPago bigint, pIdTipoTributo tinyint, pMontoPago decimal(12,2),
pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago de una venta, utilizando un efectivo.
    * Si con esta modificacion del pago se termina de pagar la venta, cambiar el estado de
    * la venta a Pagado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdVenta bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMotivo varchar(100);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_retencion', pMensaje, pIdUsuario);
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
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe ingresar el monto.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoTributo IS NULL OR pIdTipoTributo = 0) THEN
        SELECT 'Debe indicar el tipo de tributo.' Mensaje;
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
    IF NOT EXISTS(SELECT IdPago FROM Pagos WHERE IdPago = pIdPago AND IdRemito IS NULL AND IdCheque IS NULL AND NroTarjeta IS NULL)THEN
        SELECT 'El pago indicado no es de tipo efectivo.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    SET pIdVenta = (SELECT IdVenta FROM Pagos WHERE IdPago = pIdPago);
    IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
    > (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta)) THEN
        SELECT 'No se puede pagar, el monto del cheque supera la venta.' Mensaje;
        LEAVE SALIR;
    END IF;

    -- IF( pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta)
    -- < (SELECT Monto FROM Ventas WHERE IdVenta = pIdVenta) AND pFechaDebe IS NULL) THEN
    --     SELECT 'No se puede activar, se debe ingresar la maxima fecha de deuda.' Mensaje;
    --     LEAVE SALIR;
    -- END IF;


    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF (pMontoPago + (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago)
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
            Datos = JSON_OBJECT('IdTipoTributo', pIdTipoTributo),
            Observaciones=pObservacionesPago
        WHERE IdPago=pIdPago;
        -- Audito el pago Despues
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, pMotivo, 'D',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

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

        IF EXISTS (SELECT IdPago FROM Pagos WHERE IdVenta=pIdVenta AND IdPago != pIdPago AND pMotivo = 'PAGA') THEN
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'A',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
            -- Modifico los demas pagos
            UPDATE Pagos
            SET     FechaPago=NOW(),
                    FechaDebe=NULL
            WHERE   IdVenta = pIdVenta AND IdPago!=pIdPago;
            -- Audito antes los demas pagos
            INSERT INTO aud_Pagos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'PAGA', 'D',
            Pagos.* FROM Pagos WHERE IdVenta = pIdVenta AND IdPago != pIdPago;
        END IF;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;