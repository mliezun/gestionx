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