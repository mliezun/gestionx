DROP procedure IF EXISTS `xsp_inf_ejecutar_reporte`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_ejecutar_reporte`(pIdEmpresa int, pIdModeloReporte int, pCadenaParametros text)
BEGIN
	/*
    Permite traer el resultset del reporte. Para ello trae el nombre del SP de la tabla ModelosReporte.
    */
	DECLARE pProcedimiento varchar(100);
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW errors;
		SELECT 'Error' Mensaje;
	END;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SET pProcedimiento = (SELECT Procedimiento FROM ModelosReporte WHERE IdModeloReporte = pIdModeloReporte);
	IF pProcedimiento IS NULL THEN
		SELECT 'Error' AS Mensaje;
	END IF;
	CALL xsp_eval(CONCAT('call ', pProcedimiento, '("', pIdEmpresa, '", ', pCadenaParametros,');'));
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;