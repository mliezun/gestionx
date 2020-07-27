DROP PROCEDURE IF EXISTS `xsp_listar_existencias_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_existencias_puntosventa`(pCadena varchar(100), pIdPuntoVenta bigint, pSinStock char(1), pIdCanal bigint)
BEGIN
	/**
    * Procedimiento que sirve para listar las existencias de un punto venta desde la base de datos.
    */
	SELECT	a.Articulo, a.Codigo, a.Descripcion, a.PrecioCosto, ec.Cantidad, c.Canal, p.Proveedor
    FROM	PuntosVenta pv
	INNER JOIN ExistenciasConsolidadas ec USING (IdPuntoVenta)
	INNER JOIN Articulos a USING (IdArticulo)
    INNER JOIN Proveedores p USING (IdProveedor)
	INNER JOIN Canales c USING (IdCanal)
    WHERE	pv.IdPuntoVenta = pIdPuntoVenta AND a.Estado = 'A'
			AND (c.IdCanal = pIdCanal OR pIdCanal = 0) AND c.Estado = 'A'
			AND (ec.Cantidad != 0 OR pSinStock = 'S')
			AND (
					a.Articulo LIKE CONCAT('%', pCadena, '%') OR
					a.Codigo LIKE CONCAT('%', pCadena, '%') OR
					a.Descripcion LIKE CONCAT('%', pCadena, '%')
				);
END$$

DELIMITER ;