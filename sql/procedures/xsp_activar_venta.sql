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
	DECLARE pUsuario varchar(30);
    DECLARE pMonto decimal(12, 2);
    DECLARE pMensaje varchar(100);
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
            SET pMonto = (SELECT COALESCE(SUM(Precio*Cantidad),0) FROM LineasVenta WHERE IdVenta = pIdVenta);
            -- Activa Venta
            UPDATE  Ventas 
            SET     Estado = 'A',
                    Monto = pMonto
            WHERE   IdVenta = pIdVenta;

            -- Aumenta la deuda del Cliente
            CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
                (SELECT IdCliente FROM Ventas WHERE IdVenta = pIdVenta),
                'C',
                pMonto,
                'Nueva Venta',
                NULL,
                pIP, pUserAgent, pAplicacion, pMensaje);
            IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
                SELECT pMensaje Mensaje; 
                ROLLBACK;
                LEAVE SALIR;
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