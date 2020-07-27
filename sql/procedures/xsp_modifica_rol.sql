DROP PROCEDURE IF EXISTS `xsp_modifica_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_rol`(pToken varchar(500), pHost varchar(255), pIdRol tinyint,
pRol varchar(30), pObservaciones text, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar un Rol existente controlando que el nombre del rol no exista ya.
	Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdEmpresa int;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pHost IS NULL OR pHost = '') THEN
        SELECT 'Debe ingresar el url de la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pRol IS NULL OR pRol = '') THEN
        SELECT 'Debe ingresar el nombre del rol.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.URL = pHost) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas E WHERE E.URL = pHost);
    IF EXISTS(SELECT Rol FROM Roles WHERE IdRol != pIdRol AND Rol = pRol AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre del rol ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_Roles
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Roles.*
        FROM Roles WHERE IdRol = pIdRol;
        -- Modifica
        UPDATE Roles 
		SET		Rol=pRol
		WHERE	IdRol=pIdRol;
		-- Despues
        INSERT INTO aud_Roles
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Roles.*
        FROM Roles WHERE IdRol = pIdRol;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;