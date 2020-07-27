DROP PROCEDURE IF EXISTS `xsp_dame_permisos_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_permisos_usuario`(pJWT varchar(500))
BEGIN
	/*
    Permite devolver en un resultset la lista de variables de permiso que el
	usuario tiene habilitados. Se valida con el token de sesión.
    */
    SELECT	Permiso
    FROM	Permisos p INNER JOIN PermisosRol pr USING(IdPermiso)
    WHERE	IdRol = (SELECT	IdRol FROM Usuarios WHERE Token = pJWT);
END$$

DELIMITER ;