DROP PROCEDURE IF EXISTS `xsp_dame_lineas_ingreso`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_lineas_ingreso`(pIdIngreso bigint)
SALIR: BEGIN
    /*
	Permite listar las líneas de un ingreso.
	*/
	SELECT li.*, a.Articulo FROM LineasIngreso li INNER JOIN Articulos a USING(IdArticulo) WHERE li.IdIngreso = pIdIngreso;
END$$

DELIMITER ;