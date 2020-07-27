DROP PROCEDURE IF EXISTS `xsp_dame_datos_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_datos_empresa`(pHost varchar(255))
BEGIN
	/*
    Permite obtener los parámetros de la empresa que necesitan cargarse al inicio de sesión (EsInicial = S), verificando que los parámetros pertenezcan a módulos activos de la empresa.
    */
    DECLARE pIdEmpresa int;
    
    SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost);
    
    SELECT		p.*, pe.Valor
    FROM		Parametros p
    INNER JOIN	ModulosEmpresas me USING(IdModulo)
    INNER JOIN	ParametroEmpresa pe USING(Parametro, IdEmpresa, IdModulo)
    WHERE		p.EsInicial = 'S' AND me.IdEmpresa = pIdEmpresa;
END$$

DELIMITER ;