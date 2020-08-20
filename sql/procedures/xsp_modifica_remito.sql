DROP PROCEDURE IF EXISTS `xsp_modifica_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_remito`(pToken varchar(500), pIdRemito bigint, pIdEmpresa int, pIdProveedor bigint,
pIdCanal bigint, pNroRemito bigint, pCAI bigint, pNroFactura bigint, pFechaFacturado datetime, pObservaciones text, 
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
	IF (pNroRemito IS NULL OR pNroRemito = 0) THEN
        SET pNroRemito = NULL;
	END IF;
	IF (pNroFactura IS NULL OR pNroFactura = 0) THEN
        SET pNroFactura = NULL;
	END IF;
	-- IF (pNroRemito IS NULL) THEN
    --     SELECT 'Debe ingresar el numero del remito.' Mensaje;
    --     LEAVE SALIR;
	-- END IF;
	-- IF (pCAI IS NULL OR pCAI = 0) THEN
    --     SELECT 'Debe ingresar el CAI.' Mensaje;
    --     LEAVE SALIR;
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
	IF (pNroRemito IS NOT NULL) THEN
		IF EXISTS(SELECT NroRemito FROM Remitos WHERE IdRemito != pIdRemito AND NroRemito = pNroRemito AND IdProveedor=pIdProveedor) THEN
			SELECT 'El numero de remito ya existe.' Mensaje;
			LEAVE SALIR;
		END IF;
	END IF;
	-- IF EXISTS(SELECT CAI FROM Remitos WHERE IdRemito != pIdRemito AND CAI = pCAI AND IdProveedor=pIdProveedor) THEN
	-- 	SELECT 'El CAI ya existe.' Mensaje;
	-- 	LEAVE SALIR;
	-- END IF;
	IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado IN ('E', 'I')) THEN
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
    UPDATE	Remitos
	SET		NroRemito=pNroRemito,
			IdCanal=pIdCanal,
			IdProveedor=pIdProveedor,
			CAI=pCAI,
			NroFactura=pNroFactura,
			FechaFacturado=pFechaFacturado,
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