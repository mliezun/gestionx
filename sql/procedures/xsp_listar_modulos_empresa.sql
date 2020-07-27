DROP PROCEDURE IF EXISTS `xsp_listar_modulos_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_modulos_empresa`()
BEGIN
	/*
	Permite listar los módulos de una empresa.
    */
    SELECT      m.*
    FROM        ModulosEmpresas me
    INNER JOIN  Modulos m USING(IdModulo)
    WHERE       Estado = 'A' AND IdEmpresa = pIdEmpresa;
END$$

DELIMITER ;