DROP PROCEDURE IF EXISTS `xsp_alta_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_usuario`(pTokenAud varchar(500), pIdRol tinyint, pNombres varchar(30), pApellidos varchar(30), pUsuario varchar(30), 
							pPassword varchar(255), pEmail varchar(120), pObservaciones varchar(255), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite dar de alta un Usuario controlando que el nombre del usuario no exista ya, siendo nombres y apellidos obligatorios.
    Se guarda el password hash de la contraseña. El correo electrónico no debe existir ya. El rol debe existir. 
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario, pIdUsuarioAud bigint;
    DECLARE pIdEmpresa int;
    DECLARE pToken varchar(500);
	DECLARE pUsuarioAud varchar(120);
    DECLARE pMensaje varchar(100);
    DECLARE pNow datetime;
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    
    SET pNow = now();
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pTokenAud, 'xsp_alta_usuario', pMensaje, pIdUsuarioAud);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pUsuario IS NULL OR pUsuario = '') THEN
        SELECT 'Debe ingresar el usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (LENGTH(pUsuario) <> LENGTH(REPLACE(pUsuario,' ',''))) THEN
        SELECT 'Caracter de espacio no permitido en el nombre de usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuarioAud);
    IF EXISTS(SELECT Usuario FROM Usuarios WHERE Usuario = pUsuario AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'El nombre del usuario ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF (pApellidos IS NULL OR pApellidos = '') THEN
        SELECT 'Debe ingresar el apellido del usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pNombres IS NULL OR pNombres = '') THEN
        SELECT 'Debe ingresar el nombre del usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT Email FROM Usuarios WHERE Email = pEmail AND IdEmpresa != pIdEmpresa) THEN
		SELECT 'El correo electrónico del usuario ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF (pEmail IS NULL OR pEmail = '') THEN
        SELECT 'Debe ingresar el correo electrónico del usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdRol IS NULL OR NOT EXISTS(SELECT IdRol FROM Roles WHERE IdRol = pIdRol)) THEN
        SELECT 'El rol o perfil de usuario seleccionado es inexistente.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS(SELECT IdRol FROM Roles WHERE IdRol = pIdRol AND Estado = 'A') THEN
        SELECT 'El rol o perfil de usuario seleccionado está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Email FROM Usuarios WHERE IdEmpresa = pIdEmpresa AND Email = pEmail) THEN
        SELECT 'El email ya está en uso por otro usuario del sistema.' Mensaje;
        LEAVE SALIR;
	END IF;
	
    START TRANSACTION;
		SELECT Usuario, IdEmpresa INTO pUsuarioAud, pIdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuarioAud;
        
        SET pToken = (SELECT SHA2(RAND(), 512));
        INSERT INTO Usuarios SELECT 0, pIdRol, pNombres, pApellidos, pUsuario, pPassword, pToken, 
									pEmail, 0, pNow, pNow, 'S', 'A', NULLIF(pObservaciones,''), pIdEmpresa;

		SET pIdUsuario = LAST_INSERT_ID();							
		-- Audita
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioAud,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
        
        SELECT CONCAT('OK', pIdUsuario) Mensaje;
	COMMIT;
END$$

DELIMITER ;