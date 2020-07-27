DROP PROCEDURE IF EXISTS `xsp_borra_rectificacionpv`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_rectificacionpv`(pToken varchar(500), pIdRectificacionPV bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite borrar una Rectificacion de Punto de Venta, dentro del tiempo de anulacion.
	* Siempre y cuando se encuentre pendiente de confirmación
	* Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pIdPuntoVentaOrigen bigint;
	DECLARE pIdArticulo bigint;
	DECLARE pIdCanal bigint;
	DECLARE pIdEmpresa int;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pCantidad decimal(12,2);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_rectificacionpv', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdRectificacionPV IS NULL OR pIdRectificacionPV = 0) THEN
        SELECT 'Debe ingresar la rectificacion del punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV=pIdRectificacionPV) THEN
		SELECT 'Debe existir la rectificacion del punto de venta.' Mensaje;
		LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdRectificacionPV FROM RectificacionesPV WHERE IdRectificacionPV=pIdRectificacionPV AND Estado = 'C') THEN
		SELECT 'No se puede anular una rectificacion ya confirmada.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
	IF NOT((SELECT FechaAlta FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1)) ) THEN
        SELECT 'La venta supero el tiempo maximo de anulacion.' Mensaje;
        LEAVE SALIR;
    END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		SET pIdPuntoVentaOrigen = (SELECT IdPuntoVentaOrigen FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdArticulo = (SELECT IdArticulo FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pIdCanal = (SELECT IdCanal FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		SET pCantidad = (SELECT Cantidad FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV);
		
		-- Modifico las existencias consolidadas
		UPDATE ExistenciasConsolidadas
		SET Cantidad = Cantidad + pCantidad
		WHERE IdPuntoVenta = pIdPuntoVentaOrigen AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
		
		-- Audito
		INSERT INTO aud_RectificacionesPV
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B',
		RectificacionesPV.* FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;
        
		-- Borra Rectificacion
        DELETE FROM RectificacionesPV WHERE IdRectificacionPV = pIdRectificacionPV;
        
        SELECT CONCAT('OK') Mensaje;
	COMMIT;
END$$

DELIMITER ;