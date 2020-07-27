DROP PROCEDURE IF EXISTS `xsp_login`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `xsp_login`(pHost varchar(255), pUsuario varchar(120), 
			pEsPassValido char(1), pJWT varchar(500), pIP varchar(40), pUserAgent varchar(255), pApp varchar(50))
PROC: BEGIN
	/*
    Permite realizar el login de un usuario indicando la aplicación a la que desea acceder en 
    pApp= A: Administración. Recibe como parámetro la autenticidad del par Usuario - Password 
    en pEsPassValido [S | N]. Controla que el usuario no haya superado el límite de login's 
    erroneos posibles indicado en MAXINTPASS, caso contrario se cambia El estado de la cuenta a
    S: Suspendido. Un intento exitoso de inicio de sesión resetea el contador de intentos fallidos.
    Devuelve un mensaje con el resultado del login y un objeto usuario en caso de login exitoso.
    */
	DECLARE pMAXINTPASS tinyint;
    DECLARE pIdUsuario, pIdEmpresa int;
    -- Manejo de errores en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			-- show errors;
			SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
            ROLLBACK;
		END;
	-- Control de parámetros vacíos
    IF pApp NOT IN ('A') OR pApp IS NULL OR pApp = '' OR pEsPassValido NOT IN ('S','N') 
    OR pEsPassValido IS NULL OR pEsPassValido = '' THEN
		SELECT 'Parámetros incorrectos.' Mensaje;
        LEAVE PROC;
	END IF;
    IF pUsuario IS NULL OR pUsuario = '' THEN
		SELECT 'Debe indicar un usuario.' Mensaje;
        LEAVE PROC;
	END IF;

	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost AND Estado = 'A');
	IF pIdEmpresa IS NULL THEN
		SELECT 'La empresa a la que intenta acceder se encuentra dada de baja.' Mensaje;
        LEAVE PROC;
	END IF;

    SET pIdUsuario = (SELECT IdUsuario FROM Usuarios WHERE Usuario = pUsuario AND IdEmpresa = pIdEmpresa);
    IF pApp = 'A' AND NOT EXISTS (SELECT IdUsuario FROM Usuarios WHERE IdUsuario = pIdUsuario 
    AND IdRol IS NOT NULL) THEN
		SELECT 'No tiene permiso para acceder a esta aplicación.' Mensaje;
        LEAVE PROC;
	END IF;

    IF NOT EXISTS (SELECT IdUsuario FROM Usuarios WHERE IdUsuario = pIdUsuario AND Estado = 'A') THEN
		SELECT 'El usuario indicado no existe en el sistema o se encuentra dado baja.' Mensaje;
        LEAVE PROC;
	END IF;
    
    IF pApp = 'A' AND EXISTS (SELECT IdUsuario FROM Usuarios WHERE IdUsuario = pIdUsuario AND IdRol IS NULL) THEN
		SELECT 'No tiene permisos para acceder a esta aplicación.' Mensaje;
        LEAVE PROC;
	END IF;
    -- Inicializo variables de empresa
    SET pMAXINTPASS = (SELECT Valor FROM ParametroEmpresa WHERE Parametro = 'MAXINTPASS' AND IdEmpresa = pIdEmpresa);
    
	START TRANSACTION;
		CASE pEsPassValido 
        WHEN 'N' THEN 
			BEGIN
				IF (SELECT IntentosPass FROM Usuarios WHERE IdUsuario = pIdUsuario) < pMAXINTPASS THEN
					
                    -- Antes
					INSERT INTO aud_Usuarios
					SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'PASS#INVALIDO', 'A', Usuarios.* 
					FROM Usuarios WHERE IdUsuario = pIdUsuario;
                    
					UPDATE	Usuarios 
					SET		IntentosPass = IntentosPass + 1, FechaUltIntento = NOW()
					WHERE	IdUsuario = pIdUsuario;
                    
                    -- Después
					INSERT INTO aud_Usuarios
					SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'PASS#INVALIDO', 'D', Usuarios.* 
					FROM Usuarios WHERE IdUsuario = pIdUsuario;
					
					SELECT 'Usuario y/o contraseña incorrectos. Ante repetidos intentos fallidos de inicio de sesión, la cuenta se suspenderá.' Mensaje;
					COMMIT;
					LEAVE PROC;
				END IF;
				
				IF (SELECT IntentosPass FROM Usuarios WHERE IdUsuario = pIdUsuario) >= pMAXINTPASS THEN
				
					UPDATE	Usuarios
					SET		Estado = 'S', FechaUltIntento = NOW()
					WHERE	Usuario = pUsuario;
					
					SELECT 'Cuenta suspendida por superar cantidad máxima de intentos de inicio de sesión.' Mensaje;
					COMMIT;
					LEAVE PROC;
				END IF;
			END;
		WHEN 'S' THEN
			BEGIN
            
				-- Antes
				INSERT INTO aud_Usuarios
				SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'LOGIN', 'A', Usuarios.* 
				FROM Usuarios WHERE IdUsuario = pIdUsuario;
                
                UPDATE	Usuarios
                SET		Token = pJWT,
						FechaUltIntento = NOW(),
                        IntentosPass = 0
				WHERE	IdUsuario = pIdUsuario;
                
                -- Después
				INSERT INTO aud_Usuarios 
				SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pApp, 'LOGIN', 'D', Usuarios.* 
				FROM Usuarios WHERE IdUsuario = pIdUsuario;
                
                INSERT INTO	SesionesUsuarios
                SELECT		0, pIdUsuario, NOW(), NULL, pIP, pApp, pUserAgent;
                
                COMMIT;
            END;
        END CASE;     
	CASE pApp
		WHEN 'A' THEN
			SELECT 		'OK' Mensaje, u.IdUsuario, u.IdRol, u.Nombres, u.Apellidos, u.Usuario,
						u.Token, u.Email, u.DebeCambiarPass, u.Estado, r.Rol, upv.IdUsuarioPuntoVenta, upv.IdPuntoVenta
			FROM 		Usuarios u
            INNER JOIN 	Roles r ON r.IdRol = u.IdRol
			LEFT JOIN 	(SELECT * FROM UsuariosPuntosVenta WHERE IdUsuario = pIdUsuario AND Estado = 'A') upv USING(IdUsuario)
			WHERE		IdUsuario = pIdUsuario;
	END CASE;
END$$

DELIMITER ;