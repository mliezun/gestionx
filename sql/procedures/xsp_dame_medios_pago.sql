DROP PROCEDURE IF EXISTS `xsp_dame_medios_pago`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_medios_pago`()
SALIR: BEGIN
    /*
	* Permite listar los medios de pago activos.
	*/
	SELECT mp.* FROM MediosPago mp WHERE mp.Estado = 'A';
END$$

DELIMITER ;