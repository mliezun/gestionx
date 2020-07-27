DROP PROCEDURE IF EXISTS `xsp_alta_linea_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_linea_venta`(pToken varchar(500), pIdVenta bigint, pIdArticulo bigint, pCantidad decimal(12, 2),
pPrecio decimal(10, 2), pConsumeStock char(1), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	* Permite agregar una línea de venta a una venta que se encuentre en estado En edición.
    * Controlando si exite stock suficiente, si es que consume stock (pConsumeStock = 'S').
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pNroLinea smallint;
    DECLARE pFactor decimal(10, 4);
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pIdPuntoVenta bigint;
    DECLARE pIdListaPrecio bigint;
    DECLARE pIdCanal bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_linea_venta', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdVenta FROM Ventas WHERE IdVenta = pIdVenta AND Estado = 'E') THEN
        SELECT 'La venta no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    SELECT IdPuntoVenta, IdCanal INTO pIdPuntoVenta, pIdCanal FROM Ventas WHERE IdVenta = pIdVenta;
    IF(pConsumeStock = 'S') THEN
        IF ( (SELECT COALESCE(SUM(Cantidad),0) FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo ) + pCantidad
        > (SELECT Cantidad FROM ExistenciasConsolidadas WHERE IdArticulo = pIdArticulo AND IdPuntoVenta = pIdPuntoVenta AND IdCanal = pIdCanal)) THEN
            SELECT 'No hay stock suficiente.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;
    IF ( (SELECT Tipo FROM Ventas WHERE IdVenta = pIdVenta) = 'G') THEN
        -- Venta por Garantia
        SET pPrecio = 0;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        /* IF EXISTS (SELECT IdVenta FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo) THEN
            -- Audito Antes la linea de venta
            INSERT INTO aud_LineasVenta
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'A', LineasVenta.*
            FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
            -- Modifica la linea de venta
            UPDATE LineasVenta SET Cantidad = Cantidad + pCantidad WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
            -- Audito Despues la linea de venta
            INSERT INTO aud_LineasVenta
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'D', LineasVenta.*
            FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
        ELSE
            SET pNroLinea = (SELECT COALESCE(MAX(NroLinea), 0) + 1 FROM LineasVenta WHERE IdVenta = pIdVenta);
            SET pIdListaPrecio = (SELECT c.IdListaPrecio FROM Ventas v
            INNER JOIN Clientes c USING(IdCliente) WHERE v.IdVenta = pIdVenta);
            SET pFactor = (SELECT (pPrecio/pa.PrecioVenta) FROM Articulos a 
            INNER JOIN PreciosArticulos pa USING(IdArticulo)
            WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio);
            -- Inserto la linea de venta
            INSERT INTO LineasVenta SELECT pIdVenta, pNroLinea, pIdArticulo, pCantidad, pPrecio, pFactor;
            -- Audito la linea de venta
            INSERT INTO aud_LineasVenta
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', LineasVenta.*
            FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;
        END IF; */

        SET pNroLinea = (SELECT COALESCE(MAX(NroLinea), 0) + 1 FROM LineasVenta WHERE IdVenta = pIdVenta);
        SET pIdListaPrecio = (SELECT c.IdListaPrecio FROM Ventas v
        INNER JOIN Clientes c USING(IdCliente) WHERE v.IdVenta = pIdVenta);
        SET pFactor = (SELECT (pPrecio/pa.PrecioVenta) FROM Articulos a 
        INNER JOIN PreciosArticulos pa USING(IdArticulo)
        WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio);
        -- Inserto la linea de venta
        INSERT INTO LineasVenta SELECT pIdVenta, pNroLinea, pIdArticulo, pCantidad, pPrecio, pFactor;
        -- Audito la linea de venta
        INSERT INTO aud_LineasVenta
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', LineasVenta.*
        FROM LineasVenta WHERE IdVenta = pIdVenta AND IdArticulo = pIdArticulo;

        IF (pConsumeStock = 'S') THEN
            SET pIdPuntoVenta = (SELECT IdPuntoVenta FROM Ventas WHERE IdVenta = pIdVenta);
            -- Modifico la existencia consolidada
            UPDATE ExistenciasConsolidadas SET Cantidad = Cantidad - pCantidad WHERE IdPuntoVenta = pIdPuntoVenta AND IdArticulo = pIdArticulo AND IdCanal = pIdCanal;
        END IF;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$

DELIMITER ;