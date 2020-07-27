DROP PROCEDURE IF EXISTS `xsp_dame_parametro`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_parametro`(pHost varchar(255), pParametro varchar(20))
BEGIN
	/*
    Permite instanciar un parámetro de empresa desde la base de datos.
    */
    DECLARE pIdEmpresa int;
    
    SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost);
    
    SELECT		p.*, pe.Valor
    FROM		Empresas e
    INNER JOIN	ModulosEmpresas me USING(IdEmpresa)
    INNER JOIN	Parametros p USING(IdModulo)
    INNER JOIN	ParametroEmpresa pe USING(Parametro, IdEmpresa, IdModulo)
    WHERE		p.Parametro = pParametro AND e.IdEmpresa = pIdEmpresa;
END$$

DELIMITER ;