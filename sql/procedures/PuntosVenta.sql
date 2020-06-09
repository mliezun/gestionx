DROP PROCEDURE IF EXISTS `xsp_dame_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_puntoventa`(pIdPuntoVenta bigint)
BEGIN
	/**
    * Procedimiento que sirve para instanciar un punto venta desde la base de datos.
    */
	SELECT	*
    FROM	PuntosVenta
    WHERE	IdPuntoVenta = pIdPuntoVenta;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_alta_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_puntoventa`(pToken varchar(500), pHost varchar(255), pPuntoVenta varchar(100),
pDatos text, pObservaciones varchar(255), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Punto Venta controlando que el nombre del punto venta 
	* no exista ya dentro de la misma empresa.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdPuntoVenta bigint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdEmpresa int;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pHost IS NULL OR pHost = '') THEN
        SELECT 'Debe ingresar el url de la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPuntoVenta IS NULL OR pPuntoVenta = '') THEN
        SELECT 'Debe ingresar el nombre del punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pDatos IS NULL OR pDatos = '') THEN
        SELECT 'Debe ingresar los datos del punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.URL = pHost) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas E WHERE E.URL = pHost);
    IF EXISTS(SELECT PuntoVenta FROM PuntosVenta WHERE PuntoVenta = pPuntoVenta AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre del punto de venta ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO PuntosVenta SELECT 0, pIdEmpresa, pPuntoVenta, pDatos, 'A', pObservaciones;
		SET pIdPuntoVenta = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;

		INSERT INTO ExistenciasConsolidadas
        SELECT      IdArticulo, pIdPuntoVenta, IdCanal, 0
        FROM        Articulos a
		CROSS JOIN  Canales c
        WHERE       a.IdEmpresa = pIdEmpresa AND c.IdEmpresa = pIdEmpresa;
        
        SELECT CONCAT('OK', pIdPuntoVenta) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_puntosventa`(pHost varchar(255), pCadena varchar(30), pEstado char(1))
BEGIN
	/**
	Permite buscar los puntos venta dada una cadena de búsqueda y estado (T: todos los estados).
	Para listar todos, cadena vacía.
	xsp_buscar_puntosventa
    */
    SELECT		p.*
    FROM		PuntosVenta p
    INNER JOIN	Empresas e USING(IdEmpresa)
    WHERE		e.URL = pHost
				AND p.PuntoVenta LIKE CONCAT('%', pCadena, '%')
                AND (p.Estado = pEstado OR pEstado = 'T');
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_puntoventa`(pToken varchar(500), pHost varchar(255), pIdPuntoVenta bigint,
pPuntoVenta varchar(100), pDatos text, pObservaciones text, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar un PuntoVenta existente controlando que el nombre del punto de venta no exista ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pHost IS NULL OR pHost = '') THEN
        SELECT 'Debe ingresar el url de la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPuntoVenta IS NULL OR pPuntoVenta = '') THEN
        SELECT 'Debe ingresar el nombre del punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.URL = pHost) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas E WHERE E.URL = pHost);
    IF EXISTS(SELECT PuntoVenta FROM PuntosVenta WHERE IdPuntoVenta != pIdPuntoVenta 
	AND PuntoVenta = pPuntoVenta AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre del punto de venta ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_PuntosVenta
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', PuntosVenta.*
        FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
        -- Modifica
        UPDATE PuntosVenta 
		SET		PuntoVenta=pPuntoVenta,
				Datos=pDatos
		WHERE	IdPuntoVenta=pIdPuntoVenta;
		-- Despues
        INSERT INTO aud_PuntosVenta
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', PuntosVenta.*
        FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_puntoventa`(pToken varchar(500), pIdPuntoVenta bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite borrar un PuntoVenta existente controlando que no existan ventas,
	rectificaciones pv, ingresos o existencias cosolidadas asociadas.
	Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM Ventas WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen ventas asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdPuntoVentaOrigen = pIdPuntoVenta OR IdPuntoVentaDestino = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen rectificaciones pv asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM Ingresos WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen ingresos asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM ExistenciasConsolidadas WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen existencias consolidadas asociadas.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdPuntoVenta FROM UsuariosPuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'No se puede borrar el punto de venta. Existen usuarios asociados.' Mensaje;
		LEAVE SALIR;
	END IF;
	-- Borra el puntoventa
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Audito
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
        -- Borra rol
        DELETE FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_puntoventa`(pToken varchar(500), pIdPuntoVenta bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del PuntoVenta a Activo siempre y cuando no esté activo ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta AND Estado = 'A') THEN
		SELECT 'El punto de venta ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
		-- Activa Rol
		UPDATE PuntosVenta SET Estado = 'A' WHERE IdPuntoVenta = pIdPuntoVenta;
		-- Después
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_puntoventa`(pToken varchar(500), pIdPuntoVenta bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del PuntoVenta a Baja siempre y cuando no esté dado de baja ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta AND Estado = 'B') THEN
		SELECT 'El punto de venta ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
		-- Da de baja
		UPDATE PuntosVenta SET Estado = 'B' WHERE IdPuntoVenta = pIdPuntoVenta;
		-- Después
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_asignar_usuario_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_asignar_usuario_puntoventa`(pToken varchar(500), pIdUsuario bigint, pIdPuntoVenta bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite asignar el punto de venta al que pertenece un usuario, controlando que ambos pertenezcan a la misma empresa.
	Un usuario sólo puede pertenecer a un punto de venta. Por lo tanto se dan de baja las pertenencias anteriores y se 
	da de alta la nueva en estado activo.
	Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuarioAud, pIdEmpresa bigint;
	DECLARE pIdRol int;
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_asignar_usuario_puntoventa', pMensaje, pIdUsuarioAud);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros vacíos
    IF pIdUsuario IS NULL THEN
		SELECT 'Debe indicar un usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros incorrectos
    IF NOT EXISTS(SELECT IdUsuario FROM Usuarios u INNER JOIN Empresas e USING(IdEmpresa)
				INNER JOIN PuntosVenta pv USING(IdEmpresa) WHERE u.IdUsuario = pIdUsuario AND pv.IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'El usuario y el punto de venta no pertenecen a la misma empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	SET pIdRol = (SELECT IdRol FROM Roles INNER JOIN ParametroEmpresa USING(IdEmpresa) WHERE Parametro = 'ROLVENDEDOR' AND IdEmpresa = pIdEmpresa AND Valor = Rol);
	IF NOT EXISTS (SELECT IdUsuario FROM Usuarios WHERE IdUsuario = pIdUsuario AND IdRol = pIdRol) THEN
		SELECT 'El usuario no es vendedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    
	START TRANSACTION;
		
		UPDATE UsuariosPuntosVenta SET Estado = 'B' WHERE IdUsuario = pIdUsuario;

		INSERT INTO UsuariosPuntosVenta SELECT 0, pIdPuntoVenta, pIdUsuario, 'A'
		ON DUPLICATE KEY UPDATE Estado = 'A';
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_desasignar_usuario_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_desasignar_usuario_puntoventa`(pToken varchar(500), pIdUsuario bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite desasignar a un usuario del punto de venta.
	Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuarioAud bigint;
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_desasignar_usuario_puntoventa', pMensaje, pIdUsuarioAud);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros vacíos
    IF pIdUsuario IS NULL THEN
		SELECT 'Debe indicar un usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
	START TRANSACTION;
		UPDATE UsuariosPuntosVenta SET Estado = 'B' WHERE IdUsuario = pIdUsuario;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_usuarios_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_usuarios_puntosventa`(pCadena varchar(100), pIdPuntoVenta bigint)
SALIR: BEGIN
	/*
    Permite buscar usuarios de un punto de venta, indicando una cadena de búsqueda y un punto de venta.
    */
    SELECT		u.*, upv.IdUsuarioPuntoVenta, upv.IdPuntoVenta
	FROM		Usuarios u
	INNER JOIN	UsuariosPuntosVenta upv USING(IdUsuario)
	WHERE		upv.IdPuntoVenta = pIdPuntoVenta
				AND upv.Estado = 'A'
				AND (
					u.Usuario LIKE CONCAT('%', pCadena, '%') OR
					u.Apellidos LIKE CONCAT('%', pCadena, '%') OR
					u.Nombres LIKE CONCAT('%', pCadena, '%')
				);
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_dame_usuarios_asignar_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_usuarios_asignar_puntosventa`(pIdPuntoVenta bigint)
SALIR: BEGIN
	/*
    Permite listar usuarios  asignables a un punto de venta.
    */
	DECLARE pIdEmpresa bigint;
	DECLARE pIdRol int;
	SET pIdEmpresa = (SELECT IdEmpresa FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta);
	SET pIdRol = (SELECT IdRol FROM Roles INNER JOIN ParametroEmpresa USING(IdEmpresa) WHERE Parametro = 'ROLVENDEDOR' AND IdEmpresa = pIdEmpresa AND Valor = Rol);
    SELECT		u.*
	FROM		(SELECT * FROM Usuarios WHERE IdRol = pIdRol AND Estado = 'A') u
	LEFT JOIN	(SELECT * FROM UsuariosPuntosVenta WHERE Estado = 'A' AND IdPuntoVenta = pIdPuntoVenta) upv USING(IdUsuario)
	WHERE		upv.IdUsuario IS NULL;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_listar_existencias_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_existencias_puntosventa`(pCadena varchar(100), pIdPuntoVenta bigint, pSinStock char(1), pIdCanal bigint)
BEGIN
	/**
    * Procedimiento que sirve para listar las existencias de un punto venta desde la base de datos.
    */
	SELECT	a.Articulo, a.Codigo, a.Descripcion, a.PrecioCosto, ec.Cantidad, c.Canal, p.Proveedor
    FROM	PuntosVenta pv
	INNER JOIN ExistenciasConsolidadas ec USING (IdPuntoVenta)
	INNER JOIN Articulos a USING (IdArticulo)
    INNER JOIN Proveedores p USING (IdProveedor)
	INNER JOIN Canales c USING (IdCanal)
    WHERE	pv.IdPuntoVenta = pIdPuntoVenta AND a.Estado = 'A'
			AND (c.IdCanal = pIdCanal OR pIdCanal = 0)
			AND (ec.Cantidad != 0 OR pSinStock = 'S')
			AND (
					a.Articulo LIKE CONCAT('%', pCadena, '%') OR
					a.Codigo LIKE CONCAT('%', pCadena, '%') OR
					a.Descripcion LIKE CONCAT('%', pCadena, '%')
				);
END$$
DELIMITER ;
