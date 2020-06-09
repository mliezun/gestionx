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