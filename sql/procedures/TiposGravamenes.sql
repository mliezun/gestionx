DROP PROCEDURE IF EXISTS `xsp_alta_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_tipogravamen`(pToken varchar(500), pTipoGravamen varchar(100),
pGravamen decimal(3,2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un tipo de gravamen controlando que el nombre del tipo de gravamen no exista ya.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdTipoGravemen tinyint;
    DECLARE pIdUsuario bigint;
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_tipogravamen', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pTipoGravamen IS NULL OR pTipoGravamen = '') THEN
        SELECT 'Debe ingresar el tipo de gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pGravamen IS NULL OR pGravamen = 0) THEN
        SELECT 'Debe ingresar el gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE TipoGravamen = pTipoGravamen) THEN
		SELECT 'El tipo de gravamen ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
        INSERT INTO TiposGravamenes SELECT 0, pTipoGravamen, pGravamen, NULL;
        SET pIdTipoGravemen = LAST_INSERT_ID();
        
        SELECT CONCAT('OK', pIdTipoGravemen) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_tipogravamen`(pToken varchar(500), pIdTipoGravemen tinyint, pTipoGravamen varchar(100),
pGravamen decimal(3,2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite modificar un tipo de gravamen controlando que el nombre del tipo de gravamen no exista ya.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_tipogravamen', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoGravemen IS NULL OR pIdTipoGravemen = 0) THEN
        SELECT 'Debe indicar el tipo de gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pTipoGravamen IS NULL OR pTipoGravamen = '') THEN
        SELECT 'Debe ingresar el tipo de gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pGravamen IS NULL OR pGravamen = 0) THEN
        SELECT 'Debe ingresar el gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen) THEN
		SELECT 'El tipo de gravamen que desea modificar no existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen AND FechaBaja IS NULL) THEN
		SELECT 'El tipo de gravamen que desea modificar se encuentra en baja.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE TipoGravamen = pTipoGravamen AND IdTipoGravemen!=pIdTipoGravemen) THEN
		SELECT 'El tipo de gravamen ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		-- Modifica
        UPDATE TiposGravamenes 
		SET		TipoGravamen=pTipoGravamen,
                Gravamen=pGravamen
		WHERE	IdTipoGravemen=pIdTipoGravemen;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_darbaja_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_tipogravamen`(pToken varchar(500), pIdTipoGravemen tinyint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de baja un tipo de gravamen controlando que no este dado de baja ya.
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_tipogravamen', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoGravemen IS NULL OR pIdTipoGravemen = 0) THEN
        SELECT 'Debe indicar el tipo de gravamen.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen) THEN
		SELECT 'El tipo de gravamen que no existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT TipoGravamen FROM TiposGravamenes WHERE IdTipoGravemen!=pIdTipoGravemen AND FechaBaja IS NOT NULL) THEN
		SELECT 'El tipo de gravamen que ya se encuentra en baja.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		-- Modifica
        UPDATE TiposGravamenes 
		SET		FechaBaja=NOW()
		WHERE	IdTipoGravemen=pIdTipoGravemen;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_tipogravamen`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_tipogravamen`(pIdTipoGravemen tinyint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un tipo de gravamen desde la base de datos.
    */
	SELECT	*
    FROM	TiposGravamenes
    WHERE	IdTipoGravemen = pIdTipoGravemen;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_tiposgravamenes`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_tiposgravamenes`(pHost varchar(255), pCadena varchar(30), pIncluyeBajas char(1))
BEGIN
	/*
    Permite buscar los tipos de gravamenes dada una cadena de búsqueda y la opción si incluye o no los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		tg.*
    FROM		TiposGravamenes tg
    WHERE		tg.TipoGravamen LIKE CONCAT('%', pCadena, '%')
                AND (tg.FechaBaja IS NULL OR pIncluyeBajas = 'S');
END$$
DELIMITER ;
