DROP procedure IF EXISTS `xsp_inf_dame_param_vendedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_vendedor`(pIdEmpresa int, pId bigint)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT  IdUsuario Id, CONCAT(u.Apellidos, ', ', u.Nombres) Nombre FROM Usuarios u
    WHERE IdEmpresa = pIdEmpresa AND Estado = 'A' AND IdUsuario = pId;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;