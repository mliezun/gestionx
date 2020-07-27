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