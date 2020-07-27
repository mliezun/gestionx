DROP PROCEDURE IF EXISTS `xsp_buscar_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_puntosventa`(pHost varchar(255), pCadena varchar(30), pEstado char(1))
BEGIN
	/**
	Permite buscar los puntos venta dada una cadena de búsqueda y estado (T: todos los estados).
	Para listar todos, cadena vacía.
	xsp_buscar_puntosventa
    */
    SELECT		p.*
    FROM		PuntosVenta p
    INNER JOIN	Empresas e USING(IdEmpresa)
    WHERE		e.URL = pHost
				AND p.PuntoVenta LIKE CONCAT('%', pCadena, '%')
                AND (p.Estado = pEstado OR pEstado = 'T');
END$$

DELIMITER ;