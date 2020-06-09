DROP PROCEDURE IF EXISTS `xsp_alta_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_lista_precio`(pToken varchar(500), pIdEmpresa int, pLista varchar(50), pPorcentaje decimal(10,4), pObservaciones text, 
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta una lista de precios controlando que el nombre de la lista no exista ya dentro de la misma empresa.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdListaPrecio bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pLista IS NULL OR pLista = '') THEN
        SELECT 'Debe ingresar el nombre de la lista.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pPorcentaje IS NULL OR pPorcentaje = 0) THEN
        SELECT 'Debe ingresar el porcentaje de la lista.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir una empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Lista FROM ListasPrecio WHERE Lista = pLista AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre de la lista ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		
        -- Inserta Lista
        INSERT INTO ListasPrecio SELECT 0, pIdEmpresa, pLista, pPorcentaje, 'A', pObservaciones;

        SET pIdListaPrecio = LAST_INSERT_ID();

        -- Insercion de PreciosArticulos
        INSERT INTO PreciosArticulos
        SELECT      IdArticulo, pIdListaPrecio, NOW(), f_calcular_precio_articulo(IdArticulo, p.Descuento, pPorcentaje)
        FROM        Articulos a
        INNER JOIN  Proveedores p USING(IdProveedor)
        WHERE       a.IdEmpresa = pIdEmpresa;

        -- Insercion de Historial Precios
        INSERT INTO HistorialPrecios
        SELECT      0, pa.IdArticulo, pa.PrecioVenta, NOW(), NULL, pIdListaPrecio
        FROM        PreciosArticulos pa
        WHERE       pa.IdListaPrecio = pIdListaPrecio;

		-- Audito Insersiones
		INSERT INTO aud_ListasPrecio
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        -- Inserta Historial
        INSERT INTO HistorialPorcentajes 
        SELECT 0, pIdListaPrecio, pPorcentaje, NOW(), NULL;
        
        SELECT CONCAT('OK', pIdListaPrecio) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_lista_precio`(pToken varchar(500), pIdListaPrecio bigint,
pLista varchar(50), pPorcentaje decimal(10,4), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar una Lista de precios existente controlando que el nombre de la lista no exista ya.
	Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario, pIdEmpresa bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pPorcentajeAntiguo decimal(10,4);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdListaPrecio IS NULL OR pIdListaPrecio = 0) THEN
        SELECT 'Debe ingresar la lista.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pLista IS NULL OR pLista = '') THEN
        SELECT 'Debe ingresar el nombre de la lista.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPorcentaje IS NULL OR pPorcentaje = 0) THEN
        SELECT 'Debe ingresar el porcentaje de la lista.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	-- Control de Parámetros incorrectos
    IF NOT EXISTS(SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio) THEN
		SELECT 'La lista indicada no existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    SET pIdEmpresa = (SELECT IdEmpresa FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio);
    IF EXISTS(SELECT Lista FROM ListasPrecio WHERE IdListaPrecio != pIdListaPrecio AND Lista = pLista AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre de la lista ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pPorcentajeAntiguo = (SELECT Porcentaje FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio);
        
        -- Antes
        INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        IF (pPorcentajeAntiguo != pPorcentaje) THEN
            -- Modifico el Historico
            UPDATE HistorialPorcentajes SET FechaFin = NOW() WHERE IdListaPrecio = pIdListaPrecio AND FechaFin IS NULL;
            -- Inserto Historico
            INSERT INTO HistorialPorcentajes
            SELECT 0, pIdListaPrecio, pPorcentaje, NOW(), NULL;

            -- Modifico el Historico Precios
            UPDATE HistorialPrecios hp
                INNER JOIN Articulos a USING(IdArticulo)
            SET FechaFin = NOW()
            WHERE FechaFin IS NULL
                AND a.IdEmpresa = pIdEmpresa;

            -- Audito PreciosArticulos Antes
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_LISTA', 'A',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;

            -- Modifico los PreciosArticulos
            UPDATE      PreciosArticulos pa
            INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
            INNER JOIN  Articulos a USING(IdArticulo)
            INNER JOIN  Proveedores p USING(IdProveedor)
            SET         pa.PrecioVenta = f_calcular_precio_articulo(IdArticulo, p.Descuento, pPorcentaje)
            WHERE       lp.IdListaPrecio = pIdListaPrecio;

            UPDATE      HistorialPrecios hp
            SET         FechaFin = NOW()
            WHERE       hp.IdListaPrecio = pIdListaPrecio AND FechaFin IS NULL;

            INSERT INTO HistorialPrecios
            SELECT      0, IdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
            FROM        PreciosArticulos
            WHERE       IdListaPrecio = pIdListaPrecio;

            -- Audita PreciosArticulos Despues
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_LISTA', 'D',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;

            -- Inserto Historico Precios
            INSERT INTO HistorialPrecios
            SELECT 0, NULL, pa.PrecioVenta, NOW(), NULL, pIdListaPrecio
            FROM PreciosArticulos pa WHERE pa.IdListaPrecio;
        END IF;

        -- Modifica
        UPDATE  ListasPrecio 
		SET		Lista=pLista,
                Porcentaje=pPorcentaje,
                Observaciones=pObservaciones
		WHERE	IdListaPrecio=pIdListaPrecio;

        -- Despues
        INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_lista_precio`(pToken varchar(500), pIdListaPrecio bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado de la Lista de Precio a Activo siempre y cuando no esté activo ya.
    Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio AND Estado = 'A') THEN
		SELECT 'La Lista ya está activada.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

		-- Antes
		INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

		-- Activa ListaPrecio
		UPDATE ListasPrecio SET Estado = 'A' WHERE IdListaPrecio = pIdListaPrecio;

		-- Después
		INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_lista_precio`(pToken varchar(500), pIdListaPrecio bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite borrar una Lista de Precios existente y su histotial de porcentajes asociado.
    Controlando que no tenga Precios Lista asociados.
    Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio) THEN
        SELECT 'La Lista indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF EXISTS(SELECT IdListaPrecio FROM Clientes WHERE IdListaPrecio = pIdListaPrecio) THEN
		SELECT 'No se puede borrar la Lista, existen clientes asociados.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

		-- Audito
		INSERT INTO aud_ListasPrecio
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_LISTA', 'A',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;

        -- Borro Historial Porcentajes
        DELETE FROM HistorialPorcentajes WHERE IdListaPrecio = pIdListaPrecio;

        -- Borra Precios Articulos
        DELETE FROM HistorialPrecios WHERE IdListaPrecio = pIdListaPrecio;

        DELETE FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;
        
        -- Borra ListaPrecio
        DELETE FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_lista_precio`(pIdListaPrecio bigint)
BEGIN
	/*
    Procedimiento que sirve para instanciar una lista de precios desde la base de datos.
    */
	SELECT	*
    FROM	ListasPrecio
    WHERE	IdListaPrecio = pIdListaPrecio;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_listas_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_listas_precio`(pIdEmpresa int, pCadena varchar(100), pIncluyeBajas char(1), pIncluyeDefecto char(1))
SALIR: BEGIN
	/*
	Permite buscar listas de precios dentro de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas.
	*/
    SELECT  lp.*
    FROM    ListasPrecio lp
    WHERE   lp.IdEmpresa = pIdEmpresa
            AND (
                    lp.Lista LIKE CONCAT('%', pCadena, '%')
                )
            AND (pIncluyeBajas = 'S' OR lp.Estado = 'A')
            AND (pIncluyeDefecto = 'S' OR lp.Lista != 'Por Defecto');
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_listar_listas_precios`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_listas_precios`()
BEGIN
	/*
    Permite listar las listas de precios activas.
    */
    SELECT		lp.*
    FROM		ListasPrecio lp
    WHERE		lp.Estado = 'A';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_listar_historial_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_historial_lista_precio`(pIdListaPrecio bigint)
SALIR: BEGIN
	/*
	Permite listar el historial de porcentajes de una lista de precios.
	*/
    SELECT  lp.Lista, hp.*
    FROM    ListasPrecio lp
    INNER JOIN HistorialPorcentajes hp USING(IdListaPrecio)
    WHERE   lp.IdListaPrecio = pIdListaPrecio
    ORDER BY FechaFin;
END$$
DELIMITER ;
