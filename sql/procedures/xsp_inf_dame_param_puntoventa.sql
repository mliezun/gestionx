DROP procedure IF EXISTS `xsp_inf_dame_param_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_puntoventa`(pIdEmpresa int, pId varchar(20))
BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT PuntoVenta Nombre FROM PuntosVenta WHERE IdEmpresa = pIdEmpresa AND IdPuntoVenta = pId;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;