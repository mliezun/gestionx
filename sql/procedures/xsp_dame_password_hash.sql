DROP PROCEDURE IF EXISTS `xsp_dame_password_hash`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_password_hash`(pHost varchar(255), pUsuario varchar(120))
BEGIN
	/*
    Permite obtener el password hash de un usuario a partir de su documento.
    */
	DECLARE pIdEmpresa int;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost AND Estado = 'A');
	IF EXISTS (SELECT Usuario FROM Usuarios WHERE Usuario = pUsuario AND IdEmpresa = pIdEmpresa) THEN
		SELECT	Password 
        FROM	Usuarios
        WHERE	Usuario = pUsuario AND IdEmpresa = pIdEmpresa;
	ELSE
		SELECT NULL Password;
	END IF;
END$$

DELIMITER ;