DROP procedure IF EXISTS `xsp_inf_dame_param_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_cliente`(pIdEmpresa int, pId bigint)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT  IdCliente Id, IF(u.Tipo = 'F', CONCAT(u.Apellidos, ', ', u.Nombres), u.RazonSocial) Nombre FROM Clientes u
    WHERE IdEmpresa = pIdEmpresa AND Estado = 'A' AND IdCliente = pId;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;