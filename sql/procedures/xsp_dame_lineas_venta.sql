DROP PROCEDURE IF EXISTS `xsp_dame_lineas_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_lineas_venta`(pIdVenta bigint)
SALIR: BEGIN
    /*
	* Permite listar las líneas de una venta.
	*/
	SELECT lv.*, a.Articulo FROM LineasVenta lv INNER JOIN Articulos a USING(IdArticulo) WHERE lv.IdVenta = pIdVenta;
END$$

DELIMITER ;