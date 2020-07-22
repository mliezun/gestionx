DROP PROCEDURE IF EXISTS `xsp_alta_cuenta_corriente`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_cuenta_corriente`(pIdUsuario bigint, pIdEntidad bigint, pTipo char(1), pMotivo varchar(100), pObservaciones text, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite ingresar existencias de un artículo a un punto de venta, ya sea por Remito o por nota de crédito (devolución de un cliente).
    Crea un ingreso en estado En edición, de manera que se le puedan agregar líneas.
    Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdCuentaCorriente bigint;
    DECLARE pIdEmpresa int;
    DECLARE pUsuario varchar(30);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    CASE pTipo 
        WHEN 'P' THEN 
            IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdEntidad AND Estado = 'A') THEN
                SET pMensaje = 'El proveedor no se encuentra activo.';
                LEAVE SALIR;
            END IF;
		WHEN 'C' THEN
			IF NOT EXISTS (SELECT IdCliente FROM CLientes WHERE IdCliente = pIdEntidad AND Estado = 'A') THEN
                SET pMensaje = 'El cliente no se encuentra activo.';
                LEAVE SALIR;
            END IF;
        ELSE
            SET pMensaje = 'Tipo de cuenta corriente no soportada.';
            LEAVE SALIR;
    END CASE;
    
    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

    -- Se crea una nueva cuenta corriente
    INSERT INTO CuentasCorrientes SELECT 0, pIdEntidad, pTipo, 0, pObservaciones;
    SET pIdCuentaCorriente = LAST_INSERT_ID();

    -- Historial de cuenta
    INSERT INTO HistorialCuentasCorrientes SELECT 0, pIdCuentaCorriente, 0, pMotivo, NOW(), NULL;

    INSERT INTO aud_CuentasCorrientes
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
    CuentasCorrientes.* FROM CuentasCorrientes WHERE IdCuentaCorriente = pIdCuentaCorriente;

    SET pMensaje = CONCAT('OK', pIdCuentaCorriente);
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_modificar_cuenta_corriente`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_cuenta_corriente`(pIdUsuario bigint, pIdEntidad bigint, pTipo char(1), pMonto decimal(12, 2), pMotivo varchar(100), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite modificar una cuenta corriente, indicando el monto de actualizacion de la cuenta.
    (Siempre suma al valor actual de la cuenta)
    Devuelve OK o el mensaje de error en Mensaje.
	*/
    DECLARE pIdCuentaCorriente bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pIdCanal bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    CASE pTipo 
        WHEN 'P' THEN 
            IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdEntidad AND Estado = 'A') THEN
                SET pMensaje = 'El proveedor no se encuentra activo.';
                LEAVE SALIR;
            END IF;
		WHEN 'C' THEN
			IF NOT EXISTS (SELECT IdCliente FROM CLientes WHERE IdCliente = pIdEntidad AND Estado = 'A') THEN
                SET pMensaje = 'El cliente no se encuentra activo.';
                LEAVE SALIR;
            END IF;
        ELSE
            SET pMensaje = 'Tipo de cuenta corriente no soportada.';
            LEAVE SALIR;
    END CASE;

    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

    INSERT INTO aud_CuentasCorrientes
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
    CuentasCorrientes.* FROM CuentasCorrientes WHERE IdEntidad = pIdEntidad AND Tipo = pTipo;

    -- Modifico el monto de la cuenta
    UPDATE  CuentasCorrientes
    SET     Monto = Monto + pMonto
    WHERE   IdEntidad = pIdEntidad AND Tipo = pTipo;

    -- Historial de cuenta
    INSERT INTO HistorialCuentasCorrientes
    SELECT      0, cc.IdCuentaCorriente, pMonto, pMotivo, NOW(), pObservaciones
    FROM        CuentasCorrientes cc
    WHERE       IdEntidad = pIdEntidad AND Tipo = pTipo;

    INSERT INTO aud_CuentasCorrientes
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
    CuentasCorrientes.* FROM CuentasCorrientes WHERE IdEntidad = pIdEntidad AND Tipo = pTipo;

    SET pMensaje = 'OK';
END$$
DELIMITER ;