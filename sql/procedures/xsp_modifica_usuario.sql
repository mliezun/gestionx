DROP PROCEDURE IF EXISTS `xsp_modifica_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_usuario`(pToken varchar(500), pIdUsuario bigint,
pIdRol tinyint, pNombres varchar(30), pApellidos varchar(30), pEmail varchar(120),
pObservaciones varchar(255), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar un Usuario existente. No se puede cambiar el nombre de usuario, ni la contraseña.
	Los nombres y apellidos son obligatorios. El correo electrónico no debe existir ya. El rol debe 
	existir. Si se cambia el rol, y se resetea token. 
	Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_usuario', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pNombres IS NULL OR pNombres = '') THEN
        SELECT 'Debe ingresar un valor para el campo nombres.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pApellidos IS NULL OR pApellidos = '') THEN
        SELECT 'Debe ingresar un valor para el campo apellidos.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pEmail IS NULL OR pEmail = '') THEN
        SELECT 'Debe ingresar un valor para el campo email.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF EXISTS (SELECT IdUsuario FROM Usuarios WHERE Email = pEmail AND IdUsuario != pIdUsuario AND IdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario)) THEN
        SELECT 'Otro usuario tiene el mismo email.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT r.IdRol FROM Roles r INNER JOIN Usuarios u USING(IdEmpresa) WHERE r.IdRol = pIdRol) THEN
        SELECT 'El rol especificado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS (SELECT IdRol FROM Usuarios WHERE IdUsuario=pIdUsuario AND IdRol!=pIdRol)
		THEN
		SET pToken = SHA2(RAND(),512);
	END IF;
    START TRANSACTION;
		SET pUsuarioAud = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
		-- Antes
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
		-- Modifica
        UPDATE Usuarios 
		SET		Nombres=pNombres,
				Apellidos=pApellidos,
				Email=pEmail,
				IdRol=pIdRol,
				Token=pToken
		WHERE	IdUsuario=pIdUsuario;
		-- Despues
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;