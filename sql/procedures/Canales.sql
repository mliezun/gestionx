DROP PROCEDURE IF EXISTS `xsp_alta_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_canal`(pToken varchar(500), pIdEmpresa int, pCanal varchar(50), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un canal controlando que el nombre del canal no exista ya dentro de la misma empresa.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdCanal bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_canal', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pCanal IS NULL OR TRIM(pCanal) = '') THEN
        SELECT 'Debe indicar el nombre del canal.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdCanal FROM Canales WHERE Canal = pCanal AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe un canal con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		        
        -- Inserta
        INSERT INTO Canales SELECT 0, pIdEmpresa, pCanal, 'A', pObservaciones;
        SET pIdCanal = LAST_INSERT_ID();
        
        -- Insercion de Existencias Consolidadas
        INSERT INTO ExistenciasConsolidadas
        SELECT      IdArticulo, IdPuntoVenta, pIdCanal, 0
        FROM        PuntosVenta pv
        CROSS JOIN  Articulos a
        WHERE       pv.IdEmpresa = pIdEmpresa AND a.IdEmpresa = pIdEmpresa;

		-- Audita
		INSERT INTO aud_Canales
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
        
        SELECT CONCAT('OK', pIdCanal) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_canal`(pToken varchar(500), pIdCanal bigint, pCanal varchar(50), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un Canal existente controlando que el nombre del Canal no exista ya dentro de la misma empresa.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario,pIdEmpresa bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_canal', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCanal IS NULL OR pIdCanal = 0) THEN
        SELECT 'Debe indicar el canal.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pCanal IS NULL OR TRIM(pCanal) = '') THEN
        SELECT 'Debe indicar el nombre del canal.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	-- Control de Parametros incorrectos
    IF EXISTS(SELECT IdCanal FROM Canales WHERE Canal = pCanal AND IdCanal != pIdCanal AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe otro canal con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        
        -- Antes
        INSERT INTO aud_Canales
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
        
        -- Modifica
        UPDATE Canales
		SET     Canal = pCanal,
                Observaciones = pObservaciones
		WHERE   IdCanal = pIdCanal;
		
        -- Despues
        INSERT INTO aud_Canales
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_canal`(pToken varchar(500), pIdCanal bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un Canal existente controlando que no existan remitos,
    * ventas o rectificaciones asociadas.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_canal', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCanal FROM Canales WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdVenta FROM Ventas WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no se puede borrar, tiene ventas asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdRemito FROM Remitos WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no se puede borrar, tiene remitos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no se puede borrar, tiene rectificaciones asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        
        -- Borro las existencias consolidadas
        DELETE FROM ExistenciasConsolidadas WHERE IdCanal = pIdCanal;

        -- Audito
        INSERT INTO aud_Canales
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
        
        -- Borro
        DELETE FROM Canales WHERE IdCanal = pIdCanal;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_canal`(pIdCanal bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un canal desde la base de datos.
    */
	SELECT	*
    FROM	Canales
    WHERE	IdCanal = pIdCanal;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_canal`(pToken varchar(500), pIdCanal bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado del Canal a Activo siempre y cuando no esté activo ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_canal', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Canales WHERE IdCanal = pIdCanal AND Estado = 'A') THEN
		SELECT 'El Canal ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		
        -- Antes
		INSERT INTO aud_Canales
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;

		-- Activa Canal
		UPDATE Canales SET Estado = 'A' WHERE IdCanal = pIdCanal;

		-- Después
		INSERT INTO aud_Canales
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_canal`(pToken varchar(500), pIdCanal bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado del Canal a Baja siempre y cuando no esté dado de baja ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_canal', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Canales WHERE IdCanal = pIdCanal AND Estado = 'B') THEN
		SELECT 'El Canal ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		
        -- Antes
		INSERT INTO aud_Canales
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
		
        -- Activa Canal
		UPDATE Canales SET Estado = 'B' WHERE IdCanal = pIdCanal;
		
        -- Después
		INSERT INTO aud_Canales
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_canales`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_canales`(pIdEmpresa int, pCadena varchar(30), pIncluye char(1))
BEGIN
	/*
    * Permite buscar canales dentro de una empresa, indicando una cadena de búsqueda
    * y si se incluyen bajas.
    * Para listar todos, cadena vacía.
    */
    SELECT		c.*
    FROM		Canales c
    WHERE		c.IdEmpresa = pIdEmpresa
                AND (c.Canal LIKE CONCAT('%', pCadena, '%'))
                AND (c.Estado = 'A' OR pIncluye = 'S');
END$$
DELIMITER ;
