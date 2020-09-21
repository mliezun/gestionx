DROP procedure IF EXISTS `xsp_inf_llenar_listado_parametro`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_llenar_listado_parametro`(pIdEmpresa int, pIdModeloReporte int, pNroParametro tinyint, pCadena varchar(300))
SALIR:BEGIN
	/*
    Permite traer un resultset de forma {Id,Nombre} para poblar la lista del parámetro que debe ser de tipo L: Listado o A: Autocompletar.
    En este último caso, debe pasarse el parámetro pCadena; en otro caso, pasar ''. Lo ordena por nombre. No incluye el TODOS.
    */
	DECLARE pProcLlenado varchar(100);
    DECLARE pTipo char(1);
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SET pProcLlenado = (SELECT ProcLlenado FROM ParamsReportes WHERE IdModeloReporte = pIdModeloReporte AND NroParametro = pNroParametro AND Tipo IN('L','A', 'S'));
    SET pTipo = (SELECT Tipo FROM ParamsReportes WHERE IdModeloReporte = pIdModeloReporte AND NroParametro = pNroParametro AND Tipo IN ('L','A', 'S'));
    IF pProcLlenado IS NULL THEN
		SELECT 0 Id, 'ERROR' Nombre;
        LEAVE SALIR;
	END IF;
    IF pTipo = 'L' THEN
		CALL xsp_eval(CONCAT('call ', pProcLlenado, '("', pIdEmpresa, '");'));
	ELSE
		CALL xsp_eval(CONCAT('call ', pProcLlenado, '("', pIdEmpresa, '", \'',REPLACE(pCadena,"'","\\'"),'\');'));
  END IF;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;