DROP PROCEDURE IF EXISTS `xsp_dame_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_articulo`(pIdArticulo bigint)
SALIR: BEGIN
	/*
	Permite instanciar un artículo desde la base de datos.
	*/
    SELECT  a.*, JSON_OBJECTAGG(lp.Lista, pa.PrecioVenta) PreciosVenta, p.Proveedor, ti.TipoIVA
    FROM    Articulos a
    INNER JOIN Proveedores p USING(IdProveedor, IdEmpresa)
    INNER JOIN TiposIVA ti USING(IdTipoIVA)
    INNER JOIN PreciosArticulos pa USING(IdArticulo)
    INNER JOIN ListasPrecio lp USING(IdListaPrecio, IdEmpresa)
    WHERE   a.IdArticulo = pIdArticulo AND lp.Estado = 'A';
END$$

DELIMITER ;