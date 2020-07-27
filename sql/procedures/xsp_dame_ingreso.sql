DROP PROCEDURE IF EXISTS `xsp_dame_ingreso`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_ingreso`(pIdIngreso bigint)
BEGIN
    /*
    Permite instanciar un ingreso desde la base de datos.
    */
    SELECT * FROM Ingresos WHERE IdIngreso = pIdIngreso;
END$$

DELIMITER ;