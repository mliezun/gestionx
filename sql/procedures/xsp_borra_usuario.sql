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