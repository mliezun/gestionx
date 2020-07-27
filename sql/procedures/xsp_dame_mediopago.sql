DROP PROCEDURE IF EXISTS `xsp_dame_mediopago`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_mediopago`(pIdMedioPago smallint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un medio de pago desde la base de datos.
    */
	SELECT	mp.MedioPago
    FROM	MediosPago mp
    WHERE	IdMedioPago = pIdMedioPago;
END$$

DELIMITER ;