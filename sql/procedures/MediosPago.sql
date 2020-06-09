DROP PROCEDURE IF EXISTS `xsp_listar_mediospago`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_mediospago`()
BEGIN
	/*
    Permite listar los medios de pago activos.
    */
    SELECT		mp.*
    FROM		MediosPago mp
    WHERE		mp.Estado = 'A';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_listar_tiposcomprobante`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_tiposcomprobante`()
BEGIN
	/*
    Permite listar los tipos de comprobantes activos.
    */
    SELECT		tc.*
    FROM		TiposComprobante tc
    WHERE		tc.Estado = 'A';
END$$
DELIMITER ;

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