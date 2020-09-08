DROP PROCEDURE IF EXISTS `xsp_activar_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_venta`(pToken varchar(500), pIdVenta bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado de la Venta a Activo siempre y cuando el estado actual sea Edicion.
    * Controlando que la venta cuente con al menos una linea de venta.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdCliente bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMonto, pMontoLinea decimal(12, 2);
    DECLARE pMontoAFavor decimal(12, 2);
    DECLARE pMontoPago decimal(12, 2);
    DECLARE pMensaje varchar(100);
    DECLARE pDescripcion text;
    DECLARE pIndiceLinea int default 0;
    DECLARE pLineas json;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción interna. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controla Parámetros
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'A') THEN
		SELECT 'La venta ya está activa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
		SELECT 'La venta debe estar en edición para poder ser activada.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta) THEN
		SELECT 'La venta debe tener al menos una linea de venta para poder ser activada.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Audito Venta Antes
        INSERT INTO aud_Ventas
        SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'ACTIVAR','A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;

        IF ( (SELECT Tipo FROM Ventas WHERE IdVenta = pIdVenta) = 'G') THEN
            -- Paga Venta
            UPDATE  Ventas 
            SET     Estado = 'P',
                    Monto = 0
            WHERE   IdVenta = pIdVenta;
        ELSE
            SELECT      COALESCE(SUM(lv.Precio * lv.Cantidad),0), v.IdCliente
            INTO        pMonto, pIdCliente
            FROM        Ventas v
            INNER JOIN  LineasVenta lv ON lv.IdVenta = v.IdVenta
            WHERE       v.IdVenta = pIdVenta;

            SET pMontoAFavor = (SELECT IF(Monto < 0, - Monto, 0) FROM CuentasCorrientes WHERE IdEntidad = pIdCliente AND Tipo = 'C');

            -- Busco las lineas venta asociados a la venta
            SET pLineas = ( SELECT  COALESCE(JSON_ARRAYAGG(NroLinea), JSON_ARRAY())
                            FROM    LineasVenta
                            WHERE   IdVenta = pIdVenta
            );

            WHILE pIndiceLinea < JSON_LENGTH(pLineas) DO
                -- Aumento la deuda del Cliente
                SELECT      CONCAT(a.Articulo, ' x ', lv.Cantidad, ' [', pr.Proveedor, ']'), COALESCE((lv.Precio*lv.Cantidad),0)
                INTO        pDescripcion, pMontoLinea
                FROM        LineasVenta lv
                INNER JOIN  Articulos a ON lv.IdArticulo = a.IdArticulo
                INNER JOIN  Proveedores pr ON a.IdProveedor = pr.IdProveedor
                WHERE       lv.IdVenta = pIdVenta
                            AND lv.NroLinea = JSON_EXTRACT(pLineas, CONCAT('$[', pIndiceLinea, ']'));

                -- Aumento la deuda del cliente
                CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
                    pIdCliente,'C', pMontoLinea,
                    'Venta', pDescripcion,
                    pIP, pUserAgent, pAplicacion, pMensaje);
                IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
                    SELECT pMensaje Mensaje; 
                    ROLLBACK;
                    LEAVE SALIR;
                END IF;

                SET pIndiceLinea = pIndiceLinea + 1;
            END WHILE;

            IF pMontoAFavor > 0 THEN
                SET pMontoPago = IF((pMontoAFavor - pMonto) < 0, pMontoAFavor, pMonto);

                -- Inserto el pago
                INSERT INTO Pagos VALUES (0, pIdVenta, 'V', 11, -- Medio de Pago Debito de Cuenta Corriente
                pIdUsuario, NOW(), NULL,
                NOW(), NULL, pMontoPago, 'Pago Automatico',
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

                -- Audito el pago
                INSERT INTO aud_Pagos
                SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
                Pagos.* FROM Pagos WHERE IdPago = LAST_INSERT_ID();
            END IF;

            IF pMontoPago = pMonto THEN
                -- Paga Venta
                UPDATE  Ventas 
                SET     Estado = 'P',
                        Monto = pMonto
                WHERE   IdVenta = pIdVenta;
            ELSE
                -- Activa Venta
                UPDATE  Ventas 
                SET     Estado = 'A',
                        Monto = pMonto
                WHERE   IdVenta = pIdVenta;
            END IF;
        END IF;

        -- Audito Venta Después
        INSERT INTO aud_Ventas
        SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'ACTIVAR','D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$

DELIMITER ;