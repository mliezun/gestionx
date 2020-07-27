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