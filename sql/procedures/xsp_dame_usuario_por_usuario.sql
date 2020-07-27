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