DROP PROCEDURE IF EXISTS `xsp_buscar_tipos_tributos`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_tipos_tributos`(pCadena varchar(30), pIncluyeBajas char(1))
BEGIN
	/*
    Permite buscar los tipos de tributos dada una cadena de búsqueda y la opción si incluye o no
    los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		tt.*
    FROM		TiposTributos tt
    WHERE		tt.TipoTributo LIKE CONCAT('%', pCadena, '%')
                AND (tt.FechaHasta IS NULL OR pIncluyeBajas = 'S');
END$$

DELIMITER ;