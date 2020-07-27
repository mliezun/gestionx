DROP PROCEDURE IF EXISTS `xsp_buscar_articulos_autocompletado`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_articulos_autocompletado`(pIdEmpresa int, pCadena varchar(100))
SALIR: BEGIN
	/*
	Permite buscar articulos dentro de un proveedor de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas. Si pIdProveedor = 0 lista para todos los proveedores activos de una empresa.
	*/
    SELECT  a.*, CONCAT(a.Articulo, ' (', a.Codigo, ') [', p.Proveedor, ']') NombreArticulo
    FROM    Articulos a
    INNER JOIN  Proveedores p USING(IdProveedor)
    WHERE   a.IdEmpresa = pIdEmpresa
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%') OR
                    p.Proveedor LIKE CONCAT('%', pCadena, '%')
                )
            AND (a.Estado = 'A');
END$$

DELIMITER ;