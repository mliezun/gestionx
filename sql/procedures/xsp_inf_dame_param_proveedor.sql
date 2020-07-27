DROP procedure IF EXISTS `xsp_inf_dame_param_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_proveedor`(pIdEmpresa int, pId bigint)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT  IdProveedor Id, Proveedor Nombre FROM Proveedores p
    WHERE IdEmpresa = pIdEmpresa AND Estado = 'A' AND IdProveedor = pId;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;