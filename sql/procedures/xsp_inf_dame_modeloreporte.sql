DROP procedure IF EXISTS `xsp_inf_dame_modeloreporte`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_modeloreporte`(pIdEmpresa int, pIdModeloReporte int)
BEGIN
	/*
    Trae todos los campos de la tabla ModelosReporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT		*
    FROM		ModelosReporte
    WHERE		IdModeloreporte = pIdModeloReporte;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;