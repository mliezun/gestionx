DROP PROCEDURE IF EXISTS `xsp_buscar_articulos_por_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_articulos_por_cliente`(pIdEmpresa int, pIdCliente bigint, pCadena varchar(100))
SALIR: BEGIN
	/*
	Permite buscar articulos y su precios para un cliente de una empresa, indicando una cadena de búsqueda.
	*/
    SELECT  a.IdArticulo, a.IdProveedor, a.IdEmpresa, a.IdTipoIVA, a.Codigo, a.Descripcion, a.PrecioCosto, a.Estado, a.FechaAlta,
			CONCAT(a.Articulo, ' (', p.Proveedor, ')') Articulo, IF(pIdCliente = 0, a.PrecioCosto, (SELECT pa.PrecioVenta FROM PreciosArticulos pa INNER JOIN ListasPrecio lp USING(IdListaPrecio) INNER JOIN Clientes USING(IdListaPrecio) WHERE IdCliente = pIdCliente AND pa.IdArticulo = a.IdArticulo)) PrecioVenta
    FROM    Articulos a
    INNER JOIN Proveedores p USING(IdProveedor)
    WHERE   a.IdEmpresa = pIdEmpresa AND a.Estado = 'A'
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%') OR
                    p.Proveedor LIKE CONCAT('%', pCadena, '%')
                )
    GROUP BY a.IdArticulo;
END$$

DELIMITER ;