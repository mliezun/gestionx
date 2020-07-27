DROP procedure IF EXISTS `xsp_inf_dame_param_tipoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_param_tipoventa`(pIdEmpresa int, pId char(1))
BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT CASE pId
    WHEN 'P' THEN 'Presupuesto'
    WHEN 'C' THEN 'Cotización'
    WHEN 'V' THEN 'Venta'
    WHEN 'B' THEN 'Préstamo'
    WHEN 'G' THEN 'Garantía'
    WHEN 'T' THEN 'Todas'
    END Nombre;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;