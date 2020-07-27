DROP PROCEDURE IF EXISTS `xsp_modifica_precio_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_precio_articulo`(pToken varchar(500), pIdArticulo bigint, pIdListaPrecio bigint,
    pPrecioVenta decimal(12, 2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar un precio de un articulo.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdArticulo IS NULL OR pIdArticulo = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdListaPrecio IS NULL OR pIdListaPrecio = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPrecioVenta IS NULL OR pPrecioVenta = 0) THEN
        SELECT 'El precio de venta del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El articulo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio) THEN
        SELECT 'La lista de precios indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio AND Estado = 'A') THEN
        SELECT 'La lista no se encuentra activa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo AND Estado = 'A') THEN
        SELECT 'El Articulo no se encuentra activa.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita Antes
        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;

        -- Modifica en PreciosArticulos
        UPDATE PreciosArticulos
        SET     PrecioVenta=pPrecioVenta,
                FechaAlta=NOW()
        WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;
        
        -- Audita Despues
        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;