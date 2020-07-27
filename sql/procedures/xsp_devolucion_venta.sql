DROP PROCEDURE IF EXISTS `xsp_devolucion_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_devolucion_venta`(pToken varchar(500), pIdVenta bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado de la Venta a baja y agregar existencias articulos vendidos.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdPuntoVenta bigint;
    DECLARE pIdCliente bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pIdIngreso bigint;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_devolucion_venta', pMensaje, pIdUsuario);
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
		SELECT 'La venta está dada de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pIdPuntoVenta = (SELECT IdPuntoVenta FROM Ventas WHERE IdVenta = pIdVenta);
        SET pIdCliente = (SELECT IdPuntoVenta FROM Ventas WHERE IdVenta = pIdVenta);

        -- Instancia un nuevo ingreso
		CALL xsp_alta_existencia(pIdUsuario, pIdPuntoVenta, pIdCliente, NULL, 'Devolucion de Venta', pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

        SET pIdIngreso = SUBSTRING_INDEX(pMensaje,'OK',-1);
        -- Instancia las lineas ingreso del ingreo
        INSERT INTO LineasIngreso SELECT pIdIngreso, lv.NroLinea, lv.IdArticulo, lv.Cantidad, lv.Precio 
        FROM LineasVenta lv WHERE IdVenta=pIdVenta;

        -- Audita las lineas del ingreso
        INSERT INTO aud_LineasIngreso
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        LineasIngreso.* FROM LineasIngreso WHERE IdIngreso = pIdIngreso;

        -- Activa el nuevo ingreso
        CALL xsp_activar_existencia(pIdUsuario, pIdIngreso, pIP, pUserAgent, pAplicacion, pMensaje);
		IF pMensaje != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Audito la Venta antes de darla de baja
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DEVOLUCION','A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
		-- Da de baja la venta
		UPDATE Ventas SET Estado = 'D' WHERE IdVenta = pIdVenta;
		-- Audito la Venta despues de darla de baja
		INSERT INTO aud_Ventas
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DEVOLUCION','D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;

		SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;