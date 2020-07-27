DROP PROCEDURE IF EXISTS `xsp_dame_tipos_comprobantes`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_tipos_comprobantes`()
SALIR: BEGIN
    /*
	* Permite listar los tipos de comprobantes activos.
	*/
	SELECT tc.* FROM TiposComprobante tc WHERE tc.Estado = 'A';
END$$

DELIMITER ;