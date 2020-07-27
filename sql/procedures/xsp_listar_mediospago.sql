DROP PROCEDURE IF EXISTS `xsp_listar_mediospago`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_mediospago`()
BEGIN
	/*
    Permite listar los medios de pago activos.
    */
    SELECT		mp.*
    FROM		MediosPago mp
    WHERE		mp.Estado = 'A'
    ORDER BY    mp.MedioPago;
END$$

DELIMITER ;