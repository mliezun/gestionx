DROP PROCEDURE IF EXISTS `xsp_borrar_linea_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_borrar_linea_venta`(pToken varchar(500), pIdVenta bigint, pIdArticulo bigint,
pConsumeStock char(1), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	* Permite quitar una línea de venta a una venta que se encuentre en estado En edición.
    * Devolviendo el stock, si es que consume stock (pConsumeStock = 'S').
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pIdPuntoVenta bigint;
    DECLARE pIdCanal bigint;
    DECLARE pNroLinea smallint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pCantidad decimal(12, 2);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borrar_linea_venta', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
        SELECT 'La venta no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF NOT EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo) THEN
        SELECT 'La línea indicada no existe.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito Antes
        INSERT INTO aud_LineasVenta
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', LineasVenta.*
        FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
        -- Borro
        SET pCantidad = (SELECT SUM(Cantidad) FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo);
        DELETE FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;

        IF (pConsumeStock = 'S') THEN
            SELECT IdPuntoVenta, IdCanal INTO pIdPuntoVenta, pIdCanal FROM Ventas WHERE IdVenta = pIdVenta;
            -- Modifico la existencia consolidada
            UPDATE ExistenciasConsolidadas SET Cantidad = Cantidad + pCantidad WHERE IdPuntoVenta = pIdPuntoVenta AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
        END IF;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$

DELIMITER ;