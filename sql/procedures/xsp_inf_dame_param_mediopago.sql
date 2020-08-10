DROP procedure IF EXISTS `xsp_inf_dame_param_mediopago`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_mediopago`(pIdEmpresa int, pId char(1))
PROC: BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    IF pId = 0 THEN 
        SELECT 'Todos' Nombre;
        LEAVE PROC;
    END IF;
    
	SELECT MedioPago Nombre FROM MediosPago WHERE Estado = 'A' AND IdMedioPago = pId;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;