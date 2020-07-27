DROP PROCEDURE IF EXISTS `xsp_listar_modulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_modulos`()
BEGIN
	/*
	Permite listar los módulos activos.
    */
    SELECT  *
    FROM    Modulos
    WHERE   Estado = 'A';
END$$

DELIMITER ;