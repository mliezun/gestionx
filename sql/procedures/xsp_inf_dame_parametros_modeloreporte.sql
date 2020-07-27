DROP procedure IF EXISTS `xsp_inf_dame_parametros_modeloreporte`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_parametros_modeloreporte`(pIdEmpresa int, pIdModeloReporte int, pTipoOrden char(1))
BEGIN
	/*
    Trae todos los parámetros de un modelo de reporte ordenados por pTipoOrden: P: Parámetro - F: Formulario.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    IF pTipoOrden = 'P' THEN
		SELECT		*
		FROM		ParamsReportes
		WHERE		IdModeloReporte = pIdModeloReporte
		ORDER BY	NroParametro;
	ELSE
		SELECT		*
		FROM		ParamsReportes
		WHERE		IdModeloReporte = pIdModeloReporte
		ORDER BY	OrdenForm;
    END IF;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;