DROP PROCEDURE IF EXISTS `xsp_activar_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_rol`(pToken varchar(500), pIdRol tinyint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Rol a Activo siempre y cuando no esté activo ya. Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Roles WHERE IdRol = pIdRol AND Estado = 'A') THEN
		SELECT 'El rol ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Roles
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Roles.* FROM Roles WHERE IdRol = pIdRol;
		-- Activa Rol
		UPDATE Roles SET Estado = 'A' WHERE IdRol = pIdRol;
		-- Después
		INSERT INTO aud_Roles
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Roles.* FROM Roles WHERE IdRol = pIdRol;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;