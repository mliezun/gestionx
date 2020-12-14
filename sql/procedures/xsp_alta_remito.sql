DROP PROCEDURE IF EXISTS `xsp_alta_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_remito`(pToken varchar(500), pIdEmpresa int, pIdProveedor bigint,
pIdPuntoVenta bigint, pIdCanal bigint, pNroRemito bigint, pCAI bigint,
pNroFactura bigint, pFechaFactura datetime, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Remito controlando que el nro de remito
	* no exista ya dentro del mismo proveedor.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdRemito bigint;
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
        SET pNroRemito = NULL;
	END IF;
	IF (pNroFactura IS NULL OR pNroFactura = 0) THEN
        SET pNroFactura = NULL;
	END IF;
	-- IF (pNroRemito IS NULL OR pNroRemito = 0) THEN
	-- 	SELECT 'Debe ingresar el numero del remito.' Mensaje;
    --     LEAVE SALIR;
	-- END IF;
	-- IF (pCAI IS NULL OR pCAI = 0) THEN
    --     SELECT 'Debe ingresar el CAI.' Mensaje;
    --     LEAVE SALIR;
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
	IF (pNroRemito IS NOT NULL AND pNroRemito != 0) THEN
		IF EXISTS(SELECT NroRemito FROM Remitos WHERE NroRemito = pNroRemito AND IdProveedor=pIdProveedor) THEN
			SELECT 'El numero de remito ya existe.' Mensaje;
			LEAVE SALIR;
		END IF;
	END IF;
	-- IF EXISTS(SELECT CAI FROM Remitos WHERE CAI = pCAI AND IdProveedor=pIdProveedor) THEN
	-- 	SELECT 'El CAI ya existe.' Mensaje;
	-- 	LEAVE SALIR;
	-- END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO Remitos SELECT 0, pIdProveedor, NULL, pIdEmpresa, pIdCanal, pNroRemito, pCAI,
		pNroFactura, NOW(), pFechaFactura, 'E', pObservaciones;
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