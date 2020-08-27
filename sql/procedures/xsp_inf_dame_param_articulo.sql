DROP procedure IF EXISTS `xsp_inf_dame_param_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_articulo`(pIdEmpresa int, pIds text)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT  IdArticulo Id, CONCAT(a.Articulo, ' (', a.Codigo, ')') Nombre FROM Articulos a
    WHERE IdEmpresa = pIdEmpresa AND Estado = 'A' AND FIND_IN_SET(a.IdArticulo, pIds);
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$
DELIMITER ;
