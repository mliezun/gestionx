DROP PROCEDURE IF EXISTS `xsp_activar_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_proveedor`(pToken varchar(500), pIdProveedor bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite activar un proveedor controlando que no esté activo ya.
    Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor AND Estado = 'A') THEN
        SELECT 'El proveedor indicado ya está activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;

        UPDATE Proveedores SET Estado = 'A' WHERE IdProveedor = pIdProveedor;

        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;