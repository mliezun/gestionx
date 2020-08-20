DROP procedure IF EXISTS `xsp_inf_llenar_param_tipoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_llenar_param_tipoventa`(pIdEmpresa int)
BEGIN
	/*
    Permite llenar el parámetro TipoVenta de los modelos de reporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT 'P' Id, 'Presupuesto' Nombre
	UNION
	SELECT 'C' Id, 'Cotización' Nombre
	UNION
	SELECT 'V' Id, 'Venta' Nombre
    UNION
	SELECT 'B' Id, 'Préstamo' Nombre
    UNION
	SELECT 'G' Id, 'Garantía' Nombre
	UNION
	SELECT 'Z' Id, 'Todas las ventas' Nombre
    UNION
	SELECT 'T' Id, 'Todas' Nombre
	;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;