DROP PROCEDURE IF EXISTS `xsp_buscar_remitos`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_remitos`(pIdEmpresa int, pCadena varchar(30), pEstado char(1), pIdProveedor bigint, pIdPuntoVenta bigint, pIdCanal bigint, pIncluyeUtilizados char(1))
BEGIN
	/*
    Permite buscar los remitos dada una cadena de búsqueda y estado (T: todos los estados).
	Para listar todos los remitos para un punto de venta si IdPuntoVenta es 0.
    */
    SELECT		r.*, i.IdIngreso, p.Proveedor, c.Canal
    FROM		Remitos r
	INNER JOIN	Ingresos i USING(IdRemito)
	INNER JOIN	Proveedores p USING(IdProveedor)
	INNER JOIN	Canales c USING(IdCanal)
    WHERE		r.IdEmpresa = pIdEmpresa
				AND (r.NroRemito IS NULL OR CONCAT(r.NroRemito,'') LIKE CONCAT('%', pCadena, '%'))
				-- AND (r.CAI IS NULL OR CONCAT(r.CAI,'') LIKE CONCAT('%', pCadena, '%'))
                AND (r.Estado = pEstado OR pEstado = 'T')
				AND (r.IdProveedor = pIdProveedor OR pIdProveedor=0)
				AND (i.IdPuntoVenta = pIdPuntoVenta OR pIdPuntoVenta=0)
				AND (r.IdCliente IS NULL OR pIncluyeUtilizados = 'S')
				AND (c.IdCanal = pIdCanal OR pIdCanal=0)
	ORDER BY 1 DESC;
END$$

DELIMITER ;