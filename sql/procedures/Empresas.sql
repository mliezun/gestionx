DROP PROCEDURE IF EXISTS `xsp_alta_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_empresa`(pToken varchar(500), pEmpresa varchar(100), pURL varchar(255), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
	/*
	Permite dar de alta una nueva empresa, junto con todos los parámetros de empresa por defecto.
    Verifica que el nombre de la empresa no exista ya.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pIdEmpresa, pIdRol int;
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        -- show errors;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
    END;
    
    call xsp_puede_ejecutar(pToken, 'xsp_alta_empresa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN
		SELECT pMensaje Mensaje;
        LEAVE PROC;
    END IF;
    
    IF EXISTS (SELECT IdEmpresa FROM Empresas WHERE Empresa = pEmpresa) THEN
		SELECT 'No se puede dar de alta la empresa. Ya existe una empresa con el mismo nombre.' Mensaje;
        LEAVE PROC;
    END IF;
    
    IF EXISTS (SELECT IdEmpresa FROM Empresas WHERE URL = pURL) THEN
		SELECT 'No se puede dar de alta la empresa. Ya existe una empresa con la misma URL.' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        
		INSERT INTO Empresas SELECT 0, pEmpresa, pURL, 'A';

        SET pIdEmpresa = LAST_INSERT_ID();

        INSERT INTO ModulosEmpresas VALUES (pIdEmpresa, 1), (pIdEmpresa, 2);

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
        call xsp_generar_datos_empresa(pIdEmpresa, pMensaje);
        IF pMensaje != 'OK' THEN
            SELECT pMensaje Mensaje;
            ROLLBACK;
            LEAVE PROC;
        END IF;
        
        SELECT CONCAT('OK', pIdEmpresa) Mensaje;
    COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_buscar_empresas`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_empresas`(pCadena varchar(100), pIncluyeBajas char(1))
BEGIN
	/*
	Permite buscar empresas por una Cadena de búsqueda indicando si se incluyen o no las dadas
    de baja. Cadena vacía para listar todas.
    */
    SELECT  *
    FROM    Empresas
    WHERE   Empresa LIKE CONCAT('%', pCadena, '%')
            AND (Estado = 'A' OR pIncluyeBajas = 'S');
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_listar_modulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_modulos`()
BEGIN
	/*
	Permite listar los módulos activos.
    */
    SELECT  *
    FROM    Modulos
    WHERE   Estado = 'A';
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_listar_modulos_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_modulos_empresa`()
BEGIN
	/*
	Permite listar los módulos de una empresa.
    */
    SELECT      m.*
    FROM        ModulosEmpresas me
    INNER JOIN  Modulos m USING(IdModulo)
    WHERE       Estado = 'A' AND IdEmpresa = pIdEmpresa;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_darbaja_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_empresa`(pToken varchar(500), pIdEmpresa int, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
	/*
	Permite dar de baja una empresa, controlando que exista y se encuentre activa.
    Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
    END;
    
    call xsp_puede_ejecutar(pToken, 'xsp_darbaja_empresa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN
		SELECT pMensaje Mensaje;
        LEAVE PROC;
    END IF;
    
    IF EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa AND Estado = 'B') THEN
		SELECT 'La empresa ya se encuentra dada de baja.' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
		UPDATE Empresas SET Estado = 'B' WHERE IdEmpresa = pIdEmpresa;

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
        SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_activar_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_empresa`(pToken varchar(500), pIdEmpresa int, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
	/*
	Permite activar una empresa, controlando que exista y se encuentre dada de baja.
    Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
    END;
    
    call xsp_puede_ejecutar(pToken, 'xsp_activar_empresa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN
		SELECT pMensaje Mensaje;
        LEAVE PROC;
    END IF;
    
    IF EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa AND Estado = 'A') THEN
		SELECT 'La empresa ya se encuentra activa.' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
		UPDATE Empresas SET Estado = 'A' WHERE IdEmpresa = pIdEmpresa;

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
        SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;


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


DROP PROCEDURE IF EXISTS `xsp_buscar_parametros`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_parametros`(pHost varchar(255), pCadena varchar(20))
BEGIN
	/*
    Permite buscar los parámetros editables de una empresa dada una cadena de búsqueda, controlando que pertenezcan a módulos activos.
    Para listar todos, cadena vacía.
    */
    DECLARE pIdEmpresa int;
    
    SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost);
    
    SELECT 		p.*, pe.Valor
    FROM 		Empresas e
    INNER JOIN	ModulosEmpresas me USING(IdEmpresa)
    INNER JOIN	Parametros p USING(IdModulo)
    INNER JOIN	ParametroEmpresa pe USING(Parametro, IdEmpresa, IdModulo)
    WHERE 		e.IdEmpresa = pIdEmpresa
				AND p.EsEditable = 'S'
                AND pe.Parametro LIKE CONCAT('%', pCadena, '%');
END$$
DELIMITER ;


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


DROP PROCEDURE IF EXISTS `xsp_dame_datos_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_datos_empresa`(pHost varchar(255))
BEGIN
	/*
    Permite obtener los parámetros de la empresa que necesitan cargarse al inicio de sesión (EsInicial = S), verificando que los parámetros pertenezcan a módulos activos de la empresa.
    */
    DECLARE pIdEmpresa int;
    
    SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost);
    
    SELECT		p.*, pe.Valor
    FROM		Parametros p
    INNER JOIN	ModulosEmpresas me USING(IdModulo)
    INNER JOIN	ParametroEmpresa pe USING(Parametro, IdEmpresa, IdModulo)
    WHERE		p.EsInicial = 'S' AND me.IdEmpresa = pIdEmpresa;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_dame_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_empresa`(pIdEmpresa int)
BEGIN
	/*
    Permite instanciar una empresa desde la base de datos.
    */
    SELECT * FROM Empresas WHERE IdEmpresa = pIdEmpresa;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_parametro`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_parametro`(pHost varchar(255), pParametro varchar(20))
BEGIN
	/*
    Permite instanciar un parámetro de empresa desde la base de datos.
    */
    DECLARE pIdEmpresa int;
    
    SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas WHERE URL = pHost);
    
    SELECT		p.*, pe.Valor
    FROM		Empresas e
    INNER JOIN	ModulosEmpresas me USING(IdEmpresa)
    INNER JOIN	Parametros p USING(IdModulo)
    INNER JOIN	ParametroEmpresa pe USING(Parametro, IdEmpresa, IdModulo)
    WHERE		p.Parametro = pParametro AND e.IdEmpresa = pIdEmpresa;
END$$
DELIMITER ;

