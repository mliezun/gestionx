DROP PROCEDURE IF EXISTS `xsp_alta_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_banco`(pToken varchar(500), pIdEmpresa int, pBanco varchar(100), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Banco.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdBanco smallint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pBanco IS NULL OR TRIM(pBanco) = '') THEN
        SELECT 'Debe indicar el nombre del banco.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdBanco FROM Bancos WHERE Banco = pBanco AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe un banco con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Inserta
        INSERT INTO Bancos SELECT 0, pIdEmpresa, pBanco, 'A';
        SET pIdBanco = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
        
        SELECT CONCAT('OK', pIdBanco) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_banco`(pToken varchar(500), pIdBanco smallint, pBanco varchar(100),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un Banco.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdBanco IS NULL OR pIdBanco = 0) THEN
        SELECT 'Debe indicar el banco.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pBanco IS NULL OR TRIM(pBanco) = '') THEN
        SELECT 'Debe indicar el nombre del banco.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF EXISTS(SELECT IdBanco FROM Bancos WHERE Banco = pBanco AND IdEmpresa = pIdEmpresa AND IdBanco != pIdBanco) THEN
		SELECT 'Ya existe otro banco con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_Bancos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Bancos.*
        FROM Bancos WHERE IdBanco = pIdBanco;
        -- Modifica
        UPDATE Bancos 
		SET	   Banco = pBanco
		WHERE  IdBanco=pIdBanco;
		-- Despues
        INSERT INTO aud_Bancos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Bancos.*
        FROM Bancos WHERE IdBanco = pIdBanco;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_banco`(pToken varchar(500), pIdBanco smallint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un banco controlando que no tenga ingresos o ventas asosiadas.
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_banco', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdBanco FROM Bancos WHERE IdBanco = pIdBanco) THEN
        SELECT 'El banco indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdCheque FROM Cheques WHERE IdBanco = pIdBanco) THEN
        SELECT 'El banco indicado no se puede borrar, tiene cheques asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Bancos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Bancos.*
        FROM Bancos WHERE IdBanco = pIdBanco;
        -- Borro
        DELETE FROM Bancos WHERE IdBanco = pIdBanco;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

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

DROP PROCEDURE IF EXISTS `xsp_activar_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_banco`(pToken varchar(500), pIdBanco smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado del Banco a Activo siempre y cuando no esté activo ya.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Bancos WHERE IdBanco = pIdBanco AND Estado = 'A') THEN
		SELECT 'El Banco ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		-- Activa Banco
		UPDATE Bancos SET Estado = 'A' WHERE IdBanco = pIdBanco;
		-- Después
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_banco`(pToken varchar(500), pIdBanco smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de baja a un Banco siempre y cuando no esté dado de baja ya.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Bancos WHERE IdBanco = pIdBanco AND Estado = 'B') THEN
		SELECT 'El Banco ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		-- Activa Banco
		UPDATE Bancos SET Estado = 'B' WHERE IdBanco = pIdBanco;
		-- Después
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_bancos`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_bancos`(pIdEmpresa int, pCadena varchar(30), pEstado char(1))
BEGIN
	/*
    * Permite buscar los bancos dada una cadena de búsqueda, el tipo de banco (T para listar todas) y el estado.
    * Para listar todos, cadena vacía.
    */
    SELECT		b.*
    FROM		Bancos b
    WHERE		b.IdEmpresa = pIdEmpresa
                AND (b.Banco LIKE CONCAT('%', pCadena, '%'))
                AND (b.Estado = pEstado OR pEstado = 'T');
END$$
DELIMITER ;
