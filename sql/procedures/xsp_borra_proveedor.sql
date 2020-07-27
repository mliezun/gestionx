DROP PROCEDURE IF EXISTS `xsp_borra_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_proveedor`(pToken varchar(500), pIdProveedor bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite borrar un proveedor controlando que no tenga artículos asociados.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no se puede borrar, tiene artículos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audito Antes
        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;

        -- Borro Historial Descuentos
        DELETE FROM HistorialDescuentos WHERE IdProveedor = pIdProveedor;

        -- Borro Proveedor
        DELETE FROM Proveedores WHERE IdProveedor = pIdProveedor;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;