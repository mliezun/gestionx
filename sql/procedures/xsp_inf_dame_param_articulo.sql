DROP procedure IF EXISTS `xsp_inf_dame_param_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_articulo`(pIdEmpresa int, pIds text)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    DECLARE pIdsJson json;

    SET pIdsJson = CAST(CONCAT('[', pIds, ']') as JSON);
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT  IdArticulo Id, CONCAT(a.Articulo, ' (', a.Codigo, ')') Nombre FROM Articulos a
    WHERE IdEmpresa = pIdEmpresa AND Estado = 'A' AND JSON_CONTAINS(pIdsJson, CONCAT('', IdArticulo), '$');
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;