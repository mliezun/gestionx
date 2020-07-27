DROP PROCEDURE IF EXISTS `xsp_buscar_parametros`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_parametros`(pHost varchar(255), pCadena varchar(20))
BEGIN
	/*
    Permite buscar los parámetros editables de una empresa dada una cadena de búsqueda, controlando que pertenezcan a módulos activos.
    Para listar todos, cadena vacía.
    */
    DECLARE pIdEmpresa int;
    
    SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost);
    
    SELECT 		p.*, pe.Valor
    FROM 		Empresas e
    INNER JOIN	ModulosEmpresas me USING(IdEmpresa)
    INNER JOIN	Parametros p USING(IdModulo)
    INNER JOIN	ParametroEmpresa pe USING(Parametro, IdEmpresa, IdModulo)
    WHERE 		e.IdEmpresa = pIdEmpresa
				AND p.EsEditable = 'S'
                AND pe.Parametro LIKE CONCAT('%', pCadena, '%');
END$$

DELIMITER ;