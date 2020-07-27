DROP PROCEDURE IF EXISTS `xsp_dame_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_tipogravamen`(pIdTipoGravemen tinyint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un tipo de gravamen desde la base de datos.
    */
	SELECT	*
    FROM	TiposGravamenes
    WHERE	IdTipoGravemen = pIdTipoGravemen;
END$$

DELIMITER ;