DROP PROCEDURE IF EXISTS `xsp_borra_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_cliente`(pToken varchar(500), pIdCliente bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un cliente controlando que no tenga ingresos o ventas asosiadas.
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_cliente', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdVenta FROM Ventas WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene ventas asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene ingresos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdRemito FROM Remitos WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene remitos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdCheque FROM Cheques WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene cheques asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Clientes
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Clientes.*
        FROM Clientes WHERE IdCliente = pIdCliente;
        -- Borro
        DELETE FROM Clientes WHERE IdCliente = pIdCliente;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;