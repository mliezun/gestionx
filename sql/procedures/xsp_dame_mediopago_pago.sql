DROP PROCEDURE IF EXISTS `xsp_dame_mediopago_pago`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_mediopago_pago`(pMedioPago varchar(100))
BEGIN
	/*
    Procedimiento que sirve para instanciar un medio de pago desde la base de datos.
    */
	SELECT	mp.IdMedioPago
    FROM	MediosPago mp
    WHERE	mp.MedioPago = pMedioPago
            AND mp.Estado = 'A';
END$$

DELIMITER ;