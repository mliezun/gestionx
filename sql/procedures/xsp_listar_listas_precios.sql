DROP PROCEDURE IF EXISTS `xsp_listar_listas_precios`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_listas_precios`()
BEGIN
	/*
    Permite listar las listas de precios activas.
    */
    SELECT		lp.*
    FROM		ListasPrecio lp
    WHERE		lp.Estado = 'A';
END$$

DELIMITER ;