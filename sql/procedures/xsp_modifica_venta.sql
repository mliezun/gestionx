DROP PROCEDURE IF EXISTS `xsp_modifica_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_venta`(pToken varchar(500), pIdVenta bigint, pIdEmpresa int, pIdCliente bigint,
pIdTipoComprobanteAfip smallint, pIdTipoTributo tinyint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite modificar una venta en un punto de venta, siempre y cuando la venta este en edicion.
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
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdVenta IS NULL OR pIdVenta = 0) THEN
        SELECT 'Debe indicar la venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCliente IS NULL OR pIdCliente = 0) THEN
        SELECT 'Debe indicar el punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoComprobanteAfip IS NOT NULL) THEN
        IF (pIdTipoComprobanteAfip = 0) THEN
            SELECT 'Debe indicar el tipo de comprobante.' Mensaje;
            LEAVE SALIR;
        END IF;
	END IF;
    IF (pIdTipoTributo IS NOT NULL) THEN
        IF (pIdTipoTributo = 0) THEN
            SELECT 'Debe indicar el tipo de tributo.' Mensaje;
            LEAVE SALIR;
        END IF;
	END IF;
    
	-- Control de Parametros incorrectos
	IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta) THEN
        SELECT 'La venta indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT Estado FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
		SELECT 'La venta debe estar en edicion para ser modificada.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa) THEN
        SELECT 'La empresa indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoComprobanteAfip IS NOT NULL) THEN
        IF NOT EXISTS (SELECT IdTipoComprobanteAfip FROM TiposComprobantesAfip WHERE IdTipoComprobanteAfip = pIdTipoComprobanteAfip) THEN
            SELECT 'El tipo de comprobante indicado no existe.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;
    IF (pIdTipoTributo IS NOT NULL) THEN
        IF NOT EXISTS (SELECT IdTipoTributo FROM TiposTributos WHERE IdTipoTributo = pIdTipoTributo) THEN
            SELECT 'El tipo de tributo indicado no existe.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;

    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Audito Antes
        INSERT INTO aud_Ventas
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
		-- Da de alta calculando el próximo id
        UPDATE Ventas
        SET     IdCliente=pIdCliente,
                IdTipoComprobanteAfip=pIdTipoComprobanteAfip,
                IdTipoTributo=pIdTipoTributo,
                Observaciones=pObservaciones
        WHERE IdVenta=pIdVenta;
		-- Audito Despues
		INSERT INTO aud_Ventas
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;