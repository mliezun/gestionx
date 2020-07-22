DROP PROCEDURE IF EXISTS `xsp_alta_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_cliente`(pToken varchar(500), pIdEmpresa int, pIdListaPrecio bigint, pIdTipoDocAfip tinyint,
pNombres varchar(255), pApellidos varchar(255), pRazonSocial varchar(255), pDocumento char(12),
pDatos text, pTipo char(1), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Cliente.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdCliente bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_cliente', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdListaPrecio IS NULL OR pIdListaPrecio = 0) THEN
        SELECT 'Debe ingresar la lista de precio.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoDocAfip IS NULL OR pIdTipoDocAfip = 0) THEN
        SELECT 'Debe indicar el tipo de documento.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDatos IS NULL) THEN
        SELECT 'Debe los datos del cliente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pTipo IS NULL) THEN
        SELECT 'Debe ingresar el tipo de cliente.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Lista FROM ListasPrecio LP WHERE LP.IdListaPrecio = pIdListaPrecio AND LP.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la lista de precios dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT TipoDocAfip FROM TiposDocAfip tda WHERE tda.IdTipoDocAfip = pIdTipoDocAfip) THEN
		SELECT 'Debe existir la lista de precios dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoDocAfip FROM TiposDocAfip
    WHERE IdTipoDocAfip = pIdTipoDocAfip AND FechaHasta IS NULL) THEN
        SELECT 'El tipo de documento indicado no se encuentra vigente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pTipo NOT IN ('F','J')) THEN
        SELECT 'El tipo de cliente juridico no es valido.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pTipo = 'J') THEN
        IF (pRazonSocial IS NULL OR pRazonSocial = '') THEN
            SELECT 'Un cliente juridico debe tener razon social.' Mensaje;
            LEAVE SALIR;
	    END IF;
        SET pNombres = '';
        SET pApellidos = '';
	END IF;
    IF (pTipo = 'F') THEN
        IF (pNombres IS NULL OR pNombres = '') THEN
            SELECT 'Un cliente fisico debe tener nombres.' Mensaje;
            LEAVE SALIR;
	    END IF;
        IF (pApellidos IS NULL OR pApellidos = '') THEN
            SELECT 'Un cliente fisico debe tener apellidos.' Mensaje;
            LEAVE SALIR;
	    END IF;
        SET pRazonSocial = '';
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		
        -- Inserta
        INSERT INTO Clientes SELECT 0, pIdEmpresa, pIdListaPrecio, pIdTipoDocAfip, pNombres, pApellidos,
        pRazonSocial, pDocumento, pDatos, NOW(), pTipo, 'A', pObservaciones;

        SET pIdCliente = LAST_INSERT_ID();

		-- Audita
		INSERT INTO aud_Clientes
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Clientes.* FROM Clientes WHERE IdCliente = pIdCliente;
        
        SELECT CONCAT('OK', pIdCliente) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_cliente`(pToken varchar(500), pIdCliente bigint, pIdEmpresa int, pIdListaPrecio bigint, pIdTipoDocAfip tinyint,
pNombres varchar(255), pApellidos varchar(255), pRazonSocial varchar(255), pDocumento char(12),
pDatos text, pTipo char(1), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un Cliente.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_cliente', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdListaPrecio IS NULL OR pIdListaPrecio = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoDocAfip IS NULL OR pIdTipoDocAfip = 0) THEN
        SELECT 'Debe ingresar el tipo de documento.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDatos IS NULL) THEN
        SELECT 'Debe los datos del cliente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pTipo IS NULL) THEN
        SELECT 'Debe el tipo de cliente.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Lista FROM ListasPrecio LP WHERE LP.IdListaPrecio = pIdListaPrecio AND LP.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la lista de precios dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT TipoDocAfip FROM TiposDocAfip tda WHERE tda.IdTipoDocAfip = pIdTipoDocAfip) THEN
		SELECT 'Debe existir el tipo de documento.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoDocAfip FROM TiposDocAfip
    WHERE IdTipoDocAfip = pIdTipoDocAfip AND FechaHasta IS NULL) THEN
        SELECT 'El tipo de documento indicado no se encuentra vigente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pTipo NOT IN ('F','J')) THEN
        SELECT 'El tipo de cliente juridico no es valido.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pTipo = 'J') THEN
        IF (pRazonSocial IS NULL OR pRazonSocial = '') THEN
            SELECT 'Un cliente juridico debe tener razon social.' Mensaje;
            LEAVE SALIR;
	    END IF;
        SET pNombres = '';
        SET pApellidos = '';
	END IF;
    IF (pTipo = 'F') THEN
        IF (pNombres IS NULL OR pNombres = '') THEN
            SELECT 'Un cliente fisico debe tener nombres.' Mensaje;
            LEAVE SALIR;
	    END IF;
        IF (pApellidos IS NULL OR pApellidos = '') THEN
            SELECT 'Un cliente fisico debe tener apellidos.' Mensaje;
            LEAVE SALIR;
	    END IF;
        SET pRazonSocial = '';
	END IF;

    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_Clientes
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Clientes.*
        FROM Clientes WHERE IdCliente = pIdCliente;
        
        -- Modifica
        UPDATE Clientes 
		SET		Nombres=pNombres,
                Apellidos=pApellidos,
                RazonSocial=pRazonSocial,
                Datos=pDatos,
                Tipo=pTipo,
                Documento=pDocumento,
                IdTipoDocAfip=pIdTipoDocAfip,
                IdListaPrecio=pIdListaPrecio,
                Observaciones=pObservaciones
		WHERE	IdCliente=pIdCliente;

		-- Despues
        INSERT INTO aud_Clientes
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Clientes.*
        FROM Clientes WHERE IdCliente = pIdCliente;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_cliente`(pToken varchar(500), pIdCliente bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un cliente controlando que no tenga ingresos o ventas asosiadas.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_cliente', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdVenta FROM Ventas WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene ventas asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene ingresos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdRemito FROM Remitos WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene remitos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdCheque FROM Cheques WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no se puede borrar, tiene cheques asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Clientes
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Clientes.*
        FROM Clientes WHERE IdCliente = pIdCliente;
        -- Borro
        DELETE FROM Clientes WHERE IdCliente = pIdCliente;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_cliente`(pIdCliente bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un cliente desde la base de datos.
    */
	SELECT		c.*, lp.Lista, tda.TipoDocAfip
    FROM		Clientes c
    INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
    INNER JOIN  TiposDocAfip tda USING(IdTipoDocAfip)
    WHERE	c.IdCliente = pIdCliente;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_cliente`(pToken varchar(500), pIdCliente bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado del Cliente a Activo siempre y cuando no esté activo ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_cliente', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Clientes WHERE IdCliente = pIdCliente AND Estado = 'A') THEN
		SELECT 'El Cliente ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Clientes
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Clientes.* FROM Clientes WHERE IdCliente = pIdCliente;
		-- Activa Cliente
		UPDATE Clientes SET Estado = 'A' WHERE IdCliente = pIdCliente;
		-- Después
		INSERT INTO aud_Clientes
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Clientes.* FROM Clientes WHERE IdCliente = pIdCliente;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_cliente`(pToken varchar(500), pIdCliente bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de baja a un Cliente siempre y cuando no esté dado de baja ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_cliente', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Clientes WHERE IdCliente = pIdCliente AND Estado = 'B') THEN
		SELECT 'El Cliente ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Clientes
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Clientes.* FROM Clientes WHERE IdCliente = pIdCliente;
		-- Activa Cliente
		UPDATE Clientes SET Estado = 'B' WHERE IdCliente = pIdCliente;
		-- Después
		INSERT INTO aud_Clientes
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Clientes.* FROM Clientes WHERE IdCliente = pIdCliente;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_clientes`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_clientes`(pIdEmpresa int, pCadena varchar(30), pTipo char(1), pEstado char(1))
BEGIN
	/*
    * Permite buscar los clientes dada una cadena de búsqueda, el tipo de cliente (T para listar todas) y el estado.
    * Para listar todos, cadena vacía.
    */
    SELECT		c.*, lp.Lista, tda.TipoDocAfip
    FROM		Clientes c
    INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
    INNER JOIN  TiposDocAfip tda USING(IdTipoDocAfip)
    WHERE		c.IdEmpresa = pIdEmpresa
                AND (c.Tipo = pTipo OR pTipo = 'T')
                AND (c.Estado = pEstado OR pEstado = 'T')
                AND (
                    c.Nombres LIKE CONCAT('%', pCadena, '%') OR
                    c.Apellidos LIKE CONCAT('%', pCadena, '%') OR
                    c.RazonSocial LIKE CONCAT('%', pCadena, '%')
                );
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_ventas_clientes`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_ventas_clientes`(pIdEmpresa int, pIdCliente bigint, pFechaInicio date, pFechaFin date, pEstado char(1), pEstadoVenta char(1), pMora char(1))
BEGIN
	/*
    Permite buscar entre todos los movimientos de un cliente, entre 2 fechas, permitiendo filtrar los
    clientes por su estado con pEstado y filtrar las ventas por su estado con pEstadoVenta.
    Permitiendo ver cuáles están en mora con pMora [S|N].
    */
    SET pFechaInicio = COALESCE(pFechaInicio, NOW() - INTERVAL 1 YEAR);
    SET pFechaFin = COALESCE(pFechaFin, NOW());
    SET pMora = COALESCE(pMora, 'N');

    SELECT		c.*, v.IdVenta, v.Monto, v.Tipo TipoVenta, v.FechaAlta FechaAltaVenta,
                v.Estado EstadoVenta, v.Observaciones ObservacionesVenta, v.IdPuntoVenta,
                GROUP_CONCAT('[', JSON_OBJECT(
                    'IdPago', p.IdPago,
                    'IdMedioPago', p.IdMedioPago,
                    'MedioPago', (SELECT MedioPago FROM MediosPago WHERE IdMedioPago = p.IdMedioPago),
                    'FechaAlta', p.FechaAlta,
                    'FechaDebe', p.FechaDebe,
                    'FechaPago', p.FechaPago,
                    'FechaAnula', p.FechaAnula,
                    'Monto', p.Monto,
                    'Observaciones', p.Observaciones,
                    'IdCheque', p.IdCheque,
                    'NroTarjeta', p.NroTarjeta,
                    'MesVencimiento', p.MesVencimiento,
                    'AnioVencimiento', p.AnioVencimiento,
                    'CCV', p.CCV
                ), ']') Pagos, SUM(p.Monto) MontoPagos
    FROM        Clientes c
    INNER JOIN  Ventas v USING(IdCliente)
    LEFT JOIN   Pagos p USING(IdVenta)
    WHERE       v.IdEmpresa = pIdEmpresa AND (pIdCliente = 0 OR c.IdCliente = pIdCliente)
                AND (c.Estado = pEstado OR pEstado = 'T')
                AND (v.Estado = pEstadoVenta OR pEstadoVenta = 'T')
                AND (v.FechaAlta BETWEEN pFechaInicio AND (pFechaFin + INTERVAL 1 DAY))
    GROUP BY    c.IdCliente, v.IdVenta
    HAVING      pMora = 'N' OR (v.Estado = 'A' AND v.Monto > SUM(p.Monto))
    ORDER BY    v.FechaAlta DESC; -- pMora = 'S' => (MontoVenta < SUM(MontoPago))
END$$
DELIMITER ;
