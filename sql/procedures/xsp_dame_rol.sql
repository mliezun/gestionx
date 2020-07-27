DROP PROCEDURE IF EXISTS `xsp_dame_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_rol`(pIdRol tinyint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un rol desde la base de datos.
    */
	SELECT	*
    FROM	Roles
    WHERE	IdRol = pIdRol;
END$$

DELIMITER ;