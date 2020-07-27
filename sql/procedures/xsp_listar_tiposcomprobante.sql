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