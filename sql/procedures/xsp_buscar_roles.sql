DROP PROCEDURE IF EXISTS `xsp_buscar_roles`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_roles`(pHost varchar(255), pCadena varchar(30), pEstado char(1))
BEGIN
	/*
    Permite buscar los roles dada una cadena de búsqueda y la opción si incluye o no los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		r.*
    FROM		Roles r
    INNER JOIN	Empresas e USING(IdEmpresa)
    WHERE		e.URL = pHost
				AND r.Rol LIKE CONCAT('%', pCadena, '%')
                AND (r.Estado = pEstado OR pEstado = 'T');
END$$

DELIMITER ;