DROP PROCEDURE IF EXISTS `xsp_borra_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_venta`(pToken varchar(500), pIdVenta bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar una venta controlando que no tenga pagos o lineas ventas asosiadas,
    * siempre y cuando se encuentre en estado de edicion ademas que estar dentro del tiempo de anulacion de la empresa.
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pIdEmpresa int;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_venta', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdPago FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V') THEN
        SELECT 'La venta indicada no se puede borrar, tiene pagos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no se puede borrar, tiene lineas de venta asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
		SELECT 'La venta debe estar en edicion para ser borrada.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Ventas WHERE IdVenta = pIdVenta);
    IF NOT ((SELECT FechaAlta FROM Ventas WHERE IdVenta = pIdVenta) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1) ) ) THEN
        SELECT 'La venta supero el tiempo maximo de anulacion.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Ventas
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Ventas.*
        FROM Ventas WHERE IdVenta = pIdVenta;
        -- Borro
        DELETE FROM Ventas WHERE IdVenta = pIdVenta;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;