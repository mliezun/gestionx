DROP PROCEDURE IF EXISTS `xsp_buscar_usuarios`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_usuarios`(pHost varchar(255), pCadena varchar(30), pEstado char(1), pIdRol int)
BEGIN
	/*
    Permite buscar los usuarios de una empresa dada una cadena de búsqueda, estado (T: todos los estados),
    Rol (0: todos los roles). Si la cadena de búsqueda es un texto, busca por usuario, apellido
    y nombre. Para listar todos, cadena vacía.
    */
	SELECT		u.*, r.Rol
    FROM		Usuarios u
    INNER JOIN	Empresas e USING(IdEmpresa)
    INNER JOIN	Roles r USING(IdRol)
    WHERE		e.URL = pHost
				AND (u.Estado = pEstado OR pEstado = 'T')
                AND (u.IdRol = pIdRol OR pIdRol = 0)
                AND (
						u.Usuario LIKE CONCAT('%', pCadena, '%') OR
                        CONCAT_WS(',', u.Apellidos, u.Nombres) LIKE CONCAT('%', pCadena, '%')
					)
	ORDER BY	u.Apellidos, u.Nombres;
END$$

DELIMITER ;