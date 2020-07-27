DROP PROCEDURE IF EXISTS `xsp_dame_cantidad_articulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_cantidad_articulos`(pIdEmpresa int)
BEGIN
    /*
    Permite obtener la cantidad de artículos de una empresa.
    */
    SELECT COUNT(IdArticulo) Total FROM Articulos WHERE IdEmpresa = pIdEmpresa;
END$$

DELIMITER ;