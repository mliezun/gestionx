DROP PROCEDURE IF EXISTS `xsp_buscar_tipos_iva`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_tipos_iva`(pCadena varchar(30), pIncluyeBajas char(1))
BEGIN
	/*
    Permite buscar los tipos de iva dada una cadena de búsqueda y la opción si incluye o no
    los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		ti.*
    FROM		TiposIVA ti
    WHERE		ti.TipoIVA LIKE CONCAT('%', pCadena, '%')
                AND (ti.FechaHasta IS NULL OR pIncluyeBajas = 'S');
END$$

DELIMITER ;