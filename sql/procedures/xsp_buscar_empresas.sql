DROP PROCEDURE IF EXISTS `xsp_buscar_empresas`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_empresas`(pCadena varchar(100), pIncluyeBajas char(1))
BEGIN
	/*
	Permite buscar empresas por una Cadena de búsqueda indicando si se incluyen o no las dadas
    de baja. Cadena vacía para listar todas.
    */
    SELECT  *
    FROM    Empresas
    WHERE   Empresa LIKE CONCAT('%', pCadena, '%')
            AND (Estado = 'A' OR pIncluyeBajas = 'S');
END$$

DELIMITER ;