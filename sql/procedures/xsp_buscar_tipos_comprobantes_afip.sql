DROP PROCEDURE IF EXISTS `xsp_buscar_tipos_comprobantes_afip`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_tipos_comprobantes_afip`(pCadena varchar(30), pIncluyeBajas char(1))
BEGIN
	/*
    Permite buscar los tipos de comprobantes dada una cadena de búsqueda y la opción si incluye o no
    los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		tca.*
    FROM		TiposComprobantesAfip tca
    WHERE		tca.TipoComprobanteAfip LIKE CONCAT('%', pCadena, '%')
                AND (tca.FechaHasta IS NULL OR pIncluyeBajas = 'S');
END$$

DELIMITER ;