DROP PROCEDURE IF EXISTS `xsp_borra_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_lista_precio`(pToken varchar(500), pIdListaPrecio bigint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite borrar una Lista de Precios existente y su histotial de porcentajes asociado.
    Controlando que no tenga Precios Lista asociados.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio) THEN
        SELECT 'La Lista indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF EXISTS(SELECT IdListaPrecio FROM Clientes WHERE IdListaPrecio = pIdListaPrecio) THEN
		SELECT 'No se puede borrar la Lista, existen clientes asociados.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

		-- Audito
		INSERT INTO aud_ListasPrecio
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA_LISTA', 'A',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;

        -- Borro Historial Porcentajes
        DELETE FROM HistorialPorcentajes WHERE IdListaPrecio = pIdListaPrecio;

        -- Borra Precios Articulos
        DELETE FROM HistorialPrecios WHERE IdListaPrecio = pIdListaPrecio;

        DELETE FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;
        
        -- Borra ListaPrecio
        DELETE FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;