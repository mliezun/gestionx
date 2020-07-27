DROP PROCEDURE IF EXISTS `xsp_listar_sesiones_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_sesiones_usuario`(pIdUsuario bigint)
PROC: BEGIN
	/*
    Permite listar las sesiones de un usuario.
    */
	SELECT * FROM SesionesUsuarios WHERE IdUsuario = pIdUsuario ORDER BY FechaInicio DESC;
END$$

DELIMITER ;