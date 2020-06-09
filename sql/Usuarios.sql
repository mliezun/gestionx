DROP PROCEDURE IF EXISTS `xsp_activar_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_usuario`(pToken varchar(500), pIdUsuario int, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite cambiar el estado del Usuario a Activo siempre y cuando no esté activo ya y no sea cliente. 
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuarioAud bigint;
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_usuario', pMensaje, pIdUsuarioAud);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros vacíos
    IF pIdUsuario IS NULL THEN
		SELECT 'Debe indicar un usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros incorrectos
    IF EXISTS(SELECT Estado FROM Usuarios WHERE IdUsuario = pIdUsuario AND IdRol IS NULL) THEN
		SELECT 'No se puede activar. El usuario es un cliente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Usuarios WHERE IdUsuario = pIdUsuario AND Estado = 'A') THEN
		SELECT 'El usuario ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
	START TRANSACTION;
		SET pUsuarioAud = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioAud);
		-- Auditoría antes
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioAud,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
		-- Activa
		UPDATE Usuarios SET Estado = 'A' WHERE IdUsuario = pIdUsuario;
		-- Auditoría después
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioAud,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


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


DROP PROCEDURE IF EXISTS `xsp_borra_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_usuario`(pToken varchar(500), pIdUsuario int, 
			pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite borrar un Usuario existente controlando que no existan Puntos de Venta asociados. Borra el historial de Passwords. 
    No puede borrar el usuario 1, administrador. Devuelve OK o el mensaje de error en Mensaje.
    
    */
    DECLARE pIdUsuarioAud bigint;
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_usuario', pMensaje, pIdUsuarioAud);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF pIdUsuario = 1 THEN
		SELECT 'No puede borrar el usuario administrador.' Mensaje;
		LEAVE SALIR;
	END IF;
    -- Control de parámetros incorrectos
	IF EXISTS(SELECT IdUsuario FROM UsuariosPuntosVenta WHERE IdUsuario = pIdUsuario) THEN
		SELECT 'No se puede borrar el usuario. Existen puntos de venta asociados.' Mensaje;
		LEAVE SALIR; 
	END IF;
    -- Borra el usuario
    START TRANSACTION;
		SET pUsuarioAud = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioAud);
        DELETE FROM PassUsuarios WHERE IdUsuario = pIdUsuario;
		-- Audito
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioAud,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'BORRA', 'B', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
        DELETE FROM Usuarios WHERE IdUsuario = pIdUsuario;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_buscar_usuarios`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_usuarios`(pHost varchar(255), pCadena varchar(30), pEstado char(1), pIdRol int)
BEGIN
	/*
    Permite buscar los usuarios de una empresa dada una cadena de búsqueda, estado (T: todos los estados),
    Rol (0: todos los roles). Si la cadena de búsqueda es un texto, busca por usuario, apellido
    y nombre. Para listar todos, cadena vacía.
    */
	SELECT		u.*, r.Rol
    FROM		Usuarios u
    INNER JOIN	Empresas e USING(IdEmpresa)
    INNER JOIN	Roles r USING(IdRol)
    WHERE		e.URL = pHost
				AND (u.Estado = pEstado OR pEstado = 'T')
                AND (u.IdRol = pIdRol OR pIdRol = 0)
                AND (
						u.Usuario LIKE CONCAT('%', pCadena, '%') OR
                        CONCAT_WS(',', u.Apellidos, u.Nombres) LIKE CONCAT('%', pCadena, '%')
					)
	ORDER BY	u.Apellidos, u.Nombres;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_cambiar_password`;
DELIMITER $$
CREATE PROCEDURE `xsp_cambiar_password`(pModo char(1), pToken varchar(500),
											pPasswordNew varchar(255),
											pIP varchar(40), pUserAgent varchar(255), pApp varchar(50))
SALIR: BEGIN
	/*
    Permite cambiar la contraseña por el hash recibido como parámetro. Al recibir un hash
    no puede controlarse que cumpla con las políticas de contraseñas.
    El token debe ser de un cliente existente, en estado activo.
    Cuando pModo = U, debe pasar el token de sesión, el usuario debe existir, estar activo y 
    debe ingresar la contraseña anterior. Devuelve OK o el mensaje de error en Mensaje.
    Cuando pModo = R, se utiliza para rehash. Debe pasar el token de sesión, el usuario debe 
    existir, estar activo. Sólo actualiza hash en la tabla Usuarios sin agregar al historial.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    
    DECLARE pIdUsuario int;
	DECLARE pUsuario varchar(120);
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controlo parámetros
    IF pModo IN ('U','R', 'C') AND NOT EXISTS(SELECT Token FROM Usuarios WHERE Token = pToken) THEN
		SELECT 'No se puede cambiar la contraseña. No es una sesión válida.' Mensaje;
        LEAVE SALIR;
    END IF;
	IF pModo IN ('U','R', 'C') AND NOT EXISTS(SELECT Token FROM Usuarios WHERE Token = pToken AND Estado = 'A') THEN
		SELECT 'No se puede cambiar la contraseña. El usuario no está activo.' Mensaje;
        LEAVE SALIR;
	END IF;

    SET pIdUsuario = (SELECT IdUsuario FROM Usuarios WHERE Token = pToken);
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        IF pModo = 'R' THEN
			
			SET pToken = MD5(RAND());
            
			-- Auditoría
			INSERT INTO aud_Usuarios
			SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'REHASH', 'A', Usuarios.* 
			FROM Usuarios WHERE IdUsuario = pIdUsuario;
			
			UPDATE 	Usuarios 
            SET 	Password = pPasswordNew
			WHERE 	IdUsuario = pIdUsuario;
            
            -- Auditoría
			INSERT INTO aud_Usuarios
			SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'REHASH', 'D', Usuarios.* 
			FROM Usuarios WHERE IdUsuario = pIdUsuario;
			
        END IF;
        
        IF pModo IN ('U','C') THEN
			
			SET pToken = IF(pModo = 'U',MD5(RAND()), pToken);
            
            -- Auditoría
			INSERT INTO aud_Usuarios
			SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'CAMBIAR#PASS', 'A', Usuarios.* 
			FROM Usuarios WHERE IdUsuario = pIdUsuario;
			
			UPDATE 	Usuarios 
            SET 	Password = pPasswordNew, 
					DebeCambiarPass = 'N', 
                    FechaUltIntento = NOW(),
					Token = pToken ,
                    IntentosPass = 0
			WHERE 	IdUsuario = pIdUsuario;
            
            -- Auditoría
			INSERT INTO aud_Usuarios
			SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'CAMBIAR#PASS', 'D', Usuarios.* 
			FROM Usuarios WHERE IdUsuario = pIdUsuario;
			
			
		END IF;
		SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_dame_password_hash`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_password_hash`(pHost varchar(255), pUsuario varchar(120))
BEGIN
	/*
    Permite obtener el password hash de un usuario a partir de su documento.
    */
	DECLARE pIdEmpresa int;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost AND Estado = 'A');
	IF EXISTS (SELECT Usuario FROM Usuarios WHERE Usuario = pUsuario AND IdEmpresa = pIdEmpresa) THEN
		SELECT	Password 
        FROM	Usuarios
        WHERE	Usuario = pUsuario AND IdEmpresa = pIdEmpresa;
	ELSE
		SELECT NULL Password;
	END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_permisos_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_permisos_usuario`(pJWT varchar(500))
BEGIN
	/*
    Permite devolver en un resultset la lista de variables de permiso que el
	usuario tiene habilitados. Se valida con el token de sesión.
    */
    SELECT	Permiso
    FROM	Permisos p INNER JOIN PermisosRol pr USING(IdPermiso)
    WHERE	IdRol = (SELECT	IdRol FROM Usuarios WHERE Token = pJWT);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_usuario`(pIdUsuario int)
PROC: BEGIN
	/*
    Permite instanciar un usuario desde la base de datos.
    */
    
    SELECT	u.*, upv.IdUsuarioPuntoVenta, upv.IdPuntoVenta
    FROM 	Usuarios u
	LEFT JOIN (SELECT * FROM UsuariosPuntosVenta WHERE IdUsuario = pIdUsuario AND Estado = 'A') upv USING(IdUsuario)
    WHERE	u.IdUsuario = pIdUsuario;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_usuario_por_token`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `xsp_dame_usuario_por_token`(pJWT varchar(500))
BEGIN
	/*
    Permite instanciar un usuario a partir de su token. Cambia la salida dependiendo de si
	es un usuario administrador o un usuario cliente.
    */
    IF EXISTS (SELECT IdUsuario FROM Usuarios WHERE Token = pJWT AND IdRol IS NOT NULL) THEN
		SELECT 		'OK' Mensaje, u.*, r.Rol, upv.IdUsuarioPuntoVenta, upv.IdPuntoVenta
		FROM 		Usuarios u
		INNER JOIN 	Roles r ON r.IdRol = u.IdRol
		LEFT JOIN 	(SELECT * FROM UsuariosPuntosVenta WHERE IdUsuario = pIdUsuario AND Estado = 'A') upv USING(IdUsuario)
		WHERE		u.Token = pJWT;
	END IF;
	SELECT 'Error al ingresar. Contáctese con el administrador.' Mensaje;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_usuario_por_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_usuario_por_usuario`(pUsuario varchar(120))
BEGIN
	/*
    Permite instanciar un usuario por Usuario desde la base de datos.
    */
    SELECT		u.*, upv.IdUsuarioPuntoVenta, upv.IdPuntoVenta
    FROM		Usuarios u
	LEFT JOIN 	(SELECT * FROM UsuariosPuntosVenta WHERE IdUsuario = pIdUsuario AND Estado = 'A') upv USING(IdUsuario)
    WHERE		Usuario = pUsuario;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_usuario`(pToken varchar(300), pIdUsuario int, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite cambiar el estado del Usuario a Baja siempre y cuando no esté dado de baja ya y no sea cliente. 
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuarioAud bigint;
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_usuario', pMensaje, pIdUsuarioAud);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros vacíos
    IF pIdUsuario IS NULL THEN
		SELECT 'Debe indicar un usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros incorrectos
    IF EXISTS(SELECT Estado FROM Usuarios WHERE IdUsuario = pIdUsuario AND IdRol IS NULL) THEN
		SELECT 'No se puede dar de baja. El usuario es un cliente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Usuarios WHERE IdUsuario = pIdUsuario AND Estado = 'B') THEN
		SELECT 'El usuario ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
	START TRANSACTION;
		SET pUsuarioAud = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioAud);
		-- Auditoría antes
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioAud,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
		-- Da de baja
		UPDATE Usuarios SET Estado = 'B' WHERE IdUsuario = pIdUsuario;
		-- Auditoría después
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioAud,'@',pUsuarioAud), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


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


DROP PROCEDURE IF EXISTS `xsp_restablecer_password`;
DELIMITER $$
CREATE PROCEDURE `xsp_restablecer_password`(pToken varchar(500), pIdUsuario bigint, pPassword varchar(255),  pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite setear DebeCambiarPass en S y setear un nuevo Password, para un usuario indicado.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_restablecer_password', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdUsuario IS NULL OR pIdUsuario = 0) THEN
        SELECT 'Debe indicar un usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF NOT EXISTS (SELECT IdUsuario FROM Usuarios WHERE IdUsuario = pIdUsuario) THEN
        SELECT 'El usuario indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdUsuario FROM Usuarios WHERE IdUsuario = pIdUsuario AND Estado = 'A') THEN
        SELECT 'El usuario indicado no está activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audita Antes
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'RESTABLECE#PASS', 'A', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;

		-- Modifica
        UPDATE 	Usuarios 
		SET		DebeCambiarPass='S',
				Password=pPassword,
				Token=SHA2(RAND(),512)
		WHERE	IdUsuario=pIdUsuario;
		
		-- Audita despues
		INSERT INTO aud_Usuarios
		SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'RESTABLECE#PASS', 'D', Usuarios.* 
        FROM Usuarios WHERE IdUsuario = pIdUsuario;

        SELECT 'OK' Mensaje;

	COMMIT;
END$$
DELIMITER ;
