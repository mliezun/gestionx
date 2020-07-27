DROP PROCEDURE IF EXISTS `xsp_puede_ejecutar`;
DELIMITER $$
CREATE PROCEDURE `xsp_puede_ejecutar`(pJWT varchar(500), pProcedimiento varchar(100),
										OUT pMensaje varchar(255), OUT pIdUsuario bigint)
BEGIN
	/*
    Permite determinar si el usuario logueado puede ejecutar un procedimiento.
    Retorna OK o el mensaje de error en pMensaje y el id del usuario en pIdUsuario.
    */
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT 		COALESCE(IdUsuario, 0)
    INTO		pIdUsuario
    FROM		Usuarios u
    INNER JOIN	Empresas e USING(IdEmpresa)
    INNER JOIN	ModulosEmpresas me USING(IdEmpresa)
    INNER JOIN	Permisos p USING(IdModulo)
	INNER JOIN	Roles r USING(IdRol)
    INNER JOIN	PermisosRol USING(IdPermiso, IdRol)
    WHERE		u.Token = pJWT AND u.Estado = 'A'
				AND p.Procedimiento = pProcedimiento
	LIMIT		1;
                
	IF pIdUsuario IS NULL OR pIdUsuario = 0 THEN
		SET pMensaje = 'Usted no posee los permisos para realizar esta acción.';
	ELSEIF EXISTS (SELECT IdEmpresa FROM Empresas e INNER JOIN Usuarios u USING(IdEmpresa) WHERE e.Estado != 'A' AND u.IdUsuario = pIdUsuario) THEN
		SET pMensaje = 'Usted no puede ingresar, su empresa no está habilitada.';
    ELSE
		SET pMensaje = 'OK';
    END IF;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;