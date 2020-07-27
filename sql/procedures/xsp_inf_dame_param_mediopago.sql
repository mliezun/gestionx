DROP procedure IF EXISTS `xsp_inf_dame_param_mediopago`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_mediopago`(pIdEmpresa int)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT  IdMedioPago Id, MedioPago Nombre FROM MediosPago WHERE Estado = 'A'
    UNION
    SELECT  0, 'Todos';
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;