DROP PROCEDURE IF EXISTS `xsp_cambiar_parametro`;
DELIMITER $$
CREATE PROCEDURE `xsp_cambiar_parametro`(pToken varchar(500), pParametro varchar(20), pValor text, 
											pMotivo varchar(100), pAutoriza varchar(30), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite cambiar el valor de un parámetro siempre y cuando sea editable. Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_cambiar_parametro', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pValor IS NULL OR pValor = '') THEN
        SELECT 'Debe ingresar un valor para el parámetro.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS(SELECT Parametro FROM Parametros WHERE Parametro = pParametro AND EsEditable = 'S') THEN
        SELECT 'El parámetro no es editable.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Audito antes
		INSERT INTO aud_ParametroEmpresa
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', pe.* 
        FROM ParametroEmpresa pe
        INNER JOIN	Empresas e USING(IdEmpresa)
        INNER JOIN	ModulosEmpresas me USING(IdEmpresa, IdModulo)
        INNER JOIN 	Usuarios u USING(IdEmpresa)
		WHERE u.IdUsuario = pIdUsuario AND pe.Parametro = pParametro;

		-- Modifica
        UPDATE		ParametroEmpresa pe
        INNER JOIN	Empresas e USING(IdEmpresa)
        INNER JOIN	ModulosEmpresas me USING(IdEmpresa, IdModulo)
        INNER JOIN 	Usuarios u USING(IdEmpresa)
        SET			pe.Valor = pValor
        WHERE		u.IdUsuario = pIdUsuario AND pe.Parametro = pParametro;
		
		-- Audito despues
		INSERT INTO aud_ParametroEmpresa
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', pe.* 
        FROM ParametroEmpresa pe
        INNER JOIN	Empresas e USING(IdEmpresa)
        INNER JOIN	ModulosEmpresas me USING(IdEmpresa, IdModulo)
        INNER JOIN 	Usuarios u USING(IdEmpresa)
		WHERE u.IdUsuario = pIdUsuario AND pe.Parametro = pParametro;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;