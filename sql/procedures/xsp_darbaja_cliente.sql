DROP PROCEDURE IF EXISTS `xsp_darbaja_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_cliente`(pToken varchar(500), pIdCliente bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de baja a un Cliente siempre y cuando no esté dado de baja ya.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_cliente', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Clientes WHERE IdCliente = pIdCliente AND Estado = 'B') THEN
		SELECT 'El Cliente ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Clientes
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Clientes.* FROM Clientes WHERE IdCliente = pIdCliente;
		-- Activa Cliente
		UPDATE Clientes SET Estado = 'B' WHERE IdCliente = pIdCliente;
		-- Después
		INSERT INTO aud_Clientes
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Clientes.* FROM Clientes WHERE IdCliente = pIdCliente;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;