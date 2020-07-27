DROP PROCEDURE IF EXISTS `xsp_dame_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_banco`(pIdBanco smallint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un banco desde la base de datos.
    */
	SELECT	*
    FROM	Bancos
    WHERE	IdBanco = pIdBanco;
END$$

DELIMITER ;