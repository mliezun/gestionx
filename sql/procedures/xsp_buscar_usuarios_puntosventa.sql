DROP PROCEDURE IF EXISTS `xsp_buscar_usuarios_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_usuarios_puntosventa`(pCadena varchar(100), pIdPuntoVenta bigint)
SALIR: BEGIN
	/*
    Permite buscar usuarios de un punto de venta, indicando una cadena de búsqueda y un punto de venta.
    */
    SELECT		u.*, upv.IdUsuarioPuntoVenta, upv.IdPuntoVenta
	FROM		Usuarios u
	INNER JOIN	UsuariosPuntosVenta upv USING(IdUsuario)
	WHERE		upv.IdPuntoVenta = pIdPuntoVenta
				AND upv.Estado = 'A'
				AND (
					u.Usuario LIKE CONCAT('%', pCadena, '%') OR
					u.Apellidos LIKE CONCAT('%', pCadena, '%') OR
					u.Nombres LIKE CONCAT('%', pCadena, '%')
				);
END$$

DELIMITER ;