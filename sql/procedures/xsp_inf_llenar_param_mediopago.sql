DROP procedure IF EXISTS `xsp_inf_llenar_param_mediopago`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_llenar_param_mediopago`(pIdEmpresa int, pId char(1))
PROC: BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    IF pId = 0 THEN 
        SELECT 'Todos' Nombre;
        LEAVE PROC;
    END IF;

    SELECT MedioPago Nombre FROM MediosPago WHERE IdMedioPago = pId;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;