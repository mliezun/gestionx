DROP PROCEDURE IF EXISTS `xsp_alta_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_venta`(pToken varchar(500), pIdEmpresa int, pIdPuntoVenta bigint, pIdCliente bigint,
pIdTipoComprobanteAfip smallint, pIdTipoTributo tinyint, pIdCanal bigint, pTipo char(1), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta una venta en un punto de venta, indicando el cliente, el tipo de venta y el usuario.
    * Controlando que el tipo de tributo y tipo de comprobantes existan y esten activos.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pIdVenta bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_venta', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdPuntoVenta IS NULL OR pIdPuntoVenta = 0) THEN
        SELECT 'Debe indicar el punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCliente IS NULL OR pIdCliente = 0) THEN
        SELECT 'Debe indicar el punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCanal IS NULL OR pIdCanal = 0) THEN
        SELECT 'Debe indicar el canal de la venta.' Mensaje;
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
	IF (pTipo IS NULL) THEN
        SELECT 'Debe ingresar el tipo de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa) THEN
        SELECT 'La empresa indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdPuntoVenta FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta) THEN
        SELECT 'El punto de venta indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdCliente FROM Clientes WHERE IdCliente = pIdCliente) THEN
        SELECT 'El cliente indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCanal FROM Canales WHERE IdCanal = pIdCanal) THEN
        SELECT 'El canal indicado no existe.' Mensaje;
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
        INSERT INTO Ventas 
        SELECT 0, pIdPuntoVenta, pIdEmpresa, pIdCliente, pIdUsuario,
        pIdTipoComprobanteAfip, pIdTipoTributo, pIdCanal, 0, NOW(), pTipo, 'E', pObservaciones;
        SET pIdVenta = LAST_INSERT_ID();

		-- Audita
		INSERT INTO aud_Ventas
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Ventas.* FROM Ventas WHERE IdVenta = pIdVenta;
        
        SELECT CONCAT('OK', pIdVenta) Mensaje;
	COMMIT;
END$$

DELIMITER ;