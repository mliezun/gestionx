DROP PROCEDURE IF EXISTS `xsp_modificar_pago_cliente_retencion`;
DELIMITER $$
CREATE PROCEDURE `xsp_modificar_pago_cliente_retencion`(pToken varchar(500), pIdPago bigint, pIdTipoTributo tinyint, pMontoPago decimal(12,2),
pFechaDebe datetime, pFechaPago datetime, pObservacionesPago text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite modificar un pago de un cliente, utilizando un efectivo siendo este un agente de retencion.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario, pIdCliente bigint;
	DECLARE pUsuario varchar(30);
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modificar_pago_cliente_retencion', pMensaje, pIdUsuario);
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
        SELECT      p.Monto, p.Codigo, mp.MedioPago
        INTO        pMontoAnterior, pIdCliente, pDescripcion
        FROM        Pagos p
        INNER JOIN  MediosPago mp USING(IdMedioPago)
        WHERE       p.IdPago = pIdPago;

        SET pDiferencia = pMontoPago - pMontoAnterior;

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

        -- Modifica la deuda del Cliente
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			pIdCliente, 'C', - pDiferencia,
			'Modifica Pago del Cliente', pDescripcion,
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