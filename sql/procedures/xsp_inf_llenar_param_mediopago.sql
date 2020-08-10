DROP procedure IF EXISTS `xsp_inf_llenar_param_mediopago`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_llenar_param_mediopago`(pIdEmpresa int)
PROC: BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT IdMedioPago Id, MedioPago Nombre FROM MediosPago WHERE Estado = 'A'
    UNION
    SELECT 0 Id, 'Todos' Nombre;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;