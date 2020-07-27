DROP PROCEDURE IF EXISTS `xsp_dame_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_canal`(pIdCanal bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un canal desde la base de datos.
    */
	SELECT	*
    FROM	Canales
    WHERE	IdCanal = pIdCanal;
END$$

DELIMITER ;