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