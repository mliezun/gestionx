DROP PROCEDURE IF EXISTS `xsp_alta_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_existencia`(pIdUsuario bigint, pIdPuntoVenta bigint, pIdCliente bigint, pIdRemito bigint, pObservaciones text, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite ingresar existencias de un artículo a un punto de venta, ya sea por Remito o por nota de crédito (devolución de un cliente).
    Crea un ingreso en estado En edición, de manera que se le puedan agregar líneas.
    Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdIngreso bigint;
    DECLARE pIdEmpresa int;
    DECLARE pUsuario varchar(30);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;
    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
    INSERT INTO Ingresos SELECT 0, pIdPuntoVenta, pIdEmpresa, pIdCliente, pIdRemito, pIdUsuario, NOW(), 'E', pObservaciones;

    SET pIdIngreso = LAST_INSERT_ID();

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', Ingresos.*
    FROM Ingresos WHERE IdIngreso = pIdIngreso;

    SET pMensaje = CONCAT('OK', pIdIngreso);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_existencia`(pIdUsuario bigint, pIdIngreso bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite quitar existencias, controlando que existan la cantidad de existencias
    consolidadas suficientes para realizar esa acción.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
    DECLARE pUsuario varchar(30);
    DECLARE pIdEmpresa int;
    DECLARE pIdCanal bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    IF (SELECT IdRemito FROM Ingresos WHERE IdIngreso = pIdIngreso) IS NULL THEN
        -- Es un ingreso de Cliente
        SET pIdCanal = (
            SELECT v.IdCanal FROM Ingresos i
            INNER JOIN Clientes c ON i.IdCliente = c.IdCliente
            INNER JOIN Ventas v ON v.IdCliente = c.IdCliente
            WHERE i.IdIngreso = pIdIngreso
        );
    ELSE
        -- Es un ingreso de Remito
        SET pIdCanal = (SELECT r.IdCanal FROM Ingresos i INNER JOIN Remitos r USING(IdRemito) WHERE i.IdIngreso = pIdIngreso);
    END IF;

    IF EXISTS (
                SELECT      ec.IdArticulo
                FROM        LineasIngreso li 
                INNER JOIN  Ingresos i USING(IdIngreso)
                INNER JOIN  ExistenciasConsolidadas ec USING(IdArticulo, IdPuntoVenta)
                WHERE       i.IdIngreso = pIdIngreso AND i.Estado = 'A'
                            AND ec.IdCanal = pIdCanal
                GROUP BY    IdArticulo
                HAVING      SUM(li.Cantidad) > SUM(ec.Cantidad) 
            ) THEN
        SET pMensaje = 'No hay suficientes existencias de los artículos que intenta borrar.';
        LEAVE SALIR;
    END IF;

    IF EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'A') THEN
        UPDATE      ExistenciasConsolidadas ec
        INNER JOIN  Ingresos i USING(IdPuntoVenta)
        INNER JOIN  LineasIngreso li USING(IdIngreso, IdArticulo)
        SET         ec.Cantidad = ec.Cantidad - li.Cantidad
        WHERE       i.IdIngreso = pIdIngreso AND i.Estado = 'A'
                    AND ec.IdCanal = pIdCanal;
    END IF;

    SET pIdEmpresa = (SELECT IdEmpresa FROM Ingresos WHERE IdIngreso = pIdIngreso);
    IF NOT((SELECT FechaAlta FROM Ingresos WHERE IdIngreso = pIdIngreso) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1)) ) THEN
        SET pMensaje = 'El ingreso supero el tiempo maximo de anulacion.';
        LEAVE SALIR;
    END IF;

    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Ingresos.*
    FROM Ingresos WHERE IdIngreso = pIdIngreso;

    UPDATE Ingresos SET Estado = 'B' WHERE IdIngreso = pIdIngreso;

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Ingresos.*
    FROM Ingresos WHERE IdIngreso = pIdIngreso;

    SET pMensaje = 'OK';
    
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_existencia`(pIdUsuario bigint, pIdIngreso bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite activar una existencia, controlando que tenga al menos una línea.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
    DECLARE pUsuario varchar(30);
    DECLARE pIdCanal bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    IF NOT EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'E') THEN
        SET pMensaje = 'No se puede activar, no está en modo edición.';
        LEAVE SALIR;
    END IF;

    IF NOT EXISTS (
                SELECT      IdIngreso
                FROM        LineasIngreso li 
                WHERE       li.IdIngreso = pIdIngreso
            ) THEN
        SET pMensaje = 'No se puede activar, no tiene líneas de ingreso asociadas.';
        LEAVE SALIR;
    END IF;

    IF (SELECT IdRemito FROM Ingresos WHERE IdIngreso = pIdIngreso) IS NULL THEN
        -- Es un ingreso de Cliente
        SET pIdCanal = (
            SELECT v.IdCanal FROM Ingresos i
            INNER JOIN Clientes c ON i.IdCliente = c.IdCliente
            INNER JOIN Ventas v ON v.IdCliente = c.IdCliente
            WHERE i.IdIngreso = pIdIngreso
        );
    ELSE
        -- Es un ingreso de Remito
        SET pIdCanal = (SELECT r.IdCanal FROM Ingresos i INNER JOIN Remitos r USING(IdRemito) WHERE i.IdIngreso = pIdIngreso);
    END IF;
    
    UPDATE      ExistenciasConsolidadas ec
    INNER JOIN  Ingresos i USING(IdPuntoVenta)
    INNER JOIN  LineasIngreso li USING(IdIngreso, IdArticulo)
    SET         ec.Cantidad = ec.Cantidad + li.Cantidad
    WHERE       i.IdIngreso = pIdIngreso
                AND ec.IdCanal = pIdCanal;

    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
    Ingresos.* FROM Ingresos WHERE IdIngreso = pIdIngreso;

    UPDATE Ingresos SET Estado = 'A' WHERE IdIngreso = pIdIngreso;

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D',
    Ingresos.* FROM Ingresos WHERE IdIngreso = pIdIngreso;

    SET pMensaje = 'OK';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_ingreso`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_ingreso`(pIdIngreso bigint)
BEGIN
    /*
    Permite instanciar un ingreso desde la base de datos.
    */
    SELECT * FROM Ingresos WHERE IdIngreso = pIdIngreso;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_alta_linea_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_linea_existencia`(pToken varchar(500), pIdIngreso bigint, pIdArticulo bigint, pCantidad decimal(10, 2), pPrecio decimal(10, 2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	Permite agregar una línea de ingreso a una existencia que se encuentre en estado En edición.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pNroLinea smallint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_linea_existencia', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'E') THEN
        SELECT 'La existencia no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        IF EXISTS (SELECT IdIngreso FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo) THEN
            INSERT INTO aud_LineasIngreso
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'A', LineasIngreso.*
            FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

            UPDATE LineasIngreso SET Cantidad = Cantidad + pCantidad WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

            INSERT INTO aud_LineasIngreso
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'D', LineasIngreso.*
            FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;
        ELSE
            SET pNroLinea = (SELECT COALESCE(MAX(NroLinea), 0) + 1 FROM LineasIngreso WHERE IdIngreso = pIdIngreso);

            INSERT INTO LineasIngreso SELECT pIdIngreso, pNroLinea, pIdArticulo, pCantidad, pPrecio;

            INSERT INTO aud_LineasIngreso
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', LineasIngreso.*
            FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND NroLinea = pNroLinea;
        END IF;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_borrar_linea_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_borrar_linea_existencia`(pToken varchar(500), pIdIngreso bigint, pIdArticulo bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	Permite quitar una línea de ingreso a una existencia que se encuentre en estado En edición.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pNroLinea smallint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borrar_linea_existencia', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'E') THEN
        SELECT 'La existencia no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF NOT EXISTS (SELECT IdIngreso FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo) THEN
        SELECT 'La línea indicada no existe.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        INSERT INTO aud_LineasIngreso
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRAR', 'A', LineasIngreso.*
        FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

        DELETE FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS `xsp_dame_lineas_ingreso`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_lineas_ingreso`(pIdIngreso bigint)
SALIR: BEGIN
    /*
	Permite listar las líneas de un ingreso.
	*/
	SELECT li.*, a.Articulo FROM LineasIngreso li INNER JOIN Articulos a USING(IdArticulo) WHERE li.IdIngreso = pIdIngreso;
END$$
DELIMITER ;
