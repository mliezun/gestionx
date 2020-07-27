DROP PROCEDURE IF EXISTS `xsp_buscar_tiposgravamenes`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_tiposgravamenes`(pHost varchar(255), pCadena varchar(30), pIncluyeBajas char(1))
BEGIN
	/*
    Permite buscar los tipos de gravamenes dada una cadena de búsqueda y la opción si incluye o no los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		tg.*
    FROM		TiposGravamenes tg
    WHERE		tg.TipoGravamen LIKE CONCAT('%', pCadena, '%')
                AND (tg.FechaBaja IS NULL OR pIncluyeBajas = 'S');
END$$

DELIMITER ;