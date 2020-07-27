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

        -- Se crea la cuenta corriente del Proveedor
		CALL xsp_alta_cuenta_corriente(pIdUsuarioGestion, 
			pIdProveedor,
			'P',
			'Alta del Proveedor',
			NULL,
			pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;
		
        SELECT CONCAT('OK', pIdProveedor) Mensaje;
	COMMIT;
END$$

DELIMITER ;