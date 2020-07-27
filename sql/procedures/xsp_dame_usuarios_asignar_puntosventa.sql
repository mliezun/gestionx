DROP PROCEDURE IF EXISTS `xsp_dame_usuarios_asignar_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_usuarios_asignar_puntosventa`(pIdPuntoVenta bigint)
SALIR: BEGIN
	/*
    Permite listar usuarios  asignables a un punto de venta.
    */
	DECLARE pIdEmpresa bigint;
	DECLARE pIdRol int;
	SET pIdEmpresa = (SELECT IdEmpresa FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta);
	SET pIdRol = (SELECT IdRol FROM Roles INNER JOIN ParametroEmpresa USING(IdEmpresa) WHERE Parametro = 'ROLVENDEDOR' AND IdEmpresa = pIdEmpresa AND Valor = Rol);
    SELECT		u.*
	FROM		(SELECT * FROM Usuarios WHERE IdRol = pIdRol AND Estado = 'A') u
	LEFT JOIN	(SELECT * FROM UsuariosPuntosVenta WHERE Estado = 'A' AND IdPuntoVenta = pIdPuntoVenta) upv USING(IdUsuario)
	WHERE		upv.IdUsuario IS NULL;
END$$

DELIMITER ;