
DROP PROCEDURE IF EXISTS `xsp_pagar_proveedor_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_proveedor_cheque`(pToken varchar(500), pIdProveedor bigint, pIdMedioPago smallint,
pFechaDebe datetime, pFechaPago datetime, pIdCheque bigint, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago de un proveedor, utilizando un cheque.
    * Siempre y cuando el estado actual del cheque sea Disponible y
    * el del proveedor sea activo.
    * Cambia el estado del cheque a Utilizado.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje text;
    DECLARE pMontoPago decimal(12, 2)
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_proveedor_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
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
    IF NOT EXISTS(SELECT Estado FROM Proveedores WHERE IdProveedor = pIdProveedor AND Estado = 'A') THEN
		SELECT 'El proveedor no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
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

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pMonto = (SELECT Importe FROM Cheques WHERE IdCheque = pIdCheque);

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
        INSERT INTO Pagos VALUES (0, pIdProveedor, 'P', pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        pIdCheque, NULL, NULL, NULL, NULL, NULL, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- Disminuye la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			pIdProveedor,
			'P',
			pMontoPago,
			'Pago al Proveedor',
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

DROP PROCEDURE IF EXISTS `xsp_pagar_proveedor_efectivo`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_proveedor_efectivo`(pToken varchar(500), pIdProveedor bigint, pIdMedioPago smallint,
pMontoPago decimal(12,2), pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago a un proveedor, utilizando efectivo.
    * Siempre y cuando el estado actual del proveedor sea Activo.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pMedioPago varchar(100);
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_proveedor_efectivo', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdMedioPago IS NULL OR pIdMedioPago = 0) THEN
        SELECT 'Debe indicar la medio de pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe indicar la monto del pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT Estado FROM Proveedores WHERE IdProveedor = pIdProveedor AND Estado = 'A') THEN
		SELECT 'El proveedor no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM MediosPago WHERE IdMedioPago = pIdMedioPago AND Estado = 'A') THEN
		SELECT 'El medio de pago no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdProveedor, 'P', pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- Disminuye la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			pIdProveedor,
			'P',
			pMontoPago,
			'Pago al Proveedor',
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

DROP PROCEDURE IF EXISTS `xsp_pagar_proveedor_tarjeta`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_proveedor_tarjeta`(pToken varchar(500), pIdProveedor bigint, pIdMedioPago smallint,
pMontoPago decimal(12,2), pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pNroTarjeta char(16), pMesVencimiento char(2), pAnioVencimiento char(2), pCCV char(3),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago a un proveedor, utilizando una tarjeta.
    * Controlando que los datos de la tarjeta sean validos.
    * Siempre y cuando el estado actual del proveedor sea Activo.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pMedioPago varchar(100);
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_proveedor_tarjeta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdMedioPago IS NULL OR pIdMedioPago = 0) THEN
        SELECT 'Debe indicar la medio de pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pNroTarjeta IS NULL) THEN
        SELECT 'Debe indicar el numero de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe indicar la monto del pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT Estado FROM Proveedores WHERE IdProveedor = pIdProveedor AND Estado = 'A') THEN
		SELECT 'El proveedor no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM MediosPago WHERE IdMedioPago = pIdMedioPago AND Estado = 'A') THEN
		SELECT 'El medio de pago no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdProveedor, 'V', pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, NULL, pNroTarjeta, pMesVencimiento, pAnioVencimiento, pCCV, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- Disminuye la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			pIdProveedor,
			'P',
			pMontoPago,
			'Pago al Proveedor',
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

DROP PROCEDURE IF EXISTS `xsp_pagar_proveedor_retencion`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_proveedor_retencion`(pToken varchar(500), pIdProveedor bigint, pIdMedioPago smallint,
pIdTipoTributo tinyint, pMontoPago decimal(12,2), pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de alta un nuevo pago a un proveedor, utilizando efectivo a un agente de Retencion.
    * Siempre y cuando el estado actual del proveedor sea Activo.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pMedioPago varchar(100);
    DECLARE pIdPago bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje text;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_pagar_proveedor_retencion', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
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
    IF NOT EXISTS(SELECT Estado FROM Proveedores WHERE IdProveedor = pIdProveedor AND Estado = 'A') THEN
		SELECT 'El proveedor no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM MediosPago WHERE IdMedioPago = pIdMedioPago AND Estado = 'A') THEN
		SELECT 'El medio de pago no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

        -- Inserto el pago
        INSERT INTO Pagos VALUES (0, pIdProveedor, 'P', pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
        pFechaPago, NULL, pMontoPago, pObservacionesPago,
        NULL, NULL, NULL, NULL, NULL, NULL,
        JSON_OBJECT('IdTipoTributo', pIdTipoTributo));

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        -- Disminuye la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			pIdProveedor,
			'P',
			pMontoPago,
			'Pago al Proveedor',
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

DROP PROCEDURE IF EXISTS `xsp_modificar_pago_proveedor_efectivo`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_proveedor_efectivo`(pToken varchar(500), pIdPago bigint, pMontoPago decimal(12,2),
pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago a un proveedor, utilizando un efectivo.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje text;
    DECLARE pDiferencia decimal(12, 2);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_proveedor_efectivo', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdPago IS NULL OR pIdPago = 0) THEN
        SELECT 'Debe indicar el pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe ingresar el monto.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdPago FROM Pagos WHERE IdPago = pIdPago) THEN
		SELECT 'El pago indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pDiferencia = pMontoPago - (SELECT Monto FROM Pagos WHERE IdPago = pIdPago);

        -- Audito el pago Antes
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Modifica el pago
        UPDATE  Pagos
        SET     Monto = pMontoPago,
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

DROP PROCEDURE IF EXISTS `xsp_modificar_pago_proveedor_tarjeta`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_proveedor_tarjeta`(pToken varchar(500), pIdPago bigint, pMontoPago decimal(12,2),
pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pNroTarjeta char(16), pMesVencimiento char(2), pAnioVencimiento char(2), pCCV char(3),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago a un proveedor, utilizando una tarjeta.
    * Controlando que los datos de la tarjeta sean validos.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje text;
    DECLARE pDiferencia decimal(12, 2);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_proveedor_tarjeta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdPago IS NULL OR pIdPago = 0) THEN
        SELECT 'Debe indicar el pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pNroTarjeta IS NULL) THEN
        SELECT 'Debe indicar el numero de la tarjeta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pMontoPago IS NULL OR pMontoPago <= 0) THEN
        SELECT 'Debe indicar la monto del pago.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdPago FROM Pagos WHERE IdPago = pIdPago) THEN
		SELECT 'El pago indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT NroTarjeta FROM Pagos WHERE IdPago = pIdPago AND IdRemito IS NULL AND IdCheque IS NULL)THEN
        SELECT 'El pago indicado no es de tipo tarjeta.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pDiferencia = pMontoPago - (SELECT Monto FROM Pagos WHERE IdPago = pIdPago);

        -- Audito el pago Antes
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Modifica el pago
        UPDATE  Pagos
        SET     Monto = pMontoPago,
                NroTarjeta = pNroTarjeta,
                MesVencimiento = pMesVencimiento,
                AnioVencimiento = pAnioVencimiento,
                CCV = pCCV,
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

DROP PROCEDURE IF EXISTS `xsp_modificar_pago_proveedor_retencion`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_proveedor_retencion`(pToken varchar(500), pIdPago bigint, pIdTipoTributo tinyint, pMontoPago decimal(12,2),
pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago a un proveedor, utilizando un efectivo siendo este un agente de retencion.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje text;
    DECLARE pDiferencia decimal(12, 2);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_proveedor_retencion', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdPago IS NULL OR pIdPago = 0) THEN
        SELECT 'Debe indicar el pago.' Mensaje;
        LEAVE SALIR;
	END IF;
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
    IF NOT EXISTS(SELECT IdTipoTributo FROM TiposTributos WHERE IdTipoTributo = pIdTipoTributo AND FechaHasta IS NULL) THEN
		SELECT 'El tipo de tributo no se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT IdPago FROM Pagos WHERE IdPago = pIdPago AND Datos->>'$.IdTipoTributo' IS NOT NULL)THEN
        SELECT 'El pago indicado no es de tipo retencion.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF (pFechaPago IS NULL) THEN
        SET pFechaPago = NOW();
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pDiferencia = pMontoPago - (SELECT Monto FROM Pagos WHERE IdPago = pIdPago);

        -- Audito el pago Antes
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;
        -- Modifica el pago
        UPDATE Pagos
        SET     Monto = pMontoPago,
                Datos = JSON_OBJECT('IdTipoTributo', pIdTipoTributo),
                Observaciones=pObservacionesPago
        WHERE   IdPago=pIdPago;
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
        SELECT INTO pMontoPago, pIdProveedor
        SELECT Monto, Codigo FROM Pagos WHERE IdPago = pIdPago;

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
			pIdProveedor,
			'P',
			- pMontoPago,
			'Borra Pago al Proveedor',
			NULL,
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