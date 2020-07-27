DROP PROCEDURE IF EXISTS `xsp_buscar_tipos_doc_afip`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_tipos_doc_afip`(pCadena varchar(30), pIncluyeBajas char(1))
BEGIN
	/*
    Permite buscar los tipos de documentos dada una cadena de búsqueda y la opción si incluye o no
    los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		tda.*
    FROM		TiposDocAfip tda
    WHERE		tda.TipoDocAfip LIKE CONCAT('%', pCadena, '%')
                AND (tda.FechaHasta IS NULL OR pIncluyeBajas = 'S');
END$$

DELIMITER ;