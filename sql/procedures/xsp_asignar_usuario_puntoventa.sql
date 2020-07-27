DROP PROCEDURE IF EXISTS `xsp_asignar_usuario_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_asignar_usuario_puntoventa`(pToken varchar(500), pIdUsuario bigint, pIdPuntoVenta bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite asignar el punto de venta al que pertenece un usuario, controlando que ambos pertenezcan a la misma empresa.
	Un usuario sólo puede pertenecer a un punto de venta. Por lo tanto se dan de baja las pertenencias anteriores y se 
	da de alta la nueva en estado activo.
	Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuarioAud, pIdEmpresa bigint;
	DECLARE pIdRol int;
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_asignar_usuario_puntoventa', pMensaje, pIdUsuarioAud);
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
    IF NOT EXISTS(SELECT IdUsuario FROM Usuarios u INNER JOIN Empresas e USING(IdEmpresa)
				INNER JOIN PuntosVenta pv USING(IdEmpresa) WHERE u.IdUsuario = pIdUsuario AND pv.IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'El usuario y el punto de venta no pertenecen a la misma empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	SET pIdRol = (SELECT IdRol FROM Roles INNER JOIN ParametroEmpresa USING(IdEmpresa) WHERE Parametro = 'ROLVENDEDOR' AND IdEmpresa = pIdEmpresa AND Valor = Rol);
	IF NOT EXISTS (SELECT IdUsuario FROM Usuarios WHERE IdUsuario = pIdUsuario AND IdRol = pIdRol) THEN
		SELECT 'El usuario no es vendedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    
	START TRANSACTION;
		
		UPDATE UsuariosPuntosVenta SET Estado = 'B' WHERE IdUsuario = pIdUsuario;

		INSERT INTO UsuariosPuntosVenta SELECT 0, pIdPuntoVenta, pIdUsuario, 'A'
		ON DUPLICATE KEY UPDATE Estado = 'A';
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;