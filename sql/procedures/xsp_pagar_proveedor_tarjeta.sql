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
        INSERT INTO Pagos VALUES (0, pIdProveedor, 'P', pIdMedioPago, pIdUsuario, NOW(), pFechaDebe,
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