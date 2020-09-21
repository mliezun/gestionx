DROP PROCEDURE IF EXISTS `xsp_buscar_articulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_articulos`(pIdEmpresa int, pOffset bigint, pLimit bigint, pIdProveedor bigint, pIdListaPrecio bigint, pCadena varchar(100), pIncluyeBajas char(1), pIncluyeBajasListas char(1))
SALIR: BEGIN
	/*
	Permite buscar articulos dentro de un proveedor de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas. Si pIdProveedor = 0 lista para todos los proveedores activos de una empresa.
	*/
    SELECT  a.*, JSON_OBJECTAGG(lp.Lista, pa.PrecioVenta) PreciosVenta, p.Proveedor, ti.TipoIVA,
            f_calcular_precio_articulo(a.IdArticulo, p.Descuento, 0) PrecioCompra, f_existencias_articulo(IdArticulo) Existencias
    FROM       Articulos a
    INNER JOIN Proveedores p USING(IdProveedor, IdEmpresa)
    INNER JOIN TiposIVA ti USING(IdTipoIVA)
    INNER JOIN PreciosArticulos pa USING(IdArticulo)
    INNER JOIN ListasPrecio lp USING(IdListaPrecio, IdEmpresa)
    WHERE   a.IdEmpresa = pIdEmpresa
            AND (pIdListaPrecio = 0 OR lp.IdListaPrecio = pIdListaPrecio)
            AND (pIdProveedor = 0 OR a.IdProveedor = pIdProveedor)
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%')
                )
            AND (pIncluyeBajas = 'S' OR a.Estado = 'A')
            AND (pIncluyeBajasListas = 'S' OR lp.Estado = 'A')
    GROUP BY a.IdArticulo
    ORDER BY p.Proveedor, a.Articulo
    LIMIT pOffset, pLimit
    ;
END$$

DELIMITER ;