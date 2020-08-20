DROP PROCEDURE IF EXISTS `xsp_pagar_ventas_cuenta_corriente`;
DELIMITER $$
CREATE PROCEDURE `xsp_pagar_ventas_cuenta_corriente`(pIdUsuario bigint, pIdCliente bigint,
pMontoAFavor decimal(12, 2), pObservaciones text, pFechaPago datetime,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50),
out pMensaje text)
SALIR: BEGIN
    /*
	Permite pagar las ventas pendientes de un cliente por medio de su cuenta corriente, sin modificar el estado de 
    Devuelve OK o el mensaje de error en Mensaje.
	*/
    DECLARE pIdVenta bigint;
    DECLARE pIdPago bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMontoVenta decimal(12, 2);
    DECLARE pMontoPago decimal(12, 2);
    DECLARE pMontoDePagos decimal(12, 2);
    DECLARE pIndice int default 0;
    DECLARE pVentas json;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    IF NOT EXISTS (SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente AND Estado = 'A') THEN
        SET pMensaje = 'El cliente no se encuentra activo.';
        LEAVE SALIR;
    END IF;

    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

    -- Busco las ventas pendientes
    SET pVentas = ( SELECT      COALESCE(JSON_ARRAYAGG(IdVenta), JSON_ARRAY())
                    FROM        Ventas
                    WHERE       IdCliente = pIdCliente
                                AND Estado = 'A' AND Tipo NOT IN ('G', 'C')
                    ORDER BY    FechaAlta ASC
    );
    
    WHILE pMontoAFavor > 0 AND pIndice < JSON_LENGTH(pVentas) DO
        SELECT      IdVenta, Monto INTO pIdVenta, pMontoVenta
        FROM        Ventas
        WHERE       IdVenta = JSON_EXTRACT(pVentas, CONCAT('$[', pIndice, ']'));

        SET pMontoDePagos = (SELECT COALESCE(SUM(Monto),0) FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V');
        SET pMontoPago = IF((pMontoAFavor - pMontoVenta + pMontoDePagos) < 0, pMontoAFavor, pMontoVenta - pMontoDePagos);

        IF (pMontoPago + pMontoDePagos = pMontoVenta) THEN
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
        INSERT INTO Pagos VALUES (0, pIdVenta, 'V', 11, -- Medio de Pago Debito de Cuenta Corriente
        pIdUsuario, NOW(), NULL,
        pFechaPago, NULL, pMontoPago, pObservaciones,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        SET pIdPago = LAST_INSERT_ID();
        -- Audito el pago
        INSERT INTO aud_Pagos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Pagos.* FROM Pagos WHERE IdPago = pIdPago;

        SET pMontoAFavor = pMontoAFavor - pMontoPago;
        SET pIndice = pIndice + 1;
    END WHILE;

    SET pMensaje = 'OK';
END$$

DELIMITER ;