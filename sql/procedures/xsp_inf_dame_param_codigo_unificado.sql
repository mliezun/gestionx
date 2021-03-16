DROP procedure IF EXISTS `xsp_inf_dame_param_codigo_unificado`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_codigo_unificado`(pIdEmpresa int, pIds text)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT  SUBSTRING_INDEX(a.Articulo, ' ', 1) Id, SUBSTRING_INDEX(a.Articulo, ' ', 1) Nombre
    FROM    Articulos a
    WHERE   IdEmpresa = pIdEmpresa AND Estado = 'A'
    GROUP BY Id
    HAVING  FIND_IN_SET(Id, pIds);
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$
DELIMITER ;
