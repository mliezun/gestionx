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