DROP PROCEDURE IF EXISTS `xsp_alta_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_proveedor`(pToken varchar(500), pIdEmpresa int, pProveedor varchar(100), pDescuento decimal(10,4),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de alta un proveedor. Controlando que el nombre del proveedor no exista ya
    dentro de la misma empresa. Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pIdProveedor bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pProveedor IS NULL OR pProveedor = '') THEN
        SELECT 'El nombre del proveedor no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pDescuento IS NULL) THEN
        SELECT 'Debe indicar el descuento.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa) THEN
        SELECT 'La empresa indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdEmpresa = pIdEmpresa AND Proveedor = pProveedor) THEN
        SELECT 'Ya existe un proveedor con ese nombre.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Inserto Proveedor
        INSERT INTO Proveedores SELECT 0, pIdEmpresa, pProveedor, pDescuento, 'A';

        SET pIdProveedor = LAST_INSERT_ID();

        -- Audito Proveedor
        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Proveedores.* FROM Proveedores WHERE IdProveedor = pIdProveedor;

        -- Inserto Historico
        INSERT INTO HistorialDescuentos SELECT 0, pIdProveedor, pDescuento, NOW(), NULL;
		
        SELECT CONCAT('OK', pIdProveedor) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_proveedor`(pToken varchar(500), pIdProveedor bigint, pProveedor varchar(100), pDescuento decimal(10,4),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de alta un proveedor. Controlando que el nombre del proveedor no exista ya
    dentro de la misma empresa. Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pDescuentoAntiguo decimal(10,4);
    DECLARE pIdHistorial bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pProveedor IS NULL OR pProveedor = '') THEN
        SELECT 'El nombre del proveedor no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pDescuento IS NULL) THEN
        SELECT 'El descuento del proveedor no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor != pIdProveedor AND Proveedor = pProveedor) THEN
        SELECT 'Ya existe un proveedor con ese nombre.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        SET pDescuentoAntiguo = (SELECT Descuento FROM Proveedores WHERE IdProveedor = pIdProveedor);

        -- Audito Antes
        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Proveedores.* FROM Proveedores WHERE IdProveedor = pIdProveedor;

        -- Modifico Proveedor
        UPDATE Proveedores 
            SET Proveedor = pProveedor,
                Descuento = pDescuento
        WHERE IdProveedor = pIdProveedor;

        -- Audito Despues
        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Proveedores.* FROM Proveedores WHERE IdProveedor = pIdProveedor;

        IF (pDescuentoAntiguo != pDescuento) THEN
            SET pIdHistorial = (SELECT IdHistorial FROM HistorialDescuentos WHERE IdProveedor = pIdProveedor AND FechaFin IS NULL);
            -- Modifico el Historico
            UPDATE HistorialDescuentos SET FechaFin = NOW() WHERE IdHistorial = pIdHistorial AND FechaFin IS NULL;
            -- Inserto Historico
            INSERT INTO HistorialDescuentos SELECT 0, pIdProveedor, pDescuento, NOW(), NULL;

            -- Modifico los PreciosArticulos
            UPDATE      PreciosArticulos pa
            INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
            INNER JOIN  Articulos a USING(IdArticulo)
            INNER JOIN  Proveedores p USING(IdProveedor)
            SET         pa.PrecioVenta = f_calcular_precio_articulo(IdArticulo, p.Descuento, lp.Porcentaje)
            WHERE       a.IdProveedor = pIdProveedor;

            UPDATE      HistorialPrecios hp
            INNER JOIN  PreciosArticulos pa USING(IdArticulo)
            INNER JOIN  Articulos a USING(IdArticulo)
            SET         FechaFin = NOW()
            WHERE       a.IdProveedor = pIdProveedor AND FechaFin IS NULL AND hp.IdListaPrecio IS NOT NULL;

            INSERT INTO HistorialPrecios
            SELECT      0, a.IdArticulo, pa.PrecioVenta, NOW(), NULL, pa.IdListaPrecio
            FROM        PreciosArticulos pa
            INNER JOIN  Articulos a USING(IdArticulo)
            WHERE       a.IdProveedor = pIdProveedor;
        END IF;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_aplicar_aumento_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_aplicar_aumento_proveedor`(pToken varchar(500), pIdProveedor bigint, pAumento decimal(10,4),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite aplicar un aumento a todos los artículos de un proveedor. Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pAumento IS NULL) THEN
        SELECT 'El aumento del proveedor no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Modifico los PreciosArticulos
        UPDATE      PreciosArticulos pa
        INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
        INNER JOIN  Articulos a USING(IdArticulo)
        INNER JOIN  Proveedores p USING(IdProveedor)
        SET         pa.PrecioVenta = pa.PrecioVenta*IF(pAumento < 0, 1/(1+(-1*pAumento/100)), 1+(pAumento/100))
        WHERE       a.IdProveedor = pIdProveedor;

        UPDATE      HistorialPrecios hp
        INNER JOIN  PreciosArticulos pa USING(IdArticulo)
        INNER JOIN  Articulos a USING(IdArticulo)
        SET         FechaFin = NOW()
        WHERE       a.IdProveedor = pIdProveedor AND FechaFin IS NULL AND hp.IdListaPrecio IS NOT NULL;

        INSERT INTO HistorialPrecios
        SELECT      0, a.IdArticulo, pa.PrecioVenta, NOW(), NULL, pa.IdListaPrecio
        FROM        PreciosArticulos pa
        INNER JOIN  Articulos a USING(IdArticulo)
        WHERE       a.IdProveedor = pIdProveedor;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_cargar_articulos_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_cargar_articulos_proveedor`(pToken varchar(500), pIdProveedor bigint, pArticulos json,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite hacer un alta/modifica masivo de artículos de un proveedor. Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion, pIdArticulo bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pDescuentoAntiguo, pDescuento decimal(10,4);
    DECLARE pIdHistorial bigint;
    DECLARE pIndice int default 0;
    DECLARE pArticuloJSON json;
    DECLARE pIdEmpresa int;
    DECLARE pArticulo, pCodigo varchar(255);
    DECLARE pDescripcion text;
    DECLARE pPrecioCosto, pPrecioCostoAntiguo decimal(12, 2);
    DECLARE pIdTipoIVA tinyint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Proveedores WHERE IdProveedor = pIdProveedor);
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        WHILE pIndice < JSON_LENGTH(pArticulos) DO
            SET pArticuloJSON = JSON_EXTRACT(pArticulos, CONCAT('$[', pIndice, ']'));

            SELECT  pArticuloJSON->>'$.Articulo', pArticuloJSON->>'$.Codigo', pArticuloJSON->>'$.Descripcion',
                    REPLACE(pArticuloJSON->>'$.PrecioCosto', ',', '.'), (SELECT IdTipoIVA FROM TiposIVA WHERE TipoIVA LIKE CONCAT('%', REPLACE(pArticuloJSON->>'$.IVA', ',', '.'), '%') ORDER BY 1 LIMIT 1)
            INTO    pArticulo, pCodigo, pDescripcion, pPrecioCosto, pIdTipoIVA;

            IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Codigo = pCodigo) THEN
                SET pIdArticulo = (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Codigo = pCodigo LIMIT 1);
                SET pPrecioCostoAntiguo = (SELECT PrecioCosto FROM Articulos WHERE IdArticulo = pIdArticulo);

                -- Audita Articulos Antes
                INSERT INTO aud_Articulos
                SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
                Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;

                -- Modifica
                UPDATE  Articulos
                SET     Articulo = pArticulo,
                        Codigo = pCodigo,
                        Descripcion = pDescripcion,
                        PrecioCosto = pPrecioCosto,
                        IdTipoIVA = pIdTipoIVA
                WHERE   IdArticulo = pIdArticulo;

                IF (pPrecioCostoAntiguo != pPrecioCosto) THEN
                    -- Modifico el Historico
                    UPDATE HistorialPrecios SET FechaFin = NOW() WHERE IdArticulo = pIdArticulo AND FechaFin IS NULL;
                    -- Inserto Historico
                    INSERT INTO HistorialPrecios 
                    SELECT 0, pIdArticulo, pPrecioCosto, NOW(), NULL, NULL;

                    -- Audito PreciosArticulos Antes
                    INSERT INTO aud_PreciosArticulos
                    SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_ARTICULO', 'A',
                    PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

                    -- Modifico los PreciosArticulos
                    UPDATE      PreciosArticulos pa
                    INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
                    INNER JOIN  Articulos a USING(IdArticulo)
                    INNER JOIN  Proveedores p USING(IdProveedor)
                    SET         pa.PrecioVenta = f_calcular_precio_articulo(IdArticulo, p.Descuento, lp.Porcentaje)
                    WHERE       IdArticulo = pIdArticulo;

                    INSERT INTO HistorialPrecios
                    SELECT 0, IdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
                    FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

                    -- Audita PreciosArticulos Despues
                    INSERT INTO aud_PreciosArticulos
                    SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_ARTICULO', 'D',
                    PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;
                END IF;

                -- Audita Articulos Despues
                INSERT INTO aud_Articulos
                SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
                Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;
            ELSE
                -- Insercion en Articulos
                INSERT INTO Articulos
                SELECT  0, pIdProveedor, pIdEmpresa, pIdTipoIVA, pArticulo, pCodigo, pDescripcion, pPrecioCosto, NOW(), 'A';

                SET pIdArticulo = LAST_INSERT_ID();

                -- Insercion de Existencias
                INSERT INTO ExistenciasConsolidadas
                SELECT      pIdArticulo, IdPuntoVenta, IdCanal, 0
                FROM        PuntosVenta pv
                CROSS JOIN  Canales c
                WHERE       pv.IdEmpresa = pIdEmpresa AND c.IdEmpresa = pIdEmpresa;

                SET pDescuento = (SELECT MAX(Descuento) FROM Proveedores WHERE IdProveedor = pIdProveedor);

                -- Insercion de Precios Articulos
                INSERT INTO PreciosArticulos
                SELECT      pIdArticulo, IdListaPrecio, NOW(), f_calcular_precio_articulo(pIdArticulo, pDescuento, lp.Porcentaje)
                FROM        ListasPrecio lp
                WHERE       lp.IdEmpresa = pIdEmpresa;

                -- Insercion de Historial Precios
                INSERT INTO HistorialPrecios
                SELECT      0, pIdArticulo, pPrecioCosto, NOW(), NULL, NULL;

                INSERT INTO HistorialPrecios
                SELECT      0, pIdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
                FROM        PreciosArticulos WHERE IdArticulo = pIdArticulo;
                
                -- Audita Inserciones
                INSERT INTO aud_Articulos
                SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
                Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;

                INSERT INTO aud_PreciosArticulos
                SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA_ARTICULO', 'I',
                PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;
            END IF;

            SET pIndice = pIndice + 1;
        END WHILE;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_proveedor`(pToken varchar(500), pIdProveedor bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite borrar un proveedor controlando que no tenga artículos asociados.
    Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no se puede borrar, tiene artículos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audito Antes
        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;

        -- Borro Historial Descuentos
        DELETE FROM HistorialDescuentos WHERE IdProveedor = pIdProveedor;

        -- Borro Proveedor
        DELETE FROM Proveedores WHERE IdProveedor = pIdProveedor;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_proveedor`(pToken varchar(500), pIdProveedor bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de baja un proveedor controlando que no esté dado de baja ya.
    Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor AND Estado = 'B') THEN
        SELECT 'El proveedor indicado ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;

        UPDATE Proveedores SET Estado = 'B' WHERE IdProveedor = pIdProveedor;

        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_activar_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_proveedor`(pToken varchar(500), pIdProveedor bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite activar un proveedor controlando que no esté activo ya.
    Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor AND Estado = 'A') THEN
        SELECT 'El proveedor indicado ya está activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;

        UPDATE Proveedores SET Estado = 'A' WHERE IdProveedor = pIdProveedor;

        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Proveedores.*
        FROM Proveedores WHERE IdProveedor = pIdProveedor;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_dame_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_proveedor`(pIdProveedor bigint)
SALIR: BEGIN
	/*
	Permite instaciar un proveedor desde la base de datos.
	*/
    SELECT  *
    FROM    Proveedores
    WHERE   IdProveedor = pIdProveedor;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_buscar_proveedores`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_proveedores`(pIdEmpresa int, pCadena varchar(100), pIncluyeBajas char(1))
SALIR: BEGIN
	/*
	Permite buscar proveedores dentro de una empresa indicando una cadena de búsqueda y
    si se incluyen bajas.
	*/
    SELECT  *
    FROM    Proveedores
    WHERE   IdEmpresa = pIdEmpresa AND Proveedor LIKE CONCAT('%', pCadena, '%')
            AND (pIncluyeBajas = 'S' OR Estado = 'A');
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_listar_historial_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_historial_proveedor`(pIdProveedor bigint)
SALIR: BEGIN
	/*
	Permite listar el historial de descuentos de un proveedor.
	*/
    SELECT  p.Proveedor, hd.*
    FROM    Proveedores p
    INNER JOIN HistorialDescuentos hd USING(IdProveedor)
    WHERE   p.IdProveedor = pIdProveedor
    ORDER BY FechaFin;
END$$
DELIMITER ;
