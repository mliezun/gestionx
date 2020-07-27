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