DROP PROCEDURE IF EXISTS `xsp_darbaja_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_venta`(pToken varchar(500), pIdVenta bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de baja una venta siempre y cuando no esté dado de baja ya.
    * Controlando que no tenga pagos o lineas ventas asosiadas, siempre y cuando
    * se encuentre en estado de edicion ademas que estar dentro del tiempo de anulacion de la empresa.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdEmpresa int;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de Parametros incorrectos
    IF EXISTS(SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'B') THEN
		SELECT 'La venta ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdPago FROM Pagos WHERE Codigo = pIdVenta AND Tipo = 'V') THEN
		SELECT 'La venta indicada no se puede dar de baja, tiene pagos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no se puede dar de baja, tiene lineas de venta asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Ventas WHERE IdVenta = pIdVenta);
    IF NOT ((SELECT FechaAlta FROM Ventas WHERE IdVenta = pIdVenta) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1) ) ) THEN
        SELECT 'La venta supero el tiempo maximo de anulacion.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Audito Antes Ventas
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
		-- Da de baja la venta
		UPDATE Ventas SET Estado = 'B' WHERE IdVenta = pIdVenta;
		-- Audito Después Ventas
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;

		SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;