DROP PROCEDURE IF EXISTS `xsp_dame_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_empresa`(pIdEmpresa int)
BEGIN
	/*
    Permite instanciar una empresa desde la base de datos.
    */
    SELECT * FROM Empresas WHERE IdEmpresa = pIdEmpresa;
END$$

DELIMITER ;