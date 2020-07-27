DROP PROCEDURE IF EXISTS `xsp_clonar_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_clonar_rol`(pJWT varchar(500), pIdRol tinyint, pRol varchar(30),
											pIP varchar(40), pUserAgent varchar(255), pApp varchar(50))
PROC: BEGIN
	/*
    Permite clonar un rol a partir de un existente, pasándole el nombre, controlando que no exista ya. 
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pIdRolNuevo tinyint;
    DECLARE pRolNuevo varchar(30);
    DECLARE pIdUsuario bigint;
	DECLARE pIdEmpresa int;
	DECLARE pUsuario varchar(120);
	DECLARE pMensaje varchar(255);
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros.
	CALL xsp_puede_ejecutar(pJWT, 'xsp_clonar_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE PROC;
	END IF;
    IF (pRol IS NULL OR pRol = '') THEN
        SELECT 'Debe ingresar el nombre del rol.' Mensaje;
        LEAVE PROC;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	IF EXISTS(SELECT Rol FROM Roles WHERE Rol = pRol AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'El nombre del rol ya existe.' Mensaje;
		LEAVE PROC;
	END IF;
	-- Da de alta calculando el próximo id y clonando también la tabla permisos
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pRolNuevo = (SELECT CONCAT(Rol, ' (', IdRol, ')') FROM Roles WHERE IdRol = pIdRol);
        INSERT INTO Roles SELECT 0, pRol, 'A', CONCAT('Clonado de ', pRolNuevo), pIdEmpresa;
		SET pIdRolNuevo = LAST_INSERT_ID();
		-- Audito
		INSERT INTO aud_Roles
		SELECT 0, NOW(), pUsuario, pIP, pUserAgent, pApp, NULL, 'I', Roles.* FROM Roles 
        WHERE IdRol = pIdRolNuevo;
        INSERT INTO PermisosRol
			SELECT	IdPermiso, pIdRolNuevo
            FROM	PermisosRol
            WHERE	IdRol = pIdRol;
		-- Audito
		INSERT INTO aud_PermisosRol
		SELECT 0, NOW(), pUsuario, pIP, pUserAgent, pApp, NULL, 'I', PermisosRol.* FROM PermisosRol
        WHERE IdRol = pIdRolNuevo;
        SELECT CONCAT('OK', pIdRolNuevo) Mensaje;
	COMMIT;
END$$

DELIMITER ;