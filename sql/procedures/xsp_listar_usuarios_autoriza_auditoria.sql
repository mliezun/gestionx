DROP PROCEDURE IF EXISTS `xsp_listar_usuarios_autoriza_auditoria`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_usuarios_autoriza_auditoria`(pIdEmpresa int)
BEGIN
	/*
    Lista todos los usuarios activos que pertenecen al rol que tiene el permiso
    Autorizacion. Los ordena por nombre de usuario.
    */
	SELECT		u.*
	FROM		Usuarios u
	INNER JOIN	PermisosRol pr USING(IdRol)
	INNER JOIN	Permisos p USING(IdPermiso)
	WHERE		u.IdEmpresa = pIdEmpresa AND p.Permiso = 'Autoriza';
END$$

DELIMITER ;