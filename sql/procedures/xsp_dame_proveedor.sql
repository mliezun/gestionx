DROP PROCEDURE IF EXISTS `xsp_dame_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_proveedor`(pIdProveedor bigint)
SALIR: BEGIN
	/*
	Permite instaciar un proveedor desde la base de datos.
	*/
    SELECT  p.*, - cc.Monto Deuda
    FROM    Proveedores p
    INNER JOIN CuentasCorrientes cc ON cc.IdEntidad = p.IdProveedor AND cc.Tipo = 'P'
    WHERE   p.IdProveedor = pIdProveedor;
END$$

DELIMITER ;