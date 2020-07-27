DROP PROCEDURE IF EXISTS `xsp_borra_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_rol`(pToken varchar(500), pIdRol tinyint, pObservaciones text,
								pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite borrar un Rol existente y sus permisos asociados controlando que no existan usuarios asociados.
    Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdRol FROM Usuarios WHERE IdRol = pIdRol) THEN
		SELECT 'No se puede borrar el rol. Existen usuarios asociados.' Mensaje;
		LEAVE SALIR;
	END IF;
	-- Borra el rol y sus Permisos
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Audita
		INSERT INTO aud_PermisosRol
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ROLBORRA', 'B', PermisosRol.* FROM PermisosRol WHERE IdRol = pIdRol;
        -- Borra permisos
        DELETE FROM PermisosRol WHERE IdRol = pIdRol;
		-- Audito
		INSERT INTO aud_Roles
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B', Roles.* FROM Roles WHERE IdRol = pIdRol;
        -- Borra rol
        DELETE FROM Roles WHERE IdRol = pIdRol;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;