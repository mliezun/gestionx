DROP PROCEDURE IF EXISTS `xsp_alta_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_remito`(pToken varchar(500), pIdEmpresa int, pIdProveedor bigint,
pIdPuntoVenta bigint, pIdCanal bigint, pNroRemito bigint, pCAI bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Remito controlando que el nro de remito
	* no exista ya dentro del mismo proveedor.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdRemito tinyint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_remito', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdPuntoVenta IS NULL OR pIdPuntoVenta = 0) THEN
        SELECT 'Debe ingresar el Punto de Venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe ingresar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdCanal IS NULL OR pIdCanal = 0) THEN
        SELECT 'Debe ingresar el canal.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pNroRemito IS NULL OR pNroRemito = 0) THEN
        SELECT 'Debe ingresar el numero del remito.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- IF (pCAI IS NULL OR pCAI = 0) THEN
  --       SELECT 'Debe ingresar el CAI.' Mensaje;
  --       LEAVE SALIR;
	-- END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF NOT EXISTS(SELECT PuntoVenta FROM PuntosVenta P WHERE P.IdPuntoVenta = pIdPuntoVenta) THEN
		SELECT 'Debe existir el Punto de Venta.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF NOT EXISTS(SELECT Canal FROM Canales c WHERE c.IdCanal = pIdCanal AND c.Estado = 'A') THEN
		SELECT 'El Canal no existe o no se encuentra activo.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT NroRemito FROM Remitos WHERE NroRemito = pNroRemito AND IdProveedor=pIdProveedor) THEN
		SELECT 'El numero de remito ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
	-- IF EXISTS(SELECT CAI FROM Remitos WHERE CAI = pCAI AND IdProveedor=pIdProveedor) THEN
	-- 	SELECT 'El CAI ya existe.' Mensaje;
	-- 	LEAVE SALIR;
	-- END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO Remitos SELECT 0, pIdProveedor, NULL, pIdEmpresa, pIdCanal, pNroRemito, pCAI,
		NULL, NOW(), NULL, 'E', pObservaciones;
		SET pIdRemito = LAST_INSERT_ID();
		-- Instancia un nuevo ingreso
		CALL xsp_alta_existencia(pIdUsuario, pIdPuntoVenta, NULL, pIdRemito, NULL, pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;
		-- Audita
		INSERT INTO aud_Remitos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
		Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
        
        SELECT CONCAT('OK', pIdRemito) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_remito`(pToken varchar(500), pIdRemito bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Remito a Activo siempre y cuando el estado actual sea Edicion.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_remito', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'A') THEN
		SELECT 'El remito ya está activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'E') THEN
		SELECT 'El remito debe estar en edición para poder ser activado.' Mensaje;
        LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Remitos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
		-- Activa Rol
		UPDATE Remitos SET Estado = 'A' WHERE IdRemito = pIdRemito;

		-- Instancia un nuevo ingreso
		CALL xsp_activar_existencia(pIdUsuario, (SELECT IdIngreso FROM Ingresos WHERE IdRemito=pIdRemito), pIP, pUserAgent, pAplicacion, pMensaje);
		IF pMensaje != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Aumenta la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			(SELECT IdProveedor FROM Remitos WHERE IdRemito = pIdRemito),
			'P',
			(	SELECT COALESCE(- SUM(li.Cantidad * li.Precio), 0)
				FROM Ingresos i
				INNER JOIN  LineasIngreso li USING(IdIngreso)
				WHERE i.IdRemito = pIdRemito),
			'Compra al Proveedor',
			NULL,
			pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Después
		INSERT INTO aud_Remitos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_remitos`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_remitos`(pIdEmpresa int, pCadena varchar(30), pEstado char(1), pIdProveedor bigint, pIdPuntoVenta bigint, pIdCanal bigint, pIncluyeUtilizados char(1))
BEGIN
	/*
    Permite buscar los remitos dada una cadena de búsqueda y estado (T: todos los estados).
	Para listar todos los remitos para un punto de venta si IdPuntoVenta es 0.
    */
    SELECT		r.*, i.IdIngreso, p.Proveedor, c.Canal
    FROM		Remitos r
	INNER JOIN	Ingresos i USING(IdRemito)
	INNER JOIN	Proveedores p USING(IdProveedor)
	INNER JOIN	Canales c USING(IdCanal)
    WHERE		r.IdEmpresa = pIdEmpresa
				AND CONCAT(r.NroRemito,'') LIKE CONCAT('%', pCadena, '%')
                AND (r.Estado = pEstado OR pEstado = 'T')
				AND (r.IdProveedor = pIdProveedor OR pIdProveedor=0)
				AND (i.IdPuntoVenta = pIdPuntoVenta OR pIdPuntoVenta=0)
				AND (r.IdCliente IS NULL OR pIncluyeUtilizados = 'S')
				AND (c.IdCanal = pIdCanal OR pIdCanal=0)
	ORDER BY 1 DESC;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_remito`(pIdRemito bigint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un remito desde la base de datos.
    */
	SELECT		r.*, i.IdIngreso, p.Proveedor, c.Canal
    FROM		Remitos r
	INNER JOIN	Ingresos i USING(IdRemito)
	INNER JOIN	Proveedores p USING(IdProveedor)
	INNER JOIN	Canales c USING(IdCanal)
    WHERE	r.IdRemito = pIdRemito;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_remito`(pToken varchar(500), pIdRemito bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Remito siempre y cuando no esté dado de baja ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_remito', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'B') THEN
		SELECT 'El remito ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Remitos
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','A',Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
		-- Da de baja
		UPDATE Remitos SET Estado = 'B' WHERE IdRemito = pIdRemito;

		CALL xsp_darbaja_existencia(pIdUsuario, (SELECT IdIngreso FROM Ingresos WHERE IdRemito=pIdRemito), pIP, pUserAgent, pAplicacion, pMensaje);
		IF pMensaje != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Después
		INSERT INTO aud_Remitos
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','D',Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_remito`(pToken varchar(500), pIdRemito bigint, pIdEmpresa int, pIdProveedor bigint,
pIdCanal bigint, pNroRemito bigint, pCAI bigint, pObservaciones text, 
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar un Remito existente controlando que el nro de remito 
	no exista ya dentro del mismo proveedor. 
	Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdProveedorAntiguo bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_remito', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe ingresar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdCanal IS NULL OR pIdCanal = 0) THEN
        SELECT 'Debe ingresar el canal.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pNroRemito IS NULL) THEN
        SELECT 'Debe ingresar el numero del remito.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- IF (pCAI IS NULL OR pCAI = 0) THEN
  --       SELECT 'Debe ingresar el CAI.' Mensaje;
  --       LEAVE SALIR;
	-- END IF;
	-- Control de Parámetros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF NOT EXISTS(SELECT Proveedor FROM Proveedores P WHERE P.IdProveedor = pIdProveedor AND P.Estado = 'A') THEN
		SELECT 'Debe existir el Proveedor y estar Activo.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF NOT EXISTS(SELECT Canal FROM Canales c WHERE c.IdCanal = pIdCanal AND c.Estado = 'A') THEN
		SELECT 'El Canal no existe o no se encuentra activo.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT NroRemito FROM Remitos WHERE IdRemito != pIdRemito AND NroRemito = pNroRemito AND IdProveedor=pIdProveedor) THEN
		SELECT 'El numero de remito ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
	-- IF EXISTS(SELECT CAI FROM Remitos WHERE IdRemito != pIdRemito AND CAI = pCAI AND IdProveedor=pIdProveedor) THEN
	-- 	SELECT 'El CAI ya existe.' Mensaje;
	-- 	LEAVE SALIR;
	-- END IF;
	IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'E') THEN
		SELECT 'Solo se puede modificar un remito en estado de edicion.' Mensaje;
      LEAVE SALIR;
	END IF;
	SET pIdProveedorAntiguo = (SELECT IdProveedor FROM Remitos WHERE IdRemito = pIdRemito);
	IF pIdProveedorAntiguo != pIdProveedor THEN
		IF EXISTS(SELECT li.NroLinea FROM Ingresos i INNER JOIN LineasIngreso li USING(IdIngreso) WHERE i.IdRemito = pIdRemito) THEN
			SELECT 'No se puede modificar el proveedor, hay lineas de ingresos cargadas.' Mensaje;
			LEAVE SALIR;
		END IF;
	END IF;
  
	START TRANSACTION;
    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
    -- Antes
    INSERT INTO aud_Remitos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
		Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
    -- Modifica
    UPDATE Remitos
		SET		NroRemito=pNroRemito,
					IdCanal=pIdCanal,
					IdProveedor=pIdProveedor,
					CAI=pCAI,
					Observaciones=pObservaciones
		WHERE	IdRemito=pIdRemito;
		-- Despues
    INSERT INTO aud_Remitos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
		Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;

    SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;
