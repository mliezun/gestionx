DROP PROCEDURE IF EXISTS `xsp_borra_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_articulo`(pToken varchar(500), pIdArticulo bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite borrar un articulo controlando que no tenga lineas asociadas.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM LineasVenta WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene ventas asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM LineasIngreso WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene ingresos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM ExistenciasConsolidadas WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene existencias asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM RectificacionesPV WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no se puede borrar, tiene rectificaciones asociadas.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;

        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_ARTICULO', 'A',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

        -- Borra
        DELETE FROM HistorialPrecios WHERE IdArticulo = pIdArticulo;

        DELETE FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

        DELETE FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;