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