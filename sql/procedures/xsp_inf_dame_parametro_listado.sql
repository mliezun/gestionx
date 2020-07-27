DROP procedure IF EXISTS `xsp_inf_dame_parametro_listado`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_parametro_listado`(pIdEmpresa int, pIdModeloReporte int, pNroParametro tinyint, pId varchar(20))
SALIR:BEGIN
	/*
    Permite traer el nombre del elemento de un listado dado el Id.
    */
	DECLARE pProcDame varchar(100);
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SET pProcDame = (SELECT ProcDame FROM ParamsReportes WHERE IdModeloReporte = pIdModeloReporte AND NroParametro = pNroParametro AND Tipo IN('L','A'));
    IF pProcDame IS NULL THEN
		SELECT 'ERROR' Nombre;
        LEAVE SALIR;
	END IF;
		CALL xsp_eval(CONCAT('call ', pProcDame, '("', pIdEmpresa,'", "', pId,'");'));
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;