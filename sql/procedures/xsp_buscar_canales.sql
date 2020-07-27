DROP PROCEDURE IF EXISTS `xsp_buscar_canales`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_canales`(pIdEmpresa int, pCadena varchar(30), pIncluye char(1))
BEGIN
	/*
    * Permite buscar canales dentro de una empresa, indicando una cadena de búsqueda
    * y si se incluyen bajas.
    * Para listar todos, cadena vacía.
    */
    SELECT		c.*
    FROM		Canales c
    WHERE		c.IdEmpresa = pIdEmpresa
                AND (c.Canal LIKE CONCAT('%', pCadena, '%'))
                AND (c.Estado = 'A' OR pIncluye = 'S');
END$$

DELIMITER ;